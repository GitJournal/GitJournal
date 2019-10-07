import 'package:flutter/material.dart';
import 'package:gitjournal/note.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/widgets/note_header.dart';
import 'package:gitjournal/storage/serializers.dart';

enum NoteEditorDropDownChoices { Discard, RawEditor }

class NoteEditor extends StatefulWidget {
  final Note note;

  NoteEditor() : note = null;
  NoteEditor.fromNote(this.note);

  @override
  NoteEditorState createState() {
    if (note == null) {
      return NoteEditorState();
    } else {
      return NoteEditorState.fromNote(note);
    }
  }
}

class NoteEditorState extends State<NoteEditor> {
  Note note = Note();
  final bool newNote;
  TextEditingController _textController = TextEditingController();
  bool rawEditor = false;
  final serializer = MarkdownYAMLSerializer();

  NoteEditorState() : newNote = true {
    note.created = DateTime.now();
  }

  NoteEditorState.fromNote(this.note) : newNote = false {
    _textController = TextEditingController(text: note.body);
  }

  @override
  Widget build(BuildContext context) {
    Widget editor = Column(
      children: <Widget>[
        NoteHeader(note),
        NoteMarkdownEditor(_textController),
      ],
    );
    if (rawEditor) {
      editor = NoteMarkdownEditor(_textController);
    }

    var title = newNote ? "Journal Entry" : "Edit Journal Entry";
    var newJournalScreen = Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          key: ValueKey("NewEntry"),
          icon: Icon(Icons.check),
          onPressed: () {
            final stateContainer = StateContainer.of(context);
            if (rawEditor == false) {
              note.body = _textController.text;
            } else {
              note.data = serializer.decode(_textController.text);
            }
            if (note.body.isNotEmpty) {
              newNote
                  ? stateContainer.addNote(note)
                  : stateContainer.updateNote(note);
            }
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
                case NoteEditorDropDownChoices.RawEditor:
                  setState(() {
                    rawEditor = true;
                    var noteData =
                        NoteData(_textController.text, note.data.props);
                    _textController.text = serializer.encode(noteData);
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
              const PopupMenuItem<NoteEditorDropDownChoices>(
                value: NoteEditorDropDownChoices.RawEditor,
                child: Text('RawEditor'),
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

    return newJournalScreen;
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
}

class NoteMarkdownEditor extends StatelessWidget {
  final TextEditingController textController;

  NoteMarkdownEditor(this.textController);

  @override
  Widget build(BuildContext context) {
    return Form(
      child: TextFormField(
        autofocus: true,
        keyboardType: TextInputType.multiline,
        maxLines: null,
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
