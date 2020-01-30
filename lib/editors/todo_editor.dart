import 'package:flutter/material.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/editors/common.dart';

class TodoEditor extends StatefulWidget implements Editor {
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

  TodoEditor({
    Key key,
    @required this.note,
    @required this.noteDeletionSelected,
    @required this.noteEditorChooserSelected,
    @required this.exitEditorSelected,
    @required this.renameNoteSelected,
    @required this.moveNoteToFolderSelected,
  }) : super(key: key);

  @override
  TodoEditorState createState() {
    return TodoEditorState(note);
  }
}

class TodoEditorState extends State<TodoEditor> implements EditorState {
  Note note;
  List<TodoItem> todos;
  TextEditingController _titleTextController = TextEditingController();

  TodoEditorState(this.note) {
    _titleTextController = TextEditingController(text: note.title);

    todos = [
      TodoItem(false, "First Item"),
      TodoItem(true, "Second Item"),
      TodoItem(false, "Third Item"),
    ];
  }

  @override
  void dispose() {
    _titleTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var todoItemTiles = <TodoItemTile>[];
    todos.forEach((TodoItem todo) {
      todoItemTiles.add(_buildTile(todo));
    });

    print("Building " + todos.toString());
    Widget todoList = ReorderableListView(
      children: todoItemTiles,
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          var item = todos.removeAt(oldIndex);

          if (newIndex > oldIndex) {
            todos.insert(newIndex - 1, item);
          } else {
            todos.insert(newIndex, item);
          }
        });
      },
    );

    var titleEditor = Padding(
      padding: const EdgeInsets.all(16.0),
      child: _NoteTitleEditor(_titleTextController),
    );

    return Scaffold(
      appBar: buildEditorAppBar(widget, this),
      floatingActionButton: buildFAB(widget, this),
      body: Column(
        children: <Widget>[titleEditor, Expanded(child: todoList)],
      ),
    );
  }

  @override
  Note getNote() {
    note.title = _titleTextController.text.trim();
    return note;
  }

  TodoItemTile _buildTile(TodoItem todo) {
    return TodoItemTile(
      key: UniqueKey(),
      todo: todo,
      statusChanged: (val) {
        setState(() {
          todo.checked = val;
        });
      },
      todoRemoved: () {
        setState(() {
          // FIXME: The body isn't a good indicator, there could be multiple with the same body!
          todos.removeWhere((t) => t.body == todo.body);
        });
      },
    );
  }
}

class _NoteTitleEditor extends StatelessWidget {
  final TextEditingController textController;

  _NoteTitleEditor(this.textController);

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.title;

    return TextField(
      keyboardType: TextInputType.text,
      maxLines: 1,
      style: style,
      decoration: const InputDecoration(
        hintText: 'Title',
        border: InputBorder.none,
        isDense: true,
      ),
      controller: textController,
      textCapitalization: TextCapitalization.sentences,
    );
  }
}

class TodoItem {
  bool checked;
  String body;

  TodoItem(this.checked, this.body);

  @override
  String toString() {
    return 'TodoItem($checked, "$body")';
  }
}

class TodoItemTile extends StatefulWidget {
  final TodoItem todo;
  final Function statusChanged;
  final Function todoRemoved;

  TodoItemTile({
    Key key,
    @required this.todo,
    @required this.statusChanged,
    @required this.todoRemoved,
  }) : super(key: key);

  @override
  _TodoItemTileState createState() => _TodoItemTileState();
}

class _TodoItemTileState extends State<TodoItemTile> {
  TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.todo.body);
  }

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.subhead;

    var editor = TextField(
      keyboardType: TextInputType.text,
      maxLines: 1,
      style: style,
      textCapitalization: TextCapitalization.sentences,
      controller: _textController,
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
      ),
    );

    return ListTile(
      leading: Row(
        children: <Widget>[
          Container(height: 24.0, width: 24.0, child: Icon(Icons.reorder)),
          Checkbox(
            value: widget.todo.checked,
            onChanged: widget.statusChanged,
          ),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
      title: editor,
      trailing: IconButton(
        icon: Icon(Icons.cancel),
        onPressed: widget.todoRemoved,
      ),
      dense: true,
    );
  }
}

// FIXME: The body needs to be scrollable
// FIXME: Add a new todo button
// FIXME: Fix padding issue with todo items
// FIXME: Only show 'x' when active
