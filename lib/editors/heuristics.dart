class EditorHeuristicResult {
  String text;
  int cursorPos;

  EditorHeuristicResult(this.text, this.cursorPos);
}

EditorHeuristicResult autoAddBulletList(
    String oldText, String curText, int cursorPos) {
  // We only want to do this on inserts
  if (curText.length <= oldText.length) {
    return null;
  }

  // Only when adding a new line
  if (curText[cursorPos - 1] != '\n') {
    return null;
  }

  var prevLineStart = curText.lastIndexOf('\n', cursorPos - 2);
  prevLineStart = prevLineStart == -1 ? 0 : prevLineStart + 1;
  var prevLine = curText.substring(prevLineStart, cursorPos - 1);

  var pattern = RegExp(r'^(\s*)([*\-])');
  var match = pattern.firstMatch(prevLine);
  if (match == null) {
    return null;
  }

  var indent = match.group(1) ?? "";
  var text = curText.substring(0, cursorPos) + indent + match.group(2) + ' ';
  if (cursorPos == curText.length) {
    return EditorHeuristicResult(text, text.length);
  }

  text += '\n' + curText.substring(cursorPos + 1);
  var extraChars = indent.length + match.group(2).length + 1;
  return EditorHeuristicResult(text, cursorPos + extraChars);
}
