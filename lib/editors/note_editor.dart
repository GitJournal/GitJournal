/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/image.dart' as core;
import 'package:gitjournal/core/md_yaml_doc.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/note_storage.dart';
import 'package:gitjournal/core/views/inline_tags_view.dart';
import 'package:gitjournal/editors/checklist_editor.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/editors/common_types.dart';
import 'package:gitjournal/editors/journal_editor.dart';
import 'package:gitjournal/editors/markdown_editor.dart';
import 'package:gitjournal/editors/note_editor_selector.dart';
import 'package:gitjournal/editors/org_editor.dart';
import 'package:gitjournal/editors/raw_editor.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/utils/utils.dart';
import 'package:gitjournal/widgets/folder_selection_dialog.dart';
import 'package:gitjournal/widgets/note_delete_dialog.dart';
import 'package:gitjournal/widgets/note_tag_editor.dart';
import 'package:gitjournal/widgets/rename_dialog.dart';

class ShowUndoSnackbar {}

/// Certain Editors only support certain file formats. We can create an
///   editor either by -

///   * Giving it a Note, and letting it choose an editor based on the
///     default or note metadata
///   * New Note with a file type
///   * New Note with a editor type + possible file type
class NoteEditor extends StatefulWidget {
  final Note? existingNote;
  final NotesFolderFS notesFolder;
  final NotesFolder parentFolderView;
  final EditorType? defaultEditorType;
  final NoteFileFormat? defaultFileFormat;

  final String? existingText;
  final List<String>? existingImages;

  final Map<String, dynamic>? newNoteExtraProps;
  final String? newNoteFileName;
  final bool editMode;

  final String? highlightString;

  NoteEditor.fromNote(
    Note note,
    this.parentFolderView, {
    this.editMode = false,
    this.highlightString,
  })  : existingNote = note,
        notesFolder = note.parent,
        defaultEditorType = null,
        defaultFileFormat = null,
        existingText = null,
        existingImages = null,
        newNoteFileName = null,
        newNoteExtraProps = null;

  const NoteEditor.newNote(
    this.notesFolder,
    this.parentFolderView,
    this.defaultEditorType, {
    required String this.existingText,
    required List<String> this.existingImages,
    this.newNoteExtraProps = const {},
    this.newNoteFileName,
    this.defaultFileFormat,
  })  : existingNote = null,
        editMode = true,
        highlightString = null;

  @override
  NoteEditorState createState() {
    if (existingNote == null) {
      var fileFormat = defaultFileFormat ??
          notesFolder.config.defaultFileFormat.toFileFormat();

      if (defaultEditorType != null) {
        var editor = defaultEditorType!;
        if (!editorSupported(fileFormat, editor)) {
          fileFormat = defaultFormat(editor);
        }
      }

      return NoteEditorState.newNote(
        notesFolder,
        existingText!,
        existingImages!,
        newNoteExtraProps!,
        newNoteFileName,
        fileFormat,
      );
    } else {
      return NoteEditorState.fromNote();
    }
  }
}

