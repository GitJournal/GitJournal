/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/image.dart' as core;
import 'package:gitjournal/core/markdown/md_yaml_doc.dart';
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
import 'package:gitjournal/utils/result.dart';
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
        newNoteExtraProps = null {
    assert(note.file.oid.isNotEmpty);
  }

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
  late Note _note;
  late final bool _isNewNote;

  bool _newNoteRenamed = false;
  late EditorType _editorType;
  MdYamlDoc _originalNoteData = MdYamlDoc();

  final _rawEditorKey = GlobalKey<RawEditorState>();
  final _markdownEditorKey = GlobalKey<MarkdownEditorState>();
  final _checklistEditorKey = GlobalKey<ChecklistEditorState>();
  final _journalEditorKey = GlobalKey<JournalEditorState>();
  final _orgEditorKey = GlobalKey<OrgEditorState>();

  NoteEditorState.newNote(
    NotesFolderFS folder,
    String existingText,
    List<String> existingImages,
    Map<String, dynamic> extraProps,
    String? fileName,
    NoteFileFormat fileFormat,
  ) {
    _isNewNote = true;
    _note = Note.newNote(
      folder,
      extraProps: extraProps,
      fileName: fileName,
      fileFormat: fileFormat,
    );

    if (existingText.isNotEmpty) {
      _note = _note.copyWith(body: existingText);
    }

    if (existingImages.isNotEmpty) {
      for (var imagePath in existingImages) {
        () async {
          try {
            var image = await core.Image.copyIntoFs(_note.parent, imagePath)
                .getOrThrow();
            _note = _note.copyWith(
                body: _note.body + image.toMarkup(_note.fileFormat));
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
      var existingNote = widget.existingNote!;
      _note = existingNote.resetOid();
      _originalNoteData = _note.data;

      _isNewNote = false;
    }

    // Select the editor
    if (widget.defaultEditorType != null) {
      _editorType = widget.defaultEditorType!;
    } else if (widget.defaultFileFormat != null) {
      _editorType = NoteFileFormatInfo.defaultEditor(widget.defaultFileFormat!);
    } else {
      switch (_note.type) {
        case NoteType.Journal:
          _editorType = EditorType.Journal;
          break;
        case NoteType.Checklist:
          _editorType = EditorType.Checklist;
          break;
        case NoteType.Org:
          _editorType = EditorType.Org;
          break;
        case NoteType.Unknown:
          _editorType = widget.notesFolder.config.defaultEditor.toEditorType();
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
    var note = _note;

    switch (_editorType) {
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
    assert(note.oid.isEmpty);

    var newEditorType = await showDialog<EditorType>(
      context: context,
      builder: (BuildContext context) {
        return NoteEditorSelector(_editorType, note.fileFormat);
      },
    );

    if (newEditorType != null) {
      setState(() {
        _note = note;
        _editorType = newEditorType;
      });
    }
  }

  @override
  Future<void> exitEditorSelected(Note note) async {
    assert(note.oid.isEmpty);

    var saved = await _saveNote(note);
    if (saved) {
      Navigator.pop(context);
    }
  }

  @override
  Future<void> renameNote(Note note) async {
    assert(note.oid.isEmpty);

    if (_isNewNote && !_newNoteRenamed) {
      if (note.shouldRebuildPath) {
        Log.d("Rebuilding Note's FileName");
        var newName = note.rebuildFileName();
        note = note.copyWithFileName(newName);
      }
    }

    var dialogResponse = await showDialog(
      context: context,
      builder: (_) => RenameDialog(
        oldPath: note.fileName,
        inputDecoration: tr(LocaleKeys.widgets_NoteEditor_fileName),
        dialogTitle: tr(LocaleKeys.widgets_NoteEditor_renameFile),
      ),
    );
    if (dialogResponse is! String) {
      return;
    }
    var newFileName = dialogResponse;

    if (_isNewNote) {
      setState(() {
        _note = note.copyWithFileName(newFileName);
        _newNoteRenamed = true;
      });
    } else {
      var container = context.read<GitJournalRepo>();

      var originalNote = widget.existingNote!;
      var renameResult = await container.renameNote(originalNote, newFileName);
      if (renameResult.isFailure) {
        await showAlertDialog(
          context,
          tr(LocaleKeys.editors_common_saveNoteFailed_title),
          tr(LocaleKeys.editors_common_saveNoteFailed_message),
        );
      }

      var newNote = renameResult.getOrThrow();
      // FIXME: Handle rename failing!
      setState(() {
        _note = newNote;
      });
    }

    var newExt = p.extension(newFileName).toLowerCase();

    // Change the editor
    var format = NoteFileFormatInfo.fromFilePath(newFileName);
    if (!editorSupported(format, _editorType)) {
      var newEditorType = NoteFileFormatInfo.defaultEditor(format);

      if (newEditorType != _editorType) {
        setState(() {
          _editorType = newEditorType;
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
    assert(note.oid.isEmpty);

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
      return note.title != null || note.body.isNotEmpty;
    }

    if (note.data != _originalNoteData) {
      final modifiedKey = note.noteSerializer.settings.modifiedKey;

      var newSimplified = note.data.copyWith(
        props: note.data.props.remove(modifiedKey),
        body: note.body.trim(),
      );
      var originalSimplified = _originalNoteData.copyWith(
        props: _originalNoteData.props.remove(modifiedKey),
        body: _originalNoteData.body.trim(),
      );

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
    assert(note.oid.isEmpty);

    if (!_noteModified(note)) return true;

    Log.d("Note modified - saving");
    try {
      var repo = context.read<GitJournalRepo>();
      if (_isNewNote && !_newNoteRenamed) {
        if (note.shouldRebuildPath) {
          Log.d("Rebuilding Note's FileName");
          note = note.copyWithFileName(note.rebuildFileName());
          setState(() {
            _note = note;
          });
        }
        await repo.addNote(note).throwOnError();
      } else {
        var originalNote = widget.existingNote!;
        var modifiedNote =
            await repo.updateNote(originalNote, note).getOrThrow();
        setState(() {
          _note = modifiedNote;
        });
      }
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

  EditorState? _getEditorState() {
    switch (_editorType) {
      case EditorType.Markdown:
        return _markdownEditorKey.currentState;
      case EditorType.Raw:
        return _rawEditorKey.currentState;
      case EditorType.Checklist:
        return _checklistEditorKey.currentState;
      case EditorType.Journal:
        return _journalEditorKey.currentState;
      case EditorType.Org:
        return _orgEditorKey.currentState;
    }
  }

  Note? _getNoteFromEditor() => _getEditorState()?.getNote();

  @override
  Future<void> moveNoteToFolderSelected(Note note) async {
    assert(note.oid.isEmpty);

    var destFolder = await showDialog<NotesFolderFS>(
      context: context,
      builder: (context) => FolderSelectionDialog(),
    );
    if (destFolder != null) {
      if (_isNewNote) {
        setState(() {
          _note = note.copyWith(parent: destFolder);
        });
      } else {
        var stateContainer = context.read<GitJournalRepo>();
        var r = await stateContainer.moveNote(note, destFolder);
        if (r.isFailure) {
          showResultError(context, r);
          return;
        }

        setState(() {
          _note = r.getOrThrow();
        });
      }
    }
  }

  @override
  Future<void> discardChanges(Note note) async {
    assert(note.oid.isEmpty);

    if (!_isNewNote) {
      var stateContainer = context.read<GitJournalRepo>();
      stateContainer.discardChanges(note);
    }

    Navigator.pop(context);
  }

  @override
  Future<void> editTags(Note note) async {
    assert(note.oid.isEmpty);

    final rootFolder = Provider.of<NotesFolderFS>(context, listen: false);
    var inlineTagsView = InlineTagsProvider.of(context, listen: false);
    var allTags = await rootFolder.getNoteTagsRecursively(inlineTagsView);

    var route = MaterialPageRoute(
      builder: (context) => NoteTagEditor(
        selectedTags: note.tags,
        allTags: allTags,
      ),
      settings: const RouteSettings(name: '/editTags/'),
    );

    var resp = await Navigator.of(context).push(route);
    assert(resp != null);
    var newTags = resp as ISet<String>;

    if (note.tags != newTags) {
      setState(() {
        Log.i("Settings tags to: $newTags");
        _note = note.copyWith(tags: newTags);
      });
    }
  }
}
