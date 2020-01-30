import 'package:flutter/material.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/note_data_serializers.dart';
import 'package:gitjournal/editors/common.dart';

class RawEditor extends StatefulWidget implements Editor {
  final Note note;

  @override
  final NoteCallback noteDeletionSelected;
  @override
  final NoteCallback noteEditorChooserSelected;
  @override
  final NoteCallback exitEditorSelected;
  @override
  final NoteCallback renameNoteSelected;
  @override
  final NoteCallback moveNoteToFolderSelected;

  RawEditor({
    Key key,
    @required this.note,
    @required this.noteDeletionSelected,
    @required this.noteEditorChooserSelected,
    @required this.exitEditorSelected,
    @required this.renameNoteSelected,
    @required this.moveNoteToFolderSelected,
  }) : super(key: key);

  @override
  RawEditorState createState() {
    return RawEditorState(note);
  }
}

class RawEditorState extends State<RawEditor> implements EditorState {
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
      appBar: buildEditorAppBar(widget, this),
      floatingActionButton: buildFAB(widget, this),
      body: editor,
    );
  }

  @override
  Note getNote() {
    note.data = serializer.decode(_textController.text);
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