class NoteEditorState extends State<NoteEditor>
    with WidgetsBindingObserver
    implements EditorCommon {
  Note? newNote;
  late EditorType editorType;
  MdYamlDoc originalNoteData = MdYamlDoc();

  final _rawEditorKey = GlobalKey<RawEditorState>();
  final _markdownEditorKey = GlobalKey<MarkdownEditorState>();
  final _checklistEditorKey = GlobalKey<ChecklistEditorState>();
  final _journalEditorKey = GlobalKey<JournalEditorState>();
  final _orgEditorKey = GlobalKey<OrgEditorState>();

  bool get _isNewNote => newNote != null;

  // FIXME: It would be much easier if the Note always existed and there is no concept
  //        of a new note or existing note.
  //        On discarding, the note can be deleted if it doesn't exst
  //        A new note can be denoted by not having a GitHash
  NoteEditorState.newNote(
    NotesFolderFS folder,
    String existingText,
    List<String> existingImages,
    Map<String, dynamic> extraProps,
    String? fileName,
    NoteFileFormat fileFormat,
  ) {
    newNote = Note.newNote(
      folder,
      extraProps: extraProps,
      fileName: fileName,
      fileFormat: fileFormat,
    );
    if (existingText.isNotEmpty) {
      newNote!.apply(body: existingText);
    }

    if (existingImages.isNotEmpty) {
      for (var imagePath in existingImages) {
        () async {
          try {
            var image = await core.Image.copyIntoFs(newNote!.parent, imagePath);
            newNote!.apply(
                body: newNote!.body + image.toMarkup(newNote!.fileFormat));
          } catch (e, st) {
            Log.e("New Note Existing Image", ex: e, stacktrace: st);
          }
        }();
      }
    }
  }

  NoteEditorState.fromNote();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);

    if (widget.existingNote != null) {
      originalNoteData = MdYamlDoc.from(widget.existingNote!.data);
    }

    var note = (newNote ?? widget.existingNote)!;

    // Select the editor
    if (widget.defaultEditorType != null) {
      editorType = widget.defaultEditorType!;
    } else if (widget.defaultFileFormat != null) {
      editorType = NoteFileFormatInfo.defaultEditor(widget.defaultFileFormat!);
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
          editorType = widget.notesFolder.config.defaultEditor.toEditorType();
          break;
      }
    }
  }

  @override
  void dispose() {
    var _ = WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Log.i("Note Edit State: $state");

    if (state != AppLifecycleState.resumed) {
      var note = _getNoteFromEditor();
      if (note == null) return;
      if (!_noteModified(note)) return;

      Log.d("App Lost Focus - saving note");
      var repo = Provider.of<GitJournalRepo>(context, listen: false);
      repo.saveNoteToDisk(note).then((r) {
        if (r.isFailure) {
          Log.e("Failed to save note", ex: r.error, stacktrace: r.stackTrace);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var note = _getNoteFromEditor();
        if (note == null) return true;
        var savedNote = await _saveNote(note);
        return savedNote;
      },
      child: _getEditor(),
    );
  }

  Widget _getEditor() {
    var note = (newNote ?? widget.existingNote)!;

    switch (editorType) {
      case EditorType.Markdown:
        return MarkdownEditor(
          key: _markdownEditorKey,
          note: note,
          parentFolder: widget.parentFolderView,
          noteModified: _noteModified(note),
          editMode: widget.editMode,
          highlightString: widget.highlightString,
          theme: Theme.of(context),
          common: this,
        );
      case EditorType.Raw:
        return RawEditor(
          key: _rawEditorKey,
          note: note,
          noteModified: _noteModified(note),
          editMode: widget.editMode,
          highlightString: widget.highlightString,
          theme: Theme.of(context),
          common: this,
        );
      case EditorType.Checklist:
        return ChecklistEditor(
          key: _checklistEditorKey,
          note: note,
          noteModified: _noteModified(note),
          editMode: widget.editMode,
          highlightString: widget.highlightString,
          theme: Theme.of(context),
          common: this,
        );
      case EditorType.Journal:
        return JournalEditor(
          key: _journalEditorKey,
          note: note,
          noteModified: _noteModified(note),
          editMode: widget.editMode,
          highlightString: widget.highlightString,
          theme: Theme.of(context),
          common: this,
        );
      case EditorType.Org:
        return OrgEditor(
          key: _orgEditorKey,
          note: note,
          noteModified: _noteModified(note),
          editMode: widget.editMode,
          highlightString: widget.highlightString,
          theme: Theme.of(context),
          common: this,
        );
    }
  }

  @override
  Future<void> noteEditorChooserSelected(Note note) async {
    var newEditorType = await showDialog<EditorType>(
      context: context,
      builder: (BuildContext context) {
        return NoteEditorSelector(editorType, note.fileFormat);
      },
    );

    if (newEditorType != null) {
      setState(() {
        editorType = newEditorType;
      });
    }
  }

  @override
  Future<void> exitEditorSelected(Note note) async {
    var saved = await _saveNote(note);
    if (saved) {
      Navigator.pop(context);
    }
  }

  @override
  Future<void> renameNote(Note note) async {
    // FIXME: What if the note is being renamed twice?
    //        newNote or widget.note might not be the latest version of the note
    var prevNote = (widget.existingNote ?? newNote)!;
    var prevNotePath = prevNote.filePath;

    var newFileName = await showDialog(
      context: context,
      builder: (_) => RenameDialog(
        oldPath: prevNotePath,
        inputDecoration: tr(LocaleKeys.widgets_NoteEditor_fileName),
        dialogTitle: tr(LocaleKeys.widgets_NoteEditor_renameFile),
      ),
    );
    if (newFileName == null) {
      return;
    }

    if (_isNewNote) {
      note.parent.renameNote(note, newFileName);
    } else {
      var container = context.read<GitJournalRepo>();
      container.renameNote(note, newFileName);
    }

    var newExt = p.extension(newFileName).toLowerCase();
    var oldExt = p.extension(prevNotePath).toLowerCase();
    if (oldExt != newExt) {
      // Change the editor
      var format = NoteFileFormatInfo.fromFilePath(newFileName);
      var newEditorType = NoteFileFormatInfo.defaultEditor(format);

      if (newEditorType != editorType) {
        setState(() {
          editorType = newEditorType;
        });
      }

      // Make sure this file type is supported
      var config = note.parent.config;
      if (!config.allowedFileExts.contains(newExt)) {
        var _ = config.allowedFileExts.add(newExt);
        config.save();

        var ext = newExt.isNotEmpty
            ? newExt
            : LocaleKeys.settings_fileTypes_noExt.tr();
        showSnackbar(
          context,
          LocaleKeys.widgets_NoteEditor_addType.tr(args: [ext]),
        );
      }
    }
  }

  @override
  Future<void> deleteNote(Note note) async {
    if (_isNewNote && !_noteModified(note)) {
      Navigator.pop(context); // Note Editor
      return;
    }

    var settings = context.read<Settings>();
    bool shouldDelete = true;
    if (settings.confirmDelete) {
      shouldDelete = await showDialog(
        context: context,
        builder: (context) => const NoteDeleteDialog(num: 1),
      );
    }
    if (shouldDelete == true) {
      if (!_isNewNote) {
        var stateContainer = context.read<GitJournalRepo>();
        stateContainer.removeNote(note);
      }

      if (_isNewNote) {
        Navigator.pop(context); // Note Editor
      } else {
        Navigator.pop(context, ShowUndoSnackbar()); // Note Editor
      }
    }
  }

  bool _noteModified(Note note) {
    if (_isNewNote) {
      return note.title.isNotEmpty || note.body.isNotEmpty;
    }

    if (note.data != originalNoteData) {
      dynamic _;
      final modifiedKey = note.noteSerializer.settings.modifiedKey;

      var newSimplified = MdYamlDoc.from(note.data);
      _ = newSimplified.props.remove(modifiedKey);
      newSimplified.body = newSimplified.body.trim();

      var originalSimplified = MdYamlDoc.from(originalNoteData);
      _ = originalSimplified.props.remove(modifiedKey);
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
      Clipboard.setData(ClipboardData(text: NoteStorage.serialize(note)));

      await showAlertDialog(
        context,
        tr(LocaleKeys.editors_common_saveNoteFailed_title),
        tr(LocaleKeys.editors_common_saveNoteFailed_message),
      );
      return false;
    }

    return true;
  }

  Note? _getNoteFromEditor() {
    switch (editorType) {
      case EditorType.Markdown:
        return _markdownEditorKey.currentState?.getNote();
      case EditorType.Raw:
        return _rawEditorKey.currentState?.getNote();
      case EditorType.Checklist:
        return _checklistEditorKey.currentState?.getNote();
      case EditorType.Journal:
        return _journalEditorKey.currentState?.getNote();
      case EditorType.Org:
        return _orgEditorKey.currentState?.getNote();
    }
  }

  @override
  Future<void> moveNoteToFolderSelected(Note note) async {
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

  @override
  Future<void> discardChanges(Note note) async {
    if (!_isNewNote) {
      var stateContainer = context.read<GitJournalRepo>();
      stateContainer.discardChanges(note);
    }

    Navigator.pop(context);
  }

  @override
  Future<void> editTags(Note note) async {
    final rootFolder = Provider.of<NotesFolderFS>(context, listen: false);
    var inlineTagsView = InlineTagsProvider.of(context);
    var allTags = await rootFolder.getNoteTagsRecursively(inlineTagsView);

    var route = MaterialPageRoute(
      builder: (context) => NoteTagEditor(
        selectedTags: note.tags,
        allTags: allTags,
      ),
      settings: const RouteSettings(name: '/editTags/'),
    );
    var newTags = await Navigator.of(context).push(route);
    assert(newTags != null);

    var eq = const SetEquality().equals;
    if (!eq(note.tags, newTags)) {
      setState(() {
        Log.i("Settings tags to: $newTags");
        note.apply(tags: newTags);
      });
    }
  }
}
