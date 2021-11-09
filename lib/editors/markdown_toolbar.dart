/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:gitjournal/forks/icon_button_more_gestures.dart' as fork;

// FIXME:
// - Pin this on top of the keyboard
// - It should only be visible when the keyboard is shown
// - Add an overlay which shows the other header options when longtaping on H1
// - Add a block quote button
// - Add a code fence button
//
class MarkdownToolBar extends StatelessWidget {
  final TextEditingController textController;

  const MarkdownToolBar({
    Key? key,
    required this.textController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var style = textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold);

    var scroll = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          fork.IconButton(
            icon: Text('H1', style: style),
            padding: const EdgeInsets.all(0.0),
            onPressed: () => _modifyCurrentLine('# '),
          ),
          fork.IconButton(
            icon: Text('I', style: style),
            padding: const EdgeInsets.all(0.0),
            onPressed: () => _modifyCurrentWord('*'),
          ),
          fork.IconButton(
            icon: Text('B', style: style),
            padding: const EdgeInsets.all(0.0),
            onPressed: () => _modifyCurrentWord('**'),
          ),
          fork.IconButton(
            icon: const FaIcon(FontAwesomeIcons.listUl),
            padding: const EdgeInsets.all(0.0),
            onPressed: () => _modifyCurrentLine('- '),
          ),
          fork.IconButton(
            icon: const FaIcon(FontAwesomeIcons.listOl),
            padding: const EdgeInsets.all(0.0),
            onPressed: () => _modifyCurrentLine('1. '),
          ),
          fork.IconButton(
            icon: const FaIcon(FontAwesomeIcons.tasks),
            padding: const EdgeInsets.all(0.0),
            onPressed: () => _modifyCurrentLine('- [ ] '),
          ),
          const SizedBox(
            height: 20,
            child: VerticalDivider(),
          ),
          fork.IconButton(
            icon: const Icon(Icons.navigate_before),
            padding: const EdgeInsets.all(0.0),
            onPressed: _navigateToPrevWord,
            onLongPressed: _addBackTab,
          ),
          fork.IconButton(
            icon: const Icon(Icons.navigate_next),
            padding: const EdgeInsets.all(0.0),
            onPressed: _navigateToNextWord,
            onLongPressed: _addTab,
          ),
        ],
      ),
    );

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: viewportConstraints.maxWidth,
        ),
        child: scroll,
      );
    });
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

  // FIXME: Maybe add Tab should work on lines instead? Independent of the cursor pos
  // FIXME: Make addTab work for selections as well?
  void _addTab() {
    textController.value = addTab(textController.value);
  }

  void _addBackTab() {
    textController.value = addBackTab(textController.value);
  }
}

final _allowedBlockTags = [
  '# ',
  '## ',
  '### ',
  '#### ',
  '##### ',
  '###### ',
  '- ',
  '* ',
];

final _allowedBlockRegExps = [
  RegExp('- [[xX ]] '),
  RegExp('d+. '),
];

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

  // Check if line already has a block tag
  for (var blockTag in _allowedBlockTags) {
    if (text.startsWith(blockTag, lineStartPos)) {
      var newVal = _removeFromLine(text, cursorPos, lineStartPos, blockTag);
      if (blockTag == char) {
        return newVal;
      }
      return modifyCurrentLine(newVal, char);
    }
  }

  for (var blockTagRegExp in _allowedBlockRegExps) {
    var match = blockTagRegExp.matchAsPrefix(text, lineStartPos);
    if (match != null) {
      var blockTag = match.group(0)!;
      var newVal = _removeFromLine(text, cursorPos, lineStartPos, blockTag);
      if (blockTag == char) {
        return newVal;
      }
      return modifyCurrentLine(newVal, char);
    }
  }

  //print('Line Start: $lineStartPos');
  //print('Line End: $lineEndPos');
  //print('Line: ${text.substring(lineStartPos, lineEndPos)}');

  return TextEditingValue(
    text: text.replaceRange(lineStartPos, lineStartPos, char),
    selection: TextSelection.collapsed(offset: cursorPos + char.length),
  );
}

