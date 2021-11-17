/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:time/time.dart';

import 'package:gitjournal/core/checklist.dart';
import 'package:gitjournal/core/image.dart' as core;
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/editors/note_title_editor.dart';
import 'package:gitjournal/editors/utils/disposable_change_notifier.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'controllers/rich_text_controller.dart';

class ChecklistEditor extends StatefulWidget implements Editor {
  final Note note;
  final bool noteModified;

  @override
  final EditorCommon common;

  final bool editMode;
  final String? highlightString;
  final ThemeData theme;

  const ChecklistEditor({
    Key? key,
    required this.note,
    required this.noteModified,
    required this.editMode,
    required this.highlightString,
    required this.theme,
    required this.common,
  }) : super(key: key);

  @override
  ChecklistEditorState createState() {
    return ChecklistEditorState();
  }
}

class ChecklistEditorState extends State<ChecklistEditor>
    with DisposableChangeNotifier
    implements EditorState {
  late Checklist checklist;
  var focusNodes = <UniqueKey, FocusScopeNode>{};
  var keys = <UniqueKey, ChecklistItem>{};

  late TextEditingController _titleTextController;
  late bool _noteModified;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    var note = widget.note;
    _titleTextController = buildController(
      text: note.title,
      highlightText: widget.highlightString,
      theme: widget.theme,
    );
    checklist = Checklist(note);

    _noteModified = widget.noteModified;

    if (checklist.items.isEmpty) {
      var item = checklist.buildItem(false, "");
      checklist.addItem(item);
    }
    focusNodes = {};
    keys = {};
    for (var item in checklist.items) {
      keys[UniqueKey()] = item;
    }
  }

  @override
  void didUpdateWidget(ChecklistEditor oldWidget) {
    if (oldWidget.noteModified != widget.noteModified) {
      _noteModified = widget.noteModified;
    }
    if (oldWidget.note != widget.note) {
      _init();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _titleTextController.dispose();

    super.disposeListenables();
    super.dispose();
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
      startingNote: widget.note,
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
      findAllowed: false,
    );
  }

  @override
  Note getNote() {
    // Remove trailing empty items
    while (checklist.items.isNotEmpty) {
      var last = checklist.items.last;
      if (last.checked == false && last.text.trim().isEmpty) {
        var _ = checklist.removeAt(checklist.items.length - 1);
      } else {
        break;
      }
    }

    var note = checklist.note;
    note.apply(
      title: _titleTextController.text.trim(),
      type: NoteType.Checklist,
    );
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
      statusChanged: (bool? newVal) {
        setState(() {
          if (newVal != null) {
            item.checked = newVal;
          }
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

          FocusNode? fn;
          if (nextIndex >= 0) {
            var nextItemForFocus = checklist.items[nextIndex];
            fn = _getFn(nextItemForFocus);
          }

          var k = _getKey(item);
          dynamic _;
          _ = focusNodes.remove(k);
          _ = keys.remove(k);
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
            FocusScope.of(context).requestFocus();
            FocusScope.of(context).requestFocus(fn);
          });
        });
      },
      theme: widget.theme,
      highlightString: widget.highlightString,
    );
  }

  @override
  Future<void> addImage(String filePath) async {
    var note = getNote();
    var image = await core.Image.copyIntoFs(note.parent, filePath);
    note.apply(body: note.body + image.toMarkup(note.fileFormat));

    setState(() {
      checklist = Checklist(note);
      _noteModified = true;
    });
  }

  @override
  bool get noteModified => _noteModified;

  Future<void> _undo() async {}

  Future<void> _redo() async {}

  @override
  SearchInfo search(String? text) {
    throw UnimplementedError();
  }

  @override
  void scrollToResult(String text, int num) {
    throw UnimplementedError();
  }
}

typedef TextChangedFunction = void Function(String);
typedef StatusChangedFunction = void Function(bool?);

class ChecklistItemTile extends StatefulWidget {
  final ChecklistItem item;
  final StatusChangedFunction statusChanged;
  final TextChangedFunction textChanged;
  final void Function() itemRemoved;
  final void Function() itemFinished;
  final FocusNode focusNode;
  final bool autofocus;

  final String? highlightString;
  final ThemeData theme;

  const ChecklistItemTile({
    Key? key,
    required this.item,
    required this.statusChanged,
    required this.textChanged,
    required this.itemRemoved,
    required this.itemFinished,
    required this.focusNode,
    this.autofocus = false,
    required this.highlightString,
    required this.theme,
  }) : super(key: key);

  @override
  _ChecklistItemTileState createState() => _ChecklistItemTileState();
}

class _ChecklistItemTileState extends State<ChecklistItemTile> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = buildController(
      text: widget.item.text,
      highlightText: widget.highlightString,
      theme: widget.theme,
    );
    _textController.addListener(() {
      widget.textChanged(_textController.value.text);
    });
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
      style = style!.copyWith(
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
          const SizedBox(
            height: 24.0,
            width: 24.0,
            child: Icon(Icons.drag_handle),
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
  final void Function() onPressed;

  const AddItemButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.subtitle1;

    var tile = ListTile(
      dense: true,
      leading: Row(
        children: <Widget>[
          const SizedBox(height: 24.0, width: 24.0),
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
      title: Text(tr(LocaleKeys.editors_checklist_add), style: style),
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
