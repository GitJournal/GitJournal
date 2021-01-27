import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:time/time.dart';

class AutoCompleter extends StatefulWidget {
  final FocusNode textFieldFocusNode;
  final GlobalKey textFieldKey;
  final TextStyle textFieldStyle;
  final TextEditingController textController;
  final Widget child;

  final String startToken;
  final String endToken;

  AutoCompleter({
    @required this.textFieldFocusNode,
    @required this.textFieldKey,
    @required this.textFieldStyle,
    @required this.textController,
    @required this.child,
    @required this.startToken,
    @required this.endToken,
  });

  @override
  _AutoCompleterState createState() => _AutoCompleterState();
}

class _AutoCompleterState extends State<AutoCompleter> {
  OverlayEntry overlayEntry;
  String prevText;

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
    var cursorPos = selection.baseOffset;
    var text = widget.textController.text;

    var start = text.lastIndexOf(RegExp(r' |^'), cursorPos - 1) + 1;
    var word = text.substring(start, cursorPos);
    print('text: $word');
    if (word.startsWith(widget.startToken)) {
      _showOverlayTag(context, text.substring(0, cursorPos));
    } else if (word.endsWith(widget.endToken)) {
      // Hide when ]] is added
      _hideOverlay();
    }

    prevText = text;
  }

  /// newText is used to calculate where to put the completion box
  void _showOverlayTag(BuildContext context, String newText) async {
    // Code reference for overlay logic from MTECHVIRAL's video
    // https://www.youtube.com/watch?v=KuXKwjv2gTY

    //print('showOverlaidTag: $newText');

    RenderBox renderBox = widget.textFieldKey.currentContext.findRenderObject();
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
    double height = 0;
    for (var lm in lines) {
      height += lm.height;
    }
    double width = lines.last.width;

    //print("Focus Node Offset dx: ${_focusNode.offset.dx}");
    //print("Focus Node Offset dy: ${_focusNode.offset.dy}");

    //print("Painter ${painter.width} $height");

    _hideOverlay();
    overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        // Decides where to place the tag on the screen.
        top: widget.textFieldFocusNode.offset.dy + height + 3,
        left: widget.textFieldFocusNode.offset.dx + width,

        // Tag code.
        child: const Material(
            elevation: 4.0,
            color: Colors.lightBlueAccent,
            child: Text(
              'Show tag here',
              style: TextStyle(
                fontSize: 20.0,
              ),
            )),
      );
    });
    Overlay.of(context).insert(overlayEntry);

    // Removes the over lay entry from the Overly after 500 milliseconds
    await Future.delayed(5000.milliseconds);
    _hideOverlay();
  }

  void _hideOverlay() {
    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    }
  }
}

/// if endToken is empty, then the token can only be alpha numeric
String extractToken(
    String text, int cursorPos, String startToken, String endToken) {
  var start = text.lastIndexOf(RegExp(r' |^'), cursorPos - 1);
  if (start == -1) {
    var word = text.substring(0, cursorPos);
    if (word.startsWith('[[')) {
      return word.substring(2, cursorPos);
    }
    return "";
  }

  return text;
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

class CompletionResult {
  String text;
  int cursorPos;

  CompletionResult(this.text, this.cursorPos);
}

CompletionResult completeText(String oldText, String newText, int cursorPos) {
  return null;
}

bool hideAutoCompleter(String oldText, String newText, int cursorPos) {
  return false;
}

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
