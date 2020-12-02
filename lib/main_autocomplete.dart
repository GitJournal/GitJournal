import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:time/time.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter  Show Text Tag Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Show Text Tag demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FocusNode _focusNode = FocusNode();
  GlobalKey _textFieldKey = GlobalKey();
  TextStyle _textFieldStyle = const TextStyle(fontSize: 20);

  TextEditingController _textController;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController();
    _textController.addListener(() {
      var selection = _textController.selection;
      var cursorPos = selection.baseOffset;
      var text = _textController.text;

      var nextText = text.substring(0, cursorPos);
      print('newText: $nextText');
      if (nextText.endsWith('[[')) {
        showOverlaidTag(context, nextText);
      }
    });
  }

  // Code reference for overlay logic from MTECHVIRAL's video
  // https://www.youtube.com/watch?v=KuXKwjv2gTY

  // I need to paint it exactly where the cursor is

  void showOverlaidTag(BuildContext context, String newText) async {
    print('showOverlaidTag: $newText');

    RenderBox renderBox = _textFieldKey.currentContext.findRenderObject();
    print("render Box: ${renderBox.size}");

    TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        style: _textFieldStyle,
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

    print("Focus Node Offset dx: ${_focusNode.offset.dx}");
    print("Focus Node Offset dy: ${_focusNode.offset.dy}");

    print("Painter ${painter.width} $height");

    OverlayState overlayState = Overlay.of(context);
    OverlayEntry suggestionTagoverlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        // Decides where to place the tag on the screen.
        top: _focusNode.offset.dy + height + 3,
        left: _focusNode.offset.dx + width,

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
    overlayState.insert(suggestionTagoverlayEntry);

    // Removes the over lay entry from the Overly after 500 milliseconds
    await Future.delayed(5000.milliseconds);
    suggestionTagoverlayEntry.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              key: _textFieldKey,
              style: _textFieldStyle,
              maxLines: null,
            ),
            width: 400.0,
          ),
        ),
      ),
    );
  }
}

class Editor extends StatefulWidget {
  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
// https://pub.dev/packages/rich_input
// https://levelup.gitconnected.com/flutter-medium-like-text-editor-b41157f50f0e

// https://pub.dev/packages/autocomplete_textfield
// https://pub.dev/packages/flutter_typeahead

// https://stackoverflow.com/questions/59243627/flutter-how-to-get-the-coordinates-of-the-cursor-in-a-textfield

// Bug 2: Autocompletion box overlays the bottom nav bar
// Bug 3: On Pressing Enter the Overlay should disappear
// Bug 4: On Deleting the prefix buttons it should also disappear
// Bug 5: Overlay disappears too fast
// Bug 6: When writing a text which has '[[Hell' it doesn't show the autocompletion
