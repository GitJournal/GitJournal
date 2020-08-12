import 'package:flutter/material.dart';

class MarkdownToolBar extends StatelessWidget {
  final TextEditingController textController;

  MarkdownToolBar({
    @required this.textController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Text('H1'),
          onPressed: () => _modifyCurrentLine('# '),
        ),
        IconButton(
          icon: const Text('I'),
          onPressed: () => _modifyCurrentWord('*'),
        ),
        IconButton(
          icon: const Text('B'),
          onPressed: () => _modifyCurrentWord('**'),
        ),
      ],
    );
  }

  void _modifyCurrentLine(String char) {
    textController.value = modifyCurrentLine(textController.value, char);
  }

  void _modifyCurrentWord(String char) {
    var selection = textController.value.selection;
    var text = textController.value.text;

    print('Base offset: ${selection.baseOffset}');
    print('Extent offset: ${selection.extentOffset}');
    var cursorPos = selection.baseOffset;
    if (cursorPos == -1) {
      cursorPos = 0;
    }
    print('CursorPos: $cursorPos');

    var wordStartPos =
        text.lastIndexOf(' ', cursorPos == 0 ? 0 : cursorPos - 1);
    if (wordStartPos == -1) {
      wordStartPos = 0;
    }

    var wordEndPos = text.indexOf(' ', cursorPos);
    if (wordEndPos == -1) {
      wordEndPos = text.length;
    }

    print('Word Start: $wordStartPos');
    print('Word End: $wordEndPos');
    print('Word: ${text.substring(wordStartPos, wordEndPos)}');

    // Check if already present
    if (text.startsWith(char, wordStartPos)) {
      print('Removing `$char`');
      textController.text = text.replaceFirst(char, '', wordStartPos);
      textController.selection =
          TextSelection.collapsed(offset: cursorPos - (char.length * 2));
      return;
    }

    print('Adding `$char`');
    textController.text = text.replaceRange(wordStartPos, wordStartPos, char);
    wordEndPos += char.length;

    textController.text =
        text.replaceRange(wordEndPos - 1, wordEndPos - 1, char);
    textController.selection =
        TextSelection.collapsed(offset: cursorPos + (char.length * 2));

    print('$char');
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
    return TextEditingValue(
      text: text.replaceFirst(char, '', lineStartPos),
      selection: TextSelection.collapsed(offset: cursorPos - char.length),
    );
  }

  return TextEditingValue(
    text: text.replaceRange(lineStartPos, lineStartPos, char),
    selection: TextSelection.collapsed(offset: cursorPos + char.length),
  );
}
