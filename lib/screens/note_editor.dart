import 'package:flutter/material.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/md_yaml_doc.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/editors/journal_editor.dart';
import 'package:gitjournal/editors/markdown_editor.dart';
import 'package:gitjournal/editors/raw_editor.dart';
import 'package:gitjournal/editors/checklist_editor.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/widgets/folder_selection_dialog.dart';
import 'package:gitjournal/widgets/note_editor_selector.dart';
import 'package:gitjournal/widgets/rename_dialog.dart';
import 'package:provider/provider.dart';

class ShowUndoSnackbar {}

class NoteEditor extends StatefulWidget {
  final Note note;
  final NotesFolderFS notesFolder;
  final EditorType defaultEditorType;

  NoteEditor.fromNote(this.note)
      : notesFolder = note.parent,
        defaultEditorType = null;
  NoteEditor.newNote(this.notesFolder, this.defaultEditorType) : note = null;

  @override
  NoteEditorState createState() {
    if (note == null) {
      return NoteEditorState.newNote(notesFolder);
    } else {
      return NoteEditorState.fromNote(note);
    }
  }
}

enum EditorType { Markdown, Raw, Checklist, Journal }

class NoteEditorState extends State<NoteEditor> {
  Note note;
  EditorType editorType = EditorType.Markdown;
  MdYamlDoc originalNoteData = MdYamlDoc();

  final _rawEditorKey = GlobalKey<RawEditorState>();
  final _markdownEditorKey = GlobalKey<MarkdownEditorState>();
  final _checklistEditorKey = GlobalKey<ChecklistEditorState>();
  final _journalEditorKey = GlobalKey<JournalEditorState>();

  bool get _isNewNote {
    return widget.note == null;
  }

  NoteEditorState.newNote(NotesFolderFS folder) {
    note = Note.newNote(folder);
  }

  NoteEditorState.fromNote(this.note) {
    originalNoteData = MdYamlDoc.from(note.data);
  }

  @override
  void initState() {
    super.initState();
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
        case NoteType.Unknown:
          editorType = widget.notesFolder.config.defaultEditor;
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _saveNote(_getNoteFromEditor());
        return true;
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
          noteDeletionSelected: _noteDeletionSelected,
          noteEditorChooserSelected: _noteEditorChooserSelected,
          exitEditorSelected: _exitEditorSelected,
          renameNoteSelected: _renameNoteSelected,
          moveNoteToFolderSelected: _moveNoteToFolderSelected,
          discardChangesSelected: _discardChangesSelected,
          autofocusOnEditor: _isNewNote,
        );
      case EditorType.Raw:
        return RawEditor(
          key: _rawEditorKey,
          note: note,
          noteDeletionSelected: _noteDeletionSelected,
          noteEditorChooserSelected: _noteEditorChooserSelected,
          exitEditorSelected: _exitEditorSelected,
          renameNoteSelected: _renameNoteSelected,
          moveNoteToFolderSelected: _moveNoteToFolderSelected,
          discardChangesSelected: _discardChangesSelected,
          autofocusOnEditor: _isNewNote,
        );
      case EditorType.Checklist:
        return ChecklistEditor(
          key: _checklistEditorKey,
          note: note,
          noteDeletionSelected: _noteDeletionSelected,
          noteEditorChooserSelected: _noteEditorChooserSelected,
          exitEditorSelected: _exitEditorSelected,
          renameNoteSelected: _renameNoteSelected,
          moveNoteToFolderSelected: _moveNoteToFolderSelected,
          discardChangesSelected: _discardChangesSelected,
          autofocusOnEditor: _isNewNote,
        );
      case EditorType.Journal:
        return JournalEditor(
          key: _journalEditorKey,
          note: note,
          noteDeletionSelected: _noteDeletionSelected,
          noteEditorChooserSelected: _noteEditorChooserSelected,
          exitEditorSelected: _exitEditorSelected,
          renameNoteSelected: _renameNoteSelected,
          moveNoteToFolderSelected: _moveNoteToFolderSelected,
          discardChangesSelected: _discardChangesSelected,
          autofocusOnEditor: _isNewNote,
        );
    }
    return null;
  }

  void _noteEditorChooserSelected(Note _note) async {
    var newEditorType = await showDialog<EditorType>(
      context: context,
      builder: (BuildContext context) {
        return NoteEditorSelector(editorType);
      },
    );

    if (newEditorType != null) {
      setState(() {
        note = _note;
        editorType = newEditorType;
      });
    }
  }

  void _exitEditorSelected(Note note) {
    _saveNote(note);
    Navigator.pop(context);
  }

  void _renameNoteSelected(Note _note) async {
    var fileName = await showDialog(
      context: context,
      builder: (_) => RenameDialog(
        oldPath: note.filePath,
        inputDecoration: 'File Name',
        dialogTitle: "Rename File",
      ),
    );
    if (fileName is String) {
      if (_isNewNote) {
        setState(() {
          note = _note;
          note.rename(fileName);
        });
      }
      var container = Provider.of<StateContainer>(context, listen: false);
      container.renameNote(note, fileName);
    }
  }

  void _noteDeletionSelected(Note note) {
    if (_isNewNote && !_noteModified(note)) {
      Navigator.pop(context);
      return;
    }

    showDialog(context: context, builder: _buildAlertDialog);
  }

  void _deleteNote(Note note) {
    if (_isNewNote) {
      return;
    }

    var stateContainer = Provider.of<StateContainer>(context, listen: false);
    stateContainer.removeNote(note);
  }

  Widget _buildAlertDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Do you want to delete this note?'),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Keep Writing'),
        ),
        FlatButton(
          onPressed: () {
            _deleteNote(note);

            Navigator.pop(context); // Alert box

            if (_isNewNote) {
              Navigator.pop(context); // Note Editor
            } else {
              Navigator.pop(context, ShowUndoSnackbar()); // Note Editor
            }
          },
          child: const Text('Delete'),
        ),
      ],
    );
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
        print("Note modified");
        print("Original: $originalNoteData");
        print("New: $newSimplified");
        return true;
      }
    }
    return false;
  }

  void _saveNote(Note note) {
    if (!_noteModified(note)) return;

    print("Note modified - saving");
    var stateContainer = Provider.of<StateContainer>(context, listen: false);
    _isNewNote ? stateContainer.addNote(note) : stateContainer.updateNote(note);
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
    }
    return null;
  }

  void _moveNoteToFolderSelected(Note note) async {
    var destFolder = await showDialog<NotesFolderFS>(
      context: context,
      builder: (context) => FolderSelectionDialog(),
    );
    if (destFolder != null) {
      var stateContainer = Provider.of<StateContainer>(context, listen: false);
      stateContainer.moveNote(note, destFolder);
    }
  }

  void _discardChangesSelected(Note note) {
    if (_noteModified(note)) {
      showDialog(context: context, builder: _buildDiscardChangesAlertDialog);
    } else {
      Navigator.pop(context);
    }
  }

  Widget _buildDiscardChangesAlertDialog(BuildContext context) {
    var title = _isNewNote
        ? "Do you want to discard this?"
        : "Do you want to ignore the changes?";

    var editText = _isNewNote ? "Keep Writing" : "Keep Editing";
    var discardText = _isNewNote ? "Discard" : "Discard Changes";

    return AlertDialog(
      title: Text(title),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(editText),
        ),
        FlatButton(
          onPressed: () {
            // FIXME: This shouldn't be required. Why is the original note modified?
            note.data = originalNoteData;

            Navigator.pop(context); // Alert box
            Navigator.pop(context); // Note Editor
          },
          child: Text(discardText),
        ),
      ],
    );
  }
}
