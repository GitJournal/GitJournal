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

  // Only when getting a new line
  if (curText[cursorPos - 1] != '\n') {
    return null;
  }

  // Only add the bullets at the end of the document
  // FIXME: We should do this anywhere
  if (curText.length != cursorPos) {
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

  return EditorHeuristicResult(text, text.length);
}
