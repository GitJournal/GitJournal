/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:function_types/function_types.dart';

import 'package:gitjournal/core/note.dart';

export 'package:gitjournal/editors/scaffold.dart';

typedef NoteCallback = void Function(Note);

abstract class Editor {
  EditorCommon get common;
}

abstract class EditorCommon {
  void discardChanges(Note note);
  void renameNote(Note note);
  void editTags(Note note);
  void deleteNote(Note note);

  void noteEditorChooserSelected(Note note);
  void moveNoteToFolderSelected(Note note);
  void exitEditorSelected(Note note);
}

abstract class EditorState with ChangeNotifier {
  Note getNote();
  Future<void> addImage(String filePath);

  bool get noteModified;

  SearchInfo search(String? text);
  void scrollToResult(String text, int num);
}

class SearchInfo {
  final int numMatches;
  final double currentMatch;
  SearchInfo({this.numMatches = 0, this.currentMatch = 0});

  bool get isNotEmpty => numMatches != 0;
}

class TextEditorState {
  late String text;
  late int cursorPos;

  TextEditorState(this.text, this.cursorPos);

  TextEditorState.fromValue(TextEditingValue val) {
    text = val.text;
    cursorPos = val.selection.baseOffset;

    if (cursorPos == -1) {
      cursorPos = 0;
    }
  }

  TextEditingValue toValue() {
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursorPos),
    );
  }
}

class EditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Editor editor;
  final EditorState editorState;
  final bool noteModified;
  final IconButton? extraButton;
  final bool allowEdits;
  final Func0<void> onEditingModeChange;

  const EditorAppBar({
    Key? key,
    required this.editor,
    required this.editorState,
    required this.noteModified,
    required this.allowEdits,
    required this.onEditingModeChange,
    this.extraButton,
  })  : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        key: const ValueKey("NewEntry"),
        icon: Icon(noteModified ? Icons.check : Icons.close),
        onPressed: () {
          editor.common.exitEditorSelected(editorState.getNote());
        },
      ),
      actions: <Widget>[
        if (extraButton != null) extraButton!,
        IconButton(
          icon: allowEdits
              ? const Icon(Icons.remove_red_eye)
              : const Icon(Icons.edit),
          onPressed: onEditingModeChange,
        ),
        IconButton(
          key: const ValueKey("EditorSelector"),
          icon: const Icon(Icons.library_books),
          onPressed: () {
            var note = editorState.getNote();
            editor.common.noteEditorChooserSelected(note);
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            var note = editorState.getNote();
            editor.common.deleteNote(note);
          },
        ),
      ],
    );
  }
}

class EditorAppSearchBar extends StatefulWidget implements PreferredSizeWidget {
  final EditorState editorState;
  final Func0<void> onCloseSelected;

  final Func2<String, int, void> scrollToResult;

  const EditorAppSearchBar({
    Key? key,
    required this.editorState,
    required this.onCloseSelected,
    required this.scrollToResult,
  })  : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  State<EditorAppSearchBar> createState() => _EditorAppSearchBarState();
}

class _EditorAppSearchBarState extends State<EditorAppSearchBar> {
  var searchInfo = SearchInfo();
  var searchText = "";

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return AppBar(
      automaticallyImplyLeading: false,
      title: TextField(
        style: theme.textTheme.subtitle1,
        decoration: const InputDecoration(
          hintText: 'Find in Note',
          border: InputBorder.none,
        ),
        maxLines: 1,
        autofocus: true,
        onChanged: (String text) {
          var info = widget.editorState.search(text);
          setState(() {
            searchInfo = info;
            searchText = text;
          });

          widget.scrollToResult(searchText, searchInfo.currentMatch.round());
        },
      ),
      actions: [
        if (searchInfo.isNotEmpty)
          TextButton(
            child: Text(
              '${searchInfo.currentMatch.toInt() + 1}/${searchInfo.numMatches}',
              style: theme.textTheme.subtitle1,
            ),
            onPressed: null,
          ),
        // Disable these when not possible
        IconButton(
          icon: const Icon(Icons.arrow_upward),
          onPressed: searchInfo.isNotEmpty
              ? () {
                  setState(() {
                    var num = searchInfo.numMatches;
                    var prev = searchInfo.currentMatch;
                    prev = prev == 0 ? num - 1 : prev - 1;

                    searchInfo = SearchInfo(
                      currentMatch: prev,
                      numMatches: num,
                    );
                    widget.scrollToResult(
                        searchText, searchInfo.currentMatch.round());
                  });
                }
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.arrow_downward),
          onPressed: searchInfo.isNotEmpty
              ? () {
                  setState(() {
                    var num = searchInfo.numMatches;
                    var next = searchInfo.currentMatch;
                    next = next == num - 1 ? 0 : next + 1;

                    searchInfo = SearchInfo(
                      currentMatch: next,
                      numMatches: num,
                    );
                    widget.scrollToResult(
                        searchText, searchInfo.currentMatch.round());
                  });
                }
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCloseSelected,
        ),
      ],
      // It would be awesome if the scrollbar could also change
      // like how it is done in chrome
    );
  }
}
