/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:time/time.dart';

class AutoCompletionWidget extends StatefulWidget {
  final FocusNode textFieldFocusNode;
  final GlobalKey textFieldKey;
  final TextStyle textFieldStyle;
  final TextEditingController textController;
  final Widget child;
  final List<String> tags;

  const AutoCompletionWidget({
    super.key,
    required this.textFieldFocusNode,
    required this.textFieldKey,
    required this.textFieldStyle,
    required this.textController,
    required this.child,
    required this.tags,
  });

  @override
  _AutoCompletionWidgetState createState() => _AutoCompletionWidgetState();
}

class _AutoCompletionWidgetState extends State<AutoCompletionWidget> {
  OverlayEntry? overlayEntry;

  var autoCompleter = TagsAutoCompleter();
  List<String>? tags;

  @override
  void initState() {
    super.initState();
    widget.textController.addListener(_textChanged);
  }

  @override
  void dispose() {
    _hideOverlay();
    widget.textController.removeListener(_textChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _textChanged() {
    var selection = widget.textController.selection;
    var text = widget.textController.text;

    var range = TextRange(0, 0);
    try {
      var es = TextEditorState(text, selection.baseOffset);
      range = autoCompleter.textChanged(es);
    } catch (e, st) {
      Log.e("AutoCompleter", ex: e, stacktrace: st);
    }

    if (range.isEmpty) {
      _hideOverlay();
      return;
    }

    if ((range.end - range.start) <= 0) return;
    if (range.end > text.length) return;

    var prefix = text.substring(range.start, range.end);
    if (prefix == "\n") {
      // Pressed Enter
    } else {
      _showOverlayTag(context, text.substring(0, range.end));
    }
  }

  /// newText is used to calculate where to put the completion box
  Future<void> _showOverlayTag(BuildContext context, String newText) async {
    // Code reference for overlay logic from MTECHVIRAL's video
    // https://www.youtube.com/watch?v=KuXKwjv2gTY

    //print('showOverlaidTag: $newText');

    RenderBox renderBox =
        widget.textFieldKey.currentContext!.findRenderObject() as RenderBox;
    // print("render Box: ${renderBox.size}");

    TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        style: widget.textFieldStyle,
        text: newText,
      ),
      maxLines: null,
    );
    painter.layout(maxWidth: renderBox.size.width);

    List<LineMetrics> lines = painter.computeLineMetrics();
    var height = lines.map((e) => e.height).reduce((a, b) => a + b);
    var width = lines.last.width;

    //print("Focus Node Offset dx: ${_focusNode.offset.dx}");
    //print("Focus Node Offset dy: ${_focusNode.offset.dy}");

    //print("Painter ${painter.width} $height");

    var list = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var tag in widget.tags)
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text('#$tag', style: const TextStyle(fontSize: 20.0)),
          ),
      ],
    );

    _hideOverlay();
    overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        // Decides where to place the tag on the screen.
        top: widget.textFieldFocusNode.offset.dy + height + 3,
        left: widget.textFieldFocusNode.offset.dx + width,

        // Tag code.
        child: Material(
          elevation: 4.0,
          color: Colors.grey[200],
          child: list,
        ),
      );
    });
    Overlay.of(context).insert(overlayEntry!);

    // Removes the over lay entry from the Overly after 500 milliseconds
    await Future.delayed(5000.milliseconds);
    _hideOverlay();
  }

  void _hideOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
  }
}

/*
/// if endToken is empty, then the token can only be alpha numeric
String extractToken(
    String text, int cursorPos, String startToken, String endToken) {
  var start = text.lastIndexOf(RegExp(r' '), cursorPos - 1);
  if (start == -1) {
    start = 0;
  }
  print("start: $start");

  var end = text.indexOf(RegExp(r' |$'), cursorPos);
  if (end == -1) {
    end = cursorPos;
  }
  print("end: $end");

  var word = text.substring(start, end);
  if (word.startsWith('[[')) {
    return word.substring(2, cursorPos);
  }

  return "";
}

bool enterPressed(String oldText, String newText, int cursorPos) {
  if (cursorPos <= 0) {
    return false;
  }

  var charEnterred = newText[cursorPos - 1];
  if (charEnterred == '\n') {
    return true;
  }
  return false;
}
*/

// https://levelup.gitconnected.com/flutter-medium-like-text-editor-b41157f50f0e
// https://stackoverflow.com/questions/59243627/flutter-how-to-get-the-coordinates-of-the-cursor-in-a-textfield

// Bug 2: Autocompletion box overlays the bottom nav bar
// Bug 3: On Pressing Enter the Overlay should disappear
// Bug 5: Overlay disappears too fast
// Bug 7: Clicking on the text should result in auto-completion
// Bug 8: On clicking somewhere else the suggestion box should disappear
// Bug 9: RTL support
// Bug  : What about when a letter is added to an existing tag with more words
//        or an existing wiki link which has the closing brackets
// Bug  : Show auto-completion on top if no space at the bottom
// Bug  : Handle physical tab or Enter key
// Bug  : Fix the faulty colours

/*
abstract class AutoCompletionLogic {
  /// Return an empty string if the overlay should be hidden
  /// Return \n if enter has been pressed
  /// Return the prefix if an overlay should be shown
  String textChanged(EditorState es);

  EditorState completeText(String text);
}
*/

/*
class WikiLinksAutoCompleter implements AutoCompletionLogic {
  var _oldState = EditorState("", 0);

  bool inBracket1 = false;
  bool inBracket2 = false;
  bool outBracket2 = false;

  var newText = "";

  @override
  void textChanged(EditorState es) {
    var oldState = _oldState;
    _oldState = es;

    // This could result in an Add / Remove / Replace

    if (es.text.length > oldState.text.length) {
      // Probably an add
      if (oldState.cursorPos < es.cursorPos) {
        newText = es.text.substring(oldState.cursorPos, es.cursorPos);
        return;
      }
      return;
    }
  }

  @override
  EditorState completeText(String text) {
    return null;
  }

  @override
  bool get enterPressed => false;

  @override
  bool get showOverlay => false;
}
*/

class TextRange {
  final int start;
  final int end;

  TextRange(this.start, this.end);

  bool get isEmpty => start == end;
}

class TagsAutoCompleter {
  TextRange textChanged(TextEditorState es) {
    // - Get current line
    // - Remove everything to the right of the cursor
    // - Check if a character has been entered
    // - Abort if the cursor position has changed but nothing has been enterred
    // - Check if entering a tag (starts with #)
    // - Place the autocompletion popup under the cursor

    // print("${es.text} ${es.cursorPos}");
    var start = es.text.lastIndexOf(RegExp(r'^|[ .?!:;\n]'), es.cursorPos);
    if (start <= 0) {
      start = 0;
    } else {
      start += 1;
    }
    if (start == es.text.length) {
      return TextRange(0, 0);
    }

    var end = es.text.indexOf(RegExp(r'[ .?!:;\n]|$'), es.cursorPos);
    if (end == -1) {
      end = es.cursorPos;
    }

    // print("start end: $start $end ${es.text.length}");
    // var text = es.text.substring(start, end);
    // print("text $text");
    if (es.text[start] != '#') {
      return TextRange(0, 0);
    }

    return TextRange(start + 1, end);
  }
}
