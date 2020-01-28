import 'package:flutter/material.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/note_data_serializers.dart';

typedef NoteCallback = void Function(Note);
enum DropDownChoices { Rename }

class RawEditor extends StatefulWidget {
  final Note note;
  final NoteCallback noteDeletionSelected;
  final NoteCallback noteEditorChooserSelected;
  final NoteCallback exitEditorSelected;
  final NoteCallback renameNoteSelected;

  RawEditor({
    Key key,
    @required this.note,
    @required this.noteDeletionSelected,
    @required this.noteEditorChooserSelected,
    @required this.exitEditorSelected,
    @required this.renameNoteSelected,
  }) : super(key: key);

  @override
  RawEditorState createState() {
    return RawEditorState(note);
  }
}

class RawEditorState extends State<RawEditor> {
  Note note;
  TextEditingController _textController = TextEditingController();

  final serializer = MarkdownYAMLSerializer();

  RawEditorState(this.note) {
    _textController = TextEditingController(text: serializer.encode(note.data));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var editor = Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: _NoteEditor(_textController),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const ValueKey("NewEntry"),
          icon: const Icon(Icons.check),
          onPressed: () {
            _updateNote();
            widget.exitEditorSelected(note);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.library_books),
            onPressed: () {
              _updateNote();
              widget.noteEditorChooserSelected(note);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _updateNote();
              widget.noteDeletionSelected(note);
            },
          ),
          PopupMenuButton<DropDownChoices>(
            onSelected: (DropDownChoices choice) {
              _updateNote();
              widget.renameNoteSelected(note);
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<DropDownChoices>>[
              const PopupMenuItem<DropDownChoices>(
                value: DropDownChoices.Rename,
                child: Text('Edit File Name'),
              ),
            ],
          ),
        ],
      ),
      body: editor,
    );
  }

  void _updateNote() {
    note.data = serializer.decode(_textController.text);
  }

  Note getNote() {
    _updateNote();
    return note;
  }
}

class _NoteEditor extends StatelessWidget {
  final TextEditingController textController;

  _NoteEditor(this.textController);

  @override
  Widget build(BuildContext context) {
    var style =
        Theme.of(context).textTheme.subhead.copyWith(fontFamily: "Roboto Mono");

    return TextField(
      autofocus: false,
      autocorrect: false,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      style: style,
      decoration: InputDecoration(
        hintText: 'Write here',
        border: InputBorder.none,
        isDense: true,
      ),
      controller: textController,
      textCapitalization: TextCapitalization.sentences,
      scrollPadding: const EdgeInsets.all(0.0),
    );
  }
}
