/*
Copyright 2020-2021 Vishesh Handa <me@vhanda.in>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gitjournal/editors/org_editor.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/md_yaml_doc.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/editors/checklist_editor.dart';
import 'package:gitjournal/editors/journal_editor.dart';
import 'package:gitjournal/editors/markdown_editor.dart';
import 'package:gitjournal/editors/raw_editor.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/utils/logger.dart';
import 'package:gitjournal/widgets/folder_selection_dialog.dart';
import 'package:gitjournal/widgets/note_delete_dialog.dart';
import 'package:gitjournal/widgets/note_editor_selector.dart';
import 'package:gitjournal/widgets/note_tag_editor.dart';
import 'package:gitjournal/widgets/rename_dialog.dart';

class ShowUndoSnackbar {}

class NoteEditor extends StatefulWidget {
  final Note note;
  final NotesFolderFS notesFolder;
  final NotesFolder parentFolderView;
  final EditorType defaultEditorType;

  final String existingText;
  final List<String> existingImages;

  final Map<String, dynamic> newNoteExtraProps;
  final String newNoteFileName;
  final bool editMode;

  NoteEditor.fromNote(
    this.note,
    this.parentFolderView, {
    this.editMode = false,
  })  : notesFolder = note.parent,
        defaultEditorType = null,
        existingText = null,
        existingImages = null,
        newNoteFileName = "",
        newNoteExtraProps = null;

  NoteEditor.newNote(
    this.notesFolder,
    this.parentFolderView,
    this.defaultEditorType, {
    this.existingText,
    this.existingImages,
    this.newNoteExtraProps = const {},
    this.newNoteFileName = "",
  })  : note = null,
        editMode = true;

  @override
  NoteEditorState createState() {
    if (note == null) {
      return NoteEditorState.newNote(
        notesFolder,
        existingText,
        existingImages,
        newNoteExtraProps,
        newNoteFileName,
      );
    } else {
      return NoteEditorState.fromNote(note);
    }
  }
}

enum EditorType { Markdown, Raw, Checklist, Journal, Org }

class NoteEditorState extends State<NoteEditor> with WidgetsBindingObserver {
  Note note;
  EditorType editorType = EditorType.Markdown;
  MdYamlDoc originalNoteData = MdYamlDoc();

  final _rawEditorKey = GlobalKey<RawEditorState>();
  final _markdownEditorKey = GlobalKey<MarkdownEditorState>();
  final _checklistEditorKey = GlobalKey<ChecklistEditorState>();
  final _journalEditorKey = GlobalKey<JournalEditorState>();
  final _orgEditorKey = GlobalKey<OrgEditorState>();

  bool get _isNewNote {
    return widget.note == null;
  }

  NoteEditorState.newNote(
    NotesFolderFS folder,
    String existingText,
    List<String> existingImages,
    Map<String, dynamic> extraProps,
    String fileName,
  ) {
    note = Note.newNote(folder, extraProps: extraProps, fileName: fileName);
    if (existingText != null) {
      note.body = existingText;
    }

    if (existingImages != null) {
      for (var imagePath in existingImages) {
        try {
          var file = File(imagePath);
          note.addImageSync(file);
        } catch (e) {
          Log.e(e);
        }
      }
    }
  }

  NoteEditorState.fromNote(this.note) {
    originalNoteData = MdYamlDoc.from(note.data);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.defaultEditorType != null) {
      editorType = widget.defaultEditorType;
    } else {
      switch (note.type) {
        case NoteType.Journal:
          editorType = EditorType.Journal;
          break;
        case NoteType.Checklist:
          editorType = EditorType.Checklist;
          break;
        case NoteType.Org:
          editorType = EditorType.Org;
          break;
        case NoteType.Unknown:
          editorType = widget.notesFolder.config.defaultEditor;
          break;
      }
    }

    // Org files
    if (note.fileFormat == NoteFileFormat.OrgMode &&
        editorType == EditorType.Markdown) {
      editorType = EditorType.Org;
    }

    // Txt files
    if (note.fileFormat == NoteFileFormat.Txt &&
        editorType == EditorType.Markdown) {
      editorType = EditorType.Raw;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Log.i("Note Edit State: $state");

    if (state != AppLifecycleState.resumed) {
      var note = _getNoteFromEditor();
      if (!_noteModified(note)) return;

      Log.d("App Lost Focus - saving note");
      note.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var savedNote = await _saveNote(_getNoteFromEditor());
        return savedNote;
      },
      child: _getEditor(),
    );
  }

  Widget _getEditor() {
    switch (editorType) {
      case EditorType.Markdown:
        return MarkdownEditor(
          key: _markdownEditorKey,
          note: note,
          parentFolder: widget.parentFolderView,
          noteModified: _noteModified(note),
          noteDeletionSelected: _noteDeletionSelected,
          noteEditorChooserSelected: _noteEditorChooserSelected,
          exitEditorSelected: _exitEditorSelected,
          renameNoteSelected: _renameNoteSelected,
          editTagsSelected: _editTagsSelected,
          moveNoteToFolderSelected: _moveNoteToFolderSelected,
          discardChangesSelected: _discardChangesSelected,
          editMode: widget.editMode,
        );
      case EditorType.Raw:
        return RawEditor(
          key: _rawEditorKey,
          note: note,
          noteModified: _noteModified(note),
          noteDeletionSelected: _noteDeletionSelected,
          noteEditorChooserSelected: _noteEditorChooserSelected,
          exitEditorSelected: _exitEditorSelected,
          renameNoteSelected: _renameNoteSelected,
          editTagsSelected: _editTagsSelected,
          moveNoteToFolderSelected: _moveNoteToFolderSelected,
          discardChangesSelected: _discardChangesSelected,
          editMode: widget.editMode,
        );
      case EditorType.Checklist:
        return ChecklistEditor(
          key: _checklistEditorKey,
          note: note,
          noteModified: _noteModified(note),
          noteDeletionSelected: _noteDeletionSelected,
          noteEditorChooserSelected: _noteEditorChooserSelected,
          exitEditorSelected: _exitEditorSelected,
          renameNoteSelected: _renameNoteSelected,
          editTagsSelected: _editTagsSelected,
          moveNoteToFolderSelected: _moveNoteToFolderSelected,
          discardChangesSelected: _discardChangesSelected,
          editMode: widget.editMode,
        );
      case EditorType.Journal:
        return JournalEditor(
          key: _journalEditorKey,
          note: note,
          noteModified: _noteModified(note),
          noteDeletionSelected: _noteDeletionSelected,
          noteEditorChooserSelected: _noteEditorChooserSelected,
          exitEditorSelected: _exitEditorSelected,
          renameNoteSelected: _renameNoteSelected,
          editTagsSelected: _editTagsSelected,
          moveNoteToFolderSelected: _moveNoteToFolderSelected,
          discardChangesSelected: _discardChangesSelected,
          editMode: widget.editMode,
        );
      case EditorType.Org:
        return OrgEditor(
          key: _orgEditorKey,
          note: note,
          noteModified: _noteModified(note),
          noteDeletionSelected: _noteDeletionSelected,
          noteEditorChooserSelected: _noteEditorChooserSelected,
          exitEditorSelected: _exitEditorSelected,
          renameNoteSelected: _renameNoteSelected,
          editTagsSelected: _editTagsSelected,
          moveNoteToFolderSelected: _moveNoteToFolderSelected,
          discardChangesSelected: _discardChangesSelected,
          editMode: widget.editMode,
        );
    }
    return null;
  }

  void _noteEditorChooserSelected(Note _note) async {
    var newEditorType = await showDialog<EditorType>(
      context: context,
      builder: (BuildContext context) {
        return NoteEditorSelector(editorType, _note.fileFormat);
      },
    );

    if (newEditorType != null) {
      setState(() {
        note = _note;
        editorType = newEditorType;
      });
    }
  }

  void _exitEditorSelected(Note note) async {
    var saved = await _saveNote(note);
    if (saved) {
      Navigator.pop(context);
    }
  }

  void _renameNoteSelected(Note _note) async {
    var fileName = await showDialog(
      context: context,
      builder: (_) => RenameDialog(
        oldPath: note.filePath,
        inputDecoration: tr('widgets.NoteEditor.fileName'),
        dialogTitle: tr('widgets.NoteEditor.renameFile'),
      ),
    );
    if (fileName is String) {
      if (_isNewNote) {
        setState(() {
          note = _note;
          note.rename(fileName);
        });
        return;
      }
      var container = context.read<GitJournalRepo>();
      container.renameNote(note, fileName);
    }
  }

  void _noteDeletionSelected(Note note) async {
    if (_isNewNote && !_noteModified(note)) {
      Navigator.pop(context);
      return;
    }

    var settings = Provider.of<Settings>(context, listen: false);
    var shouldDelete = true;
    if (settings.confirmDelete) {
      shouldDelete = await showDialog(
        context: context,
        builder: (context) => NoteDeleteDialog(),
      );
    }
    if (shouldDelete == true) {
      _deleteNote(note);

      if (_isNewNote) {
        Navigator.pop(context); // Note Editor
      } else {
        Navigator.pop(context, ShowUndoSnackbar()); // Note Editor
      }
    }
  }

  void _deleteNote(Note note) {
    if (_isNewNote) {
      return;
    }

    var stateContainer = context.read<GitJournalRepo>();
    stateContainer.removeNote(note);
  }

  bool _noteModified(Note note) {
    if (_isNewNote) {
      return note.title.isNotEmpty || note.body.isNotEmpty;
    }

    if (note.data != originalNoteData) {
      var newSimplified = MdYamlDoc.from(note.data);
      newSimplified.props.remove(note.noteSerializer.settings.modifiedKey);
      newSimplified.body = newSimplified.body.trim();

      var originalSimplified = MdYamlDoc.from(originalNoteData);
      originalSimplified.props.remove(note.noteSerializer.settings.modifiedKey);
      originalSimplified.body = originalSimplified.body.trim();

      bool hasBeenModified = newSimplified != originalSimplified;
      if (hasBeenModified) {
        Log.d("Note modified");
        // Log.d("Original: $originalSimplified");
        // Log.d("New: $newSimplified");
        return true;
      }
    }
    return false;
  }

  // Returns bool indicating if the note was successfully saved
  Future<bool> _saveNote(Note note) async {
    if (!_noteModified(note)) return true;

    Log.d("Note modified - saving");
    try {
      var stateContainer = context.read<GitJournalRepo>();
      _isNewNote
          ? await stateContainer.addNote(note)
          : await stateContainer.updateNote(note);
    } catch (e, stackTrace) {
      logException(e, stackTrace);
      Clipboard.setData(ClipboardData(text: note.serialize()));

      await showAlertDialog(
        context,
        tr("editors.common.saveNoteFailed.title"),
        tr("editors.common.saveNoteFailed.message"),
      );
      return false;
    }

    return true;
  }

  Note _getNoteFromEditor() {
    switch (editorType) {
      case EditorType.Markdown:
        return _markdownEditorKey.currentState.getNote();
      case EditorType.Raw:
        return _rawEditorKey.currentState.getNote();
      case EditorType.Checklist:
        return _checklistEditorKey.currentState.getNote();
      case EditorType.Journal:
        return _journalEditorKey.currentState.getNote();
      case EditorType.Org:
        return _orgEditorKey.currentState.getNote();
    }
    return null;
  }

  void _moveNoteToFolderSelected(Note note) async {
    var destFolder = await showDialog<NotesFolderFS>(
      context: context,
      builder: (context) => FolderSelectionDialog(),
    );
    if (destFolder != null) {
      if (_isNewNote) {
        note.parent = destFolder;
        setState(() {});
      } else {
        var stateContainer = context.read<GitJournalRepo>();
        stateContainer.moveNote(note, destFolder);
      }
    }
  }

  void _discardChangesSelected(Note note) async {
    var stateContainer = context.read<GitJournalRepo>();
    stateContainer.discardChanges(note);

    Navigator.pop(context);
  }

  void _editTagsSelected(Note _note) async {
    final rootFolder = Provider.of<NotesFolderFS>(context, listen: false);
    var allTags = rootFolder.getNoteTagsRecursively();

    var route = MaterialPageRoute(
      builder: (context) => NoteTagEditor(
        selectedTags: note.tags,
        allTags: allTags,
      ),
      settings: const RouteSettings(name: '/editTags/'),
    );
    var newTags = await Navigator.of(context).push(route);
    assert(newTags != null);

    Function eq = const SetEquality().equals;
    if (!eq(note.tags, newTags)) {
      setState(() {
        Log.i("Settings tags to: $newTags");
        note.tags = newTags;
      });
    }
  }
}
