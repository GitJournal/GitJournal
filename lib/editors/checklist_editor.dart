import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:time/time.dart';

import 'package:gitjournal/core/checklist.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/editors/disposable_change_notifier.dart';
import 'package:gitjournal/editors/note_title_editor.dart';

class ChecklistEditor extends StatefulWidget implements Editor {
  final Note note;
  final bool noteModified;

  @override
  final NoteCallback noteDeletionSelected;
  @override
  final NoteCallback noteEditorChooserSelected;
  @override
  final NoteCallback exitEditorSelected;
  @override
  final NoteCallback renameNoteSelected;
  @override
  final NoteCallback editTagsSelected;
  @override
  final NoteCallback moveNoteToFolderSelected;
  @override
  final NoteCallback discardChangesSelected;

  final bool editMode;

  ChecklistEditor({
    Key key,
    @required this.note,
    @required this.noteModified,
    @required this.noteDeletionSelected,
    @required this.noteEditorChooserSelected,
    @required this.exitEditorSelected,
    @required this.renameNoteSelected,
    @required this.editTagsSelected,
    @required this.moveNoteToFolderSelected,
    @required this.discardChangesSelected,
    @required this.editMode,
  }) : super(key: key);

  @override
  ChecklistEditorState createState() {
    return ChecklistEditorState(note);
  }
}

class ChecklistEditorState extends State<ChecklistEditor>
    with DisposableChangeNotifier
    implements EditorState {
  Checklist checklist;
  var focusNodes = <UniqueKey, FocusScopeNode>{};
  var keys = <UniqueKey, ChecklistItem>{};

  TextEditingController _titleTextController = TextEditingController();
  bool _noteModified;

  ChecklistEditorState(Note note) {
    _titleTextController = TextEditingController(text: note.title);
    checklist = Checklist(note);
  }

  @override
  void initState() {
    super.initState();
    _noteModified = widget.noteModified;

    if (checklist.items.isEmpty) {
      var item = checklist.buildItem(false, "");
      checklist.addItem(item);
    }
    for (var item in checklist.items) {
      keys[UniqueKey()] = item;
    }
  }

  @override
  void dispose() {
    _titleTextController.dispose();

    super.disposeListenables();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChecklistEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.noteModified != widget.noteModified) {
      _noteModified = widget.noteModified;
    }
  }

  UniqueKey _getKey(ChecklistItem item) {
    for (var e in keys.entries) {
      if (e.value == item) {
        return e.key;
      }
    }

    var key = UniqueKey();
    keys[key] = item;
    return key;
  }

  FocusScopeNode _getFn(ChecklistItem item) {
    var key = _getKey(item);

    var fn = focusNodes[key];
    if (fn == null) {
      fn = FocusScopeNode();
      focusNodes[key] = fn;
    }
    return fn;
  }

  @override
  Widget build(BuildContext context) {
    var itemTiles = <Widget>[];
    for (var i = 0; i < checklist.items.length; i++) {
      var item = checklist.items[i];
      var autofocus = widget.editMode && (i == checklist.items.length - 1);
      itemTiles.add(_buildTile(item, i, autofocus));
    }
    itemTiles.add(AddItemButton(
      key: UniqueKey(),
      onPressed: () {
        _noteTextChanged();
        setState(() {
          var item = checklist.buildItem(false, "");
          var fn = _getFn(item);

          checklist.addItem(item);

          // FIXME: Make this happen on the next build
          Timer(50.milliseconds, () {
            FocusScope.of(context).requestFocus();
            FocusScope.of(context).requestFocus(fn);
          });
        });
      },
    ));

    Widget checklistWidget = ReorderableListView(
      children: itemTiles,
      onReorder: (int oldIndex, int newIndex) {
        _noteTextChanged();
        setState(() {
          var item = checklist.removeAt(oldIndex);

          if (newIndex > oldIndex) {
            checklist.insertItem(newIndex - 1, item);
          } else {
            checklist.insertItem(newIndex, item);
          }
        });
      },
    );

    var titleEditor = Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: NoteTitleEditor(_titleTextController, _noteTextChanged),
    );

    return EditorScaffold(
      editor: widget,
      editorState: this,
      noteModified: _noteModified,
      editMode: widget.editMode,
      parentFolder: widget.note.parent,
      body: Column(
        children: <Widget>[
          titleEditor,
          Expanded(child: FocusScope(child: checklistWidget)),
        ],
      ),
      onUndoSelected: _undo,
      onRedoSelected: _redo,
      undoAllowed: false,
      redoAllowed: false,
    );
  }

  @override
  Note getNote() {
    // Remove trailing empty items
    while (checklist.items.isNotEmpty) {
      var last = checklist.items.last;
      if (last.checked == false && last.text.trim().isEmpty) {
        checklist.removeAt(checklist.items.length - 1);
      } else {
        break;
      }
    }

    var note = checklist.note;
    note.title = _titleTextController.text.trim();
    note.type = NoteType.Checklist;
    return note;
  }

  void _noteTextChanged() {
    notifyListeners();

    if (_noteModified) return;
    setState(() {
      _noteModified = true;
    });
  }

  ChecklistItemTile _buildTile(ChecklistItem item, int index, bool autofocus) {
    return ChecklistItemTile(
      key: UniqueKey(),
      item: item,
      focusNode: _getFn(item),
      autofocus: autofocus,
      statusChanged: (bool newVal) {
        setState(() {
          item.checked = newVal;
        });
        _noteTextChanged();
      },
      textChanged: (String newVal) {
        item.text = newVal;
        _noteTextChanged();
      },
      itemRemoved: () {
        _noteTextChanged();
        setState(() {
          // Give next item the focus
          var nextIndex = index + 1;
          if (index >= checklist.items.length - 1) {
            nextIndex = index - 1;
          }
          print("Next focus index $nextIndex");

          FocusNode fn;
          if (nextIndex >= 0) {
            var nextItemForFocus = checklist.items[nextIndex];
            fn = _getFn(nextItemForFocus);
            print("Giving focus to $nextItemForFocus");
          }

          var k = _getKey(item);
          focusNodes.remove(k);
          keys.remove(k);
          checklist.removeItem(item);

          // FIXME: Make this happen on the next build
          Timer(200.milliseconds, () {
            if (fn != null) {
              FocusScope.of(context).requestFocus();
              FocusScope.of(context).requestFocus(fn);
            }
          });
        });
      },
      itemFinished: () {
        _noteTextChanged();
        setState(() {
          var item = checklist.buildItem(false, "");
          var fn = _getFn(item);
          checklist.insertItem(index + 1, item);

          // FIXME: Make this happen on the next build
          Timer(50.milliseconds, () {
            print("Asking focus to ${index + 1}");
            FocusScope.of(context).requestFocus();
            FocusScope.of(context).requestFocus(fn);
          });
        });
      },
    );
  }

  @override
  Future<void> addImage(File file) async {
    var note = getNote();
    await note.addImage(file);

    setState(() {
      checklist = Checklist(note);
      _noteModified = true;
    });
  }

  @override
  bool get noteModified => _noteModified;

  Future<void> _undo() async {}

  Future<void> _redo() async {}
}

