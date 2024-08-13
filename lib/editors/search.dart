/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:function_types/function_types.dart';
import 'package:gitjournal/l10n.dart';

import 'common.dart';

class SearchInfo {
  final int numMatches;
  final double currentMatch;
  SearchInfo({this.numMatches = 0, this.currentMatch = 0});

  bool get isNotEmpty => numMatches != 0;

  static SearchInfo compute({required String body, required String? text}) {
    if (text == null) {
      return SearchInfo();
    }

    body = body.toLowerCase();
    text = text.toLowerCase();

    var matches = text.toLowerCase().allMatches(body).toList();
    return SearchInfo(numMatches: matches.length);

    // FIXME: Give the current match!!
  }
}

class EditorAppSearchBar extends StatefulWidget implements PreferredSizeWidget {
  final EditorState editorState;
  final Func0<void> onCloseSelected;

  final Func2<String, int, void> scrollToResult;

  const EditorAppSearchBar({
    super.key,
    required this.editorState,
    required this.onCloseSelected,
    required this.scrollToResult,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize;

  @override
  State<EditorAppSearchBar> createState() => _EditorAppSearchBarState();
}

class _EditorAppSearchBarState extends State<EditorAppSearchBar> {
  var _searchInfo = SearchInfo();
  var _searchText = "";

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return AppBar(
      automaticallyImplyLeading: false,
      title: TextField(
        focusNode: _focusNode,
        style: theme.textTheme.titleMedium,
        decoration: InputDecoration(
          hintText: context.loc.editorsCommonFind,
          border: InputBorder.none,
        ),
        maxLines: 1,
        onChanged: (String text) {
          var info = widget.editorState.search(text);
          setState(() {
            _searchInfo = info;
            _searchText = text;
          });

          widget.scrollToResult(_searchText, _searchInfo.currentMatch.round());
        },
      ),
      actions: [
        if (_searchInfo.isNotEmpty)
          TextButton(
            onPressed: null,
            child: Text(
              '${_searchInfo.currentMatch.toInt() + 1}/${_searchInfo.numMatches}',
              style: theme.textTheme.titleMedium,
            ),
          ),
        // Disable these when not possible
        IconButton(
          icon: const Icon(Icons.arrow_upward),
          onPressed: _searchInfo.isNotEmpty
              ? () {
                  setState(() {
                    var num = _searchInfo.numMatches;
                    var prev = _searchInfo.currentMatch;
                    prev = prev == 0 ? num - 1 : prev - 1;

                    _searchInfo = SearchInfo(
                      currentMatch: prev,
                      numMatches: num,
                    );
                    widget.scrollToResult(
                        _searchText, _searchInfo.currentMatch.round());
                  });
                }
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.arrow_downward),
          onPressed: _searchInfo.isNotEmpty
              ? () {
                  setState(() {
                    var num = _searchInfo.numMatches;
                    var next = _searchInfo.currentMatch;
                    next = next == num - 1 ? 0 : next + 1;

                    _searchInfo = SearchInfo(
                      currentMatch: next,
                      numMatches: num,
                    );
                    widget.scrollToResult(
                        _searchText, _searchInfo.currentMatch.round());
                  });
                }
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.editorState.search(null);
            widget.onCloseSelected();
          },
        ),
      ],
      // It would be awesome if the scrollbar could also change
      // like how it is done in chrome
    );
  }
}

int getSearchResultPosition(String body, String text, int pos) {
  var index = 0;
  while (true) {
    index = body.indexOf(text, index);
    pos--;
    if (pos < 0) {
      break;
    }
    index += text.length;
  }

  return index;
}

double calculateTextHeight({
  required String text,
  required TextStyle style,
  required GlobalKey editorKey,
}) {
  if (editorKey.currentContext == null) {
    return -1;
  }

  var renderBox = editorKey.currentContext!.findRenderObject() as RenderBox;
  var editorWidth = renderBox.size.width;

  var painter = TextPainter(
    textDirection: TextDirection.ltr,
    text: TextSpan(style: style, text: text),
    maxLines: null,
  );
  painter.layout(maxWidth: editorWidth);

  var lines = painter.computeLineMetrics();
  double height = 0;
  for (var lm in lines) {
    height += lm.height;
  }
  height -= lines.last.height;

  return height;
}

bool isVisibleInScrollController(
  ScrollController scrollController,
  double pos,
) {
  // FIXME: This '100' is hardcoded as it seems the EditorBottomBar's height
  //        is being included in the viewPortDimension
  var height = scrollController.position.viewportDimension - 100;
  var minY = scrollController.position.pixels;
  var maxY = minY + height;

  // Check if this position is 'inside' the current view rect
  return minY < pos && pos < maxY;
}

void scrollToSearchResult({
  required ScrollController scrollController,
  required TextEditingController textController,
  required GlobalKey textEditorKey,
  required String searchText,
  required TextStyle textStyle,
  required int resultNum,
}) {
  if (resultNum < 0) {
    resultNum = 0;
  }
  var body = textController.text.toLowerCase();
  searchText = searchText.toLowerCase();

  var offset = getSearchResultPosition(body, searchText, resultNum);
  if (offset >= body.length) {
    // show some kind of error?
    return;
  }
  var newPosition = calculateTextHeight(
    text: body.substring(0, offset),
    style: textStyle,
    editorKey: textEditorKey,
  );

  if (isVisibleInScrollController(scrollController, newPosition)) {
    return;
  }

  scrollController.animateTo(
    newPosition,
    duration: const Duration(milliseconds: 300),
    curve: Easing.legacyDecelerate,
  );
}