TextEditingValue _removeFromLine(
  String text,
  int cursorPos,
  int lineStartPos,
  String char,
) {
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

TextEditingValue modifyCurrentWord(
  TextEditingValue textEditingValue,
  String char,
) {
  var selection = textEditingValue.selection;
  var text = textEditingValue.text;

  late int wordStartPos;
  late int wordEndPos;
  var selectionMode = false;

  // Text Selected
  if (selection.baseOffset != selection.extentOffset) {
    wordStartPos = selection.baseOffset;
    wordEndPos = selection.extentOffset;
    selectionMode = true;
  } else {
    var cursorPos = selection.baseOffset;
    if (cursorPos == -1) {
      cursorPos = 0;
    }
    //print('CursorPos: $cursorPos');

    wordStartPos =
        text.lastIndexOf(RegExp('\\s'), cursorPos == 0 ? 0 : cursorPos - 1);
    if (wordStartPos == -1) {
      wordStartPos = 0;
    } else {
      wordStartPos += 1;
    }

    wordEndPos = text.indexOf(RegExp('\\s'), cursorPos);
    if (wordEndPos == -1) {
      wordEndPos = text.length;
    }
  }

  //print('Word Start: $wordStartPos');
  //print('Word End: $wordEndPos');
  //print('Word: ${text.substring(wordStartPos, wordEndPos)}');

  // Check if already present
  if (text.startsWith(char, wordStartPos) &&
      text.startsWith(char, wordEndPos - char.length)) {
    text = text.replaceFirst(char, '', wordStartPos);
    wordEndPos -= char.length;

    var newSelection = selectionMode
        ? TextSelection(
            baseOffset: wordStartPos,
            extentOffset: wordEndPos - char.length,
          )
        : TextSelection.collapsed(offset: wordEndPos - char.length);

    return TextEditingValue(
      text: text.replaceFirst(char, '', wordEndPos - char.length),
      selection: newSelection,
    );
  }

  //print('Adding `$char`');
  text = text.replaceRange(wordStartPos, wordStartPos, char);
  wordEndPos += char.length;

  var newSelection = selectionMode
      ? TextSelection(
          baseOffset: wordStartPos,
          extentOffset: wordEndPos + char.length,
        )
      : TextSelection.collapsed(offset: wordEndPos);

  return TextEditingValue(
    text: text.replaceRange(wordEndPos, wordEndPos, char),
    selection: newSelection,
  );
}

// FIXME: This will fail in non space delimited languages
final _wordSepRegex = RegExp('((\\s|\\n)|[.!?])');

int nextWordPos(TextEditingValue textEditingValue) {
  var cursorPos = textEditingValue.selection.baseOffset;
  var text = textEditingValue.text;

  if (cursorPos >= text.length) {
    return text.length;
  }
  if (cursorPos == -1) {
    cursorPos = 0;
  }

  var nextSpacePos = text.indexOf(_wordSepRegex, cursorPos);
  if (nextSpacePos == -1) {
    return text.length;
  }
  if (nextSpacePos == cursorPos) {
    nextSpacePos++;
  }

  return nextSpacePos;
}

int prevWordPos(TextEditingValue textEditingValue) {
  var cursorPos = textEditingValue.selection.baseOffset;
  var text = textEditingValue.text;

  if (cursorPos <= 1) {
    return 0;
  }

  var lastSpacePos = text.lastIndexOf(_wordSepRegex, cursorPos - 1);
  if (lastSpacePos == -1) {
    return 0;
  }
  if (lastSpacePos == cursorPos - 1) {
    lastSpacePos--;
  }

  return lastSpacePos + 1;
}

var indentStr = '\t';

TextEditingValue addTab(TextEditingValue textEditingValue) {
  var cursorPos = textEditingValue.selection.baseOffset;
  var text = textEditingValue.text;

  return TextEditingValue(
    text: indentStr + text,
    selection: TextSelection.collapsed(offset: cursorPos + 1),
  );
}

TextEditingValue addBackTab(TextEditingValue textEditingValue) {
  var cursorPos = textEditingValue.selection.baseOffset;
  var text = textEditingValue.text;

  var newText = text;
  if (newText.startsWith(indentStr)) {
    newText = newText.substring(indentStr.length);
    cursorPos -= indentStr.length;
  }

  return TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: cursorPos),
  );
}