typedef TextChangedFunction = void Function(String);
typedef StatusChangedFunction = void Function(bool);

class ChecklistItemTile extends StatefulWidget {
  final ChecklistItem item;
  final StatusChangedFunction statusChanged;
  final TextChangedFunction textChanged;
  final Function itemRemoved;
  final Function itemFinished;
  final FocusNode focusNode;
  final bool autofocus;

  ChecklistItemTile({
    Key key,
    @required this.item,
    @required this.statusChanged,
    @required this.textChanged,
    @required this.itemRemoved,
    @required this.itemFinished,
    @required this.focusNode,
    this.autofocus = false,
  }) : super(key: key);

  @override
  _ChecklistItemTileState createState() => _ChecklistItemTileState();
}

class _ChecklistItemTileState extends State<ChecklistItemTile> {
  TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.item.text);
    _textController.addListener(() {
      widget.textChanged(_textController.value.text);
    });
    assert(widget.focusNode != null);
    widget.focusNode.addListener(_onFocus);
  }

  @override
  void dispose() {
    _textController.dispose();
    widget.focusNode.removeListener(_onFocus);

    super.dispose();
  }

  void _onFocus() {
    setState(() {}); // rebuild to show/hide close button
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.subtitle1;
    if (widget.item.checked) {
      style = style.copyWith(
        decoration: TextDecoration.lineThrough,
        color: theme.disabledColor,
      );
    }

    var editor = TextField(
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      keyboardType: TextInputType.text,
      maxLines: null,
      style: style,
      textCapitalization: TextCapitalization.sentences,
      controller: _textController,
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
      ),
      onEditingComplete: widget.itemFinished,
    );

    return ListTile(
      dense: true,
      leading: Row(
        children: <Widget>[
          Container(
            height: 24.0,
            width: 24.0,
            child: const Icon(Icons.drag_handle),
          ),
          const SizedBox(width: 8.0),
          SizedBox(
            height: 24.0,
            width: 24.0,
            child: Checkbox(
              value: widget.item.checked,
              onChanged: widget.statusChanged,
            ),
          ),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
      title: editor,
      trailing: IconButton(
        icon: Icon(widget.focusNode.hasFocus ? Icons.clear : null),
        onPressed: widget.itemRemoved,
      ),
      enabled: !widget.item.checked,
    );
  }
}

class AddItemButton extends StatelessWidget {
  final Function onPressed;

  AddItemButton({Key key, @required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.subtitle1;

    var tile = ListTile(
      dense: true,
      leading: Row(
        children: <Widget>[
          Container(height: 24.0, width: 24.0),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.all(0.0),
            width: 24.0,
            child: IconButton(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              icon: const Icon(Icons.add),
              onPressed: onPressed,
            ),
          ),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
      title: Text(tr("editors.checklist.add"), style: style),
    );

    return GestureDetector(
      onTap: onPressed,
      child: tile,
    );
  }
}

// FIXME: The body needs to be scrollable
// FIXME: Support removing an item when pressing backspace
// FIXME: Align the checkbox and close button on top
// FIXME: Move checked items to the bottom?
