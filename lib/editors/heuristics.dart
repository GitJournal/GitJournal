/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:gitjournal/editors/common.dart';

TextEditorState? autoAddBulletList(
    String oldText, String curText, final int cursorPos) {
  // We only want to do this on inserts
  if (curText.length <= oldText.length) {
    return null;
  }
  if (cursorPos <= 0) {
    return null;
  }

  // Only when adding a new line
  if (curText[cursorPos - 1] != '\n') {
    //print("Not a newline #${curText[cursorPos - 1]}#");
    return null;
  }

  /*
  print("CursorPos: $cursorPos");
  print("Text Length: ${curText.length}");
  */

  if (cursorPos - 2 < 0) {
    return null;
  }

  var prevLineStart = curText.lastIndexOf('\n', cursorPos - 2);
  prevLineStart = prevLineStart == -1 ? 0 : prevLineStart + 1;
  var prevLine = curText.substring(prevLineStart, cursorPos - 1);

  var pattern = RegExp(r'^(\s*)([*\-]|[0-9]\.)(\s+)(.*)$');
  var match = pattern.firstMatch(prevLine);
  if (match == null) {
    //print("no match");
    return null;
  }

  var indent = match.group(1) ?? "";
  var bulletType = match.group(2)!;
  var spacesBeforeContent = match.group(3)!;
  var contents = match.group(4)!;
  var remainingText =
      curText.length > cursorPos ? curText.substring(cursorPos) : "";

  /*
  if (remainingText.isNotEmpty) {
    print("At cursor: #${curText[cursorPos]}#");
  }
  print("Indent: #$indent#");
  print("bulletType: $bulletType");
  print("contents: #$contents#");
  print("spacesBeforeContent: #$spacesBeforeContent#");
  print("Remaining Text: #$remainingText#");
  */

  if (contents.trim().isEmpty) {
    var text = curText.substring(0, prevLineStart);
    var newCursorPos = text.length;

    text += remainingText;
    return TextEditorState(text, newCursorPos);
  }

  var extraText = indent + bulletType + spacesBeforeContent;
  var text = curText.substring(0, cursorPos) + extraText;
  var newCursorPos = text.length;
  text += remainingText;

  return TextEditorState(text, newCursorPos);
}

class EditorHeuristics {
  EditorHeuristics({String text = ''}) {
    _lastState = TextEditorState(text, 0);
  }

  late TextEditorState _lastState;

  TextEditorState? textChanged(TextEditorState es) {
    var lastState = _lastState;
    _lastState = es;

    return autoAddBulletList(lastState.text, es.text, es.cursorPos);
  }
}
