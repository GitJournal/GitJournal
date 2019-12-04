import 'package:flutter/material.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/widgets/journal_editor_header.dart';
import 'package:gitjournal/storage/serializers.dart';

enum NoteEditorDropDownChoices { Discard, SwitchEditor }

class JournalEditor extends StatefulWidget {
  final Note note;
  final NotesFolder notesFolder;

  JournalEditor.fromNote(this.note) : notesFolder = null;
  JournalEditor.newNote(this.notesFolder) : note = null;

  @override
  JournalEditorState createState() {
    if (note == null) {
      return JournalEditorState.newNote(notesFolder);
    } else {
      return JournalEditorState.fromNote(note);
    }
  }
}

class JournalEditorState extends State<JournalEditor> {
  Note note;
  final bool newNote;
  TextEditingController _textController = TextEditingController();
  bool rawEditor = false;
  final serializer = MarkdownYAMLSerializer();

  JournalEditorState.newNote(NotesFolder folder) : newNote = true {
    note = Note(folder);
    note.created = DateTime.now();
  }

  JournalEditorState.fromNote(this.note) : newNote = false {
    _textController = TextEditingController(text: note.body);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget editor = Column(
      children: <Widget>[
        JournalEditorHeader(note),
        NoteMarkdownEditor(_textController, false),
      ],
    );
    if (rawEditor) {
      editor = NoteMarkdownEditor(_textController, true);
    }

    var title = newNote ? "Journal Entry" : "Edit Journal Entry";
    var newJournalScreen = Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          key: const ValueKey("NewEntry"),
          icon: Icon(Icons.check),
          onPressed: () {
            _saveNote(context);
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          PopupMenuButton<NoteEditorDropDownChoices>(
            onSelected: (NoteEditorDropDownChoices choice) {
              switch (choice) {
                case NoteEditorDropDownChoices.Discard:
                  if (_noteModified()) {
                    showDialog(context: context, builder: _buildAlertDialog);
                  } else {
                    Navigator.pop(context);
                  }
                  break;
                case NoteEditorDropDownChoices.SwitchEditor:
                  setState(() {
                    if (rawEditor) {
                      rawEditor = false;
                      note.data = serializer.decode(_textController.text);
                      _textController.text = note.body;
                    } else {
                      rawEditor = true;
                      var noteData =
                          NoteData(_textController.text, note.data.props);
                      _textController.text = serializer.encode(noteData);
                    }
                  });
                  break;
              }
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<NoteEditorDropDownChoices>>[
              const PopupMenuItem<NoteEditorDropDownChoices>(
                value: NoteEditorDropDownChoices.Discard,
                child: Text('Discard'),
              ),
              PopupMenuItem<NoteEditorDropDownChoices>(
                value: NoteEditorDropDownChoices.SwitchEditor,
                child: rawEditor
                    ? const Text('Rich Editor')
                    : const Text('Raw Editor'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: editor,
        ),
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        _saveNote(context);
        return true;
      },
      child: newJournalScreen,
    );
  }

  Widget _buildAlertDialog(BuildContext context) {
    var title = newNote
        ? "Do you want to discard this?"
        : "Do you want to ignore the changes?";

    var editText = newNote ? "Keep Writing" : "Keep Editing";
    var discardText = newNote ? "Discard" : "Discard Changes";

    return AlertDialog(
      title: Text(title),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(editText),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pop(context); // Alert box
            Navigator.pop(context); // Note Editor
          },
          child: Text(discardText),
        ),
      ],
    );
  }

  bool _noteModified() {
    var noteContent = _textController.text.trim();
    if (noteContent.isEmpty) {
      return false;
    }
    if (note != null) {
      if (rawEditor) {
        return serializer.encode(note.data) != noteContent;
      } else {
        return noteContent != note.body;
      }
    }

    return false;
  }

  void _saveNote(BuildContext context) {
    if (!_noteModified()) return;

    final stateContainer = StateContainer.of(context);
    if (rawEditor == false) {
      note.body = _textController.text;
    } else {
      note.data = serializer.decode(_textController.text);
    }
    if (!note.isEmpty()) {
      newNote ? stateContainer.addNote(note) : stateContainer.updateNote(note);
    }
  }
}

class NoteMarkdownEditor extends StatelessWidget {
  final TextEditingController textController;
  final bool useMonospace;

  NoteMarkdownEditor(this.textController, this.useMonospace);

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.subhead;
    if (useMonospace) {
      style = style.copyWith(fontFamily: "Roboto Mono");
    }

    return Form(
      child: TextFormField(
        autofocus: true,
        autocorrect: false,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        style: style,
        decoration: InputDecoration(
          hintText: 'Write here',
          border: InputBorder.none,
        ),
        controller: textController,
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }
}
