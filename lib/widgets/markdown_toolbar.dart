import 'package:flutter/material.dart';

class MarkdownToolBar extends StatelessWidget {
  final TextEditingController textController;

  MarkdownToolBar({
    @required this.textController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          IconButton(
            icon: const Text('H1'),
            padding: const EdgeInsets.all(0.0),
            onPressed: () => _modifyCurrentLine('# '),
          ),
          IconButton(
            icon: const Text('I'),
            padding: const EdgeInsets.all(0.0),
            onPressed: () => _modifyCurrentWord('*'),
          ),
          IconButton(
            icon: const Text('B'),
            padding: const EdgeInsets.all(0.0),
            onPressed: () => _modifyCurrentWord('**'),
          ),
          IconButton(
            icon: const Icon(Icons.navigate_before),
            padding: const EdgeInsets.all(0.0),
            onPressed: _navigateToPrevWord,
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            padding: const EdgeInsets.all(0.0),
            onPressed: _navigateToNextWord,
          ),
        ],
      ),
    );
  }

  void _modifyCurrentLine(String char) {
    textController.value = modifyCurrentLine(textController.value, char);
  }

  void _modifyCurrentWord(String char) {
    textController.value = modifyCurrentWord(textController.value, char);
  }

  void _navigateToPrevWord() {
    var offset = prevWordPos(textController.value);
    textController.selection = TextSelection.collapsed(offset: offset);
  }

  void _navigateToNextWord() {
    var offset = nextWordPos(textController.value);
    textController.selection = TextSelection.collapsed(offset: offset);
  }
}

TextEditingValue modifyCurrentLine(
  TextEditingValue textEditingValue,
  String char,
) {
  var selection = textEditingValue.selection;
  var text = textEditingValue.text;

  //print('Base offset: ${selection.baseOffset}');
  //print('Extent offset: ${selection.extentOffset}');
  var cursorPos = selection.baseOffset;
  if (cursorPos == -1) {
    cursorPos = 0;
  }
  //print('CursorPos: $cursorPos');

  var lineStartPos = text.lastIndexOf('\n', cursorPos == 0 ? 0 : cursorPos - 1);
  if (lineStartPos == -1) {
    lineStartPos = 0;
  } else {
    lineStartPos += 1;
  }

  var lineEndPos = text.indexOf('\n', cursorPos);
  if (lineEndPos == -1) {
    lineEndPos = text.length;
  }

  //print('Line Start: $lineStartPos');
  //print('Line End: $lineEndPos');
  //print('Line: ${text.substring(lineStartPos, lineEndPos)}');

  // Check if already present
  if (text.startsWith(char, lineStartPos)) {
    //print('Removing `$char`');
    var endOffset = cursorPos;
    //print("End Offset: $endOffset");
    if (endOffset > lineStartPos) {
      endOffset -= char.length;
      //print("End Offset min char: $endOffset");
    }
    if (endOffset < lineStartPos) {
      endOffset = lineStartPos;
      //print("End Offset equal LineStartPos: $endOffset");
    }
    return TextEditingValue(
      text: text.replaceFirst(char, '', lineStartPos),
      selection: TextSelection.collapsed(offset: endOffset),
    );
  }

  return TextEditingValue(
    text: text.replaceRange(lineStartPos, lineStartPos, char),
    selection: TextSelection.collapsed(offset: cursorPos + char.length),
  );
}

TextEditingValue modifyCurrentWord(
  TextEditingValue textEditingValue,
  String char,
) {
  var selection = textEditingValue.selection;
  var text = textEditingValue.text;

  //print('Base offset: ${selection.baseOffset}');
  //print('Extent offset: ${selection.extentOffset}');
  var cursorPos = selection.baseOffset;
  if (cursorPos == -1) {
    cursorPos = 0;
  }
  //print('CursorPos: $cursorPos');

  var wordStartPos =
      text.lastIndexOf(RegExp('\\s'), cursorPos == 0 ? 0 : cursorPos - 1);
  if (wordStartPos == -1) {
    wordStartPos = 0;
  } else {
    wordStartPos += 1;
  }

  var wordEndPos = text.indexOf(RegExp('\\s'), cursorPos);
  if (wordEndPos == -1) {
    wordEndPos = text.length;
  }

  //print('Word Start: $wordStartPos');
  //print('Word End: $wordEndPos');
  //print('Word: ${text.substring(wordStartPos, wordEndPos)}');

  // Check if already present
  if (text.startsWith(char, wordStartPos) &&
      text.startsWith(char, wordEndPos - char.length)) {
    text = text.replaceFirst(char, '', wordStartPos);
    wordEndPos -= char.length;

    return TextEditingValue(
      text: text.replaceFirst(char, '', wordEndPos - char.length),
      selection: TextSelection.collapsed(
        offset: wordEndPos - char.length,
      ),
    );
  }

  //print('Adding `$char`');
  text = text.replaceRange(wordStartPos, wordStartPos, char);
  wordEndPos += char.length;

  return TextEditingValue(
    text: text.replaceRange(wordEndPos, wordEndPos, char),
    selection: TextSelection.collapsed(offset: wordEndPos),
  );
}

// FIXME: This will fail in non space delimited languages
int nextWordPos(TextEditingValue textEditingValue) {
  var cursorPos = textEditingValue.selection.baseOffset;
  var text = textEditingValue.text;

  var nextSpacePos = text.indexOf(RegExp('(\\s|[.!?])'), cursorPos);
  if (nextSpacePos == -1) {
    return text.length;
  }
  if (nextSpacePos == cursorPos) {
    nextSpacePos++;
  }
  if (nextSpacePos > text.length) {
    nextSpacePos = text.length;
  }

  return nextSpacePos;
}

int prevWordPos(TextEditingValue textEditingValue) {
  var cursorPos = textEditingValue.selection.baseOffset;
  var text = textEditingValue.text;

  var lastSpacePos = text.lastIndexOf(RegExp('(\\s|[.!?])'), cursorPos);
  if (lastSpacePos == -1) {
    return 0;
  }
  if (lastSpacePos == cursorPos) {
    lastSpacePos = text.lastIndexOf(RegExp('(\\s|[.!?])'), cursorPos - 1);
    if (lastSpacePos == -1) {
      return 0;
    }
    lastSpacePos++;
  }

  return lastSpacePos;
}
