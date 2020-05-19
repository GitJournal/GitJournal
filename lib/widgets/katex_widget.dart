import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:path/path.dart' as p;

class KatexWidget extends StatefulWidget {
  final String input;

  KatexWidget(this.input, {Key key}) : super(key: key);

  @override
  _KatexWidgetState createState() => _KatexWidgetState();
}

class _KatexWidgetState extends State<KatexWidget> {
  String imagePath;
  JavascriptChannel jsChannel;

  final flutterWebViewPlugin = FlutterWebviewPlugin();
  final selectedUrl = 'https://gitjournal.io/test_katex.html';

  @override
  void initState() {
    super.initState();

    jsChannel = JavascriptChannel(
      name: 'Print',
      onMessageReceived: (JavascriptMessage message) {
        print("-----JS CHANNEL ----");
        print(message.message);

        var uri = UriData.parse(message.message);
        var tmpFile = p.join(Directory.systemTemp.path, "katex.png");
        File(tmpFile).writeAsBytesSync(uri.contentAsBytes());

        setState(() {
          print("State has been set");
          imagePath = tmpFile;
        });
      },
    );

    flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if (!mounted) return;

      if (state.type == WebViewState.finishLoad) {
        _renderKatex();
      }
    });

    flutterWebViewPlugin.close();
    flutterWebViewPlugin.launch(
      selectedUrl,
      hidden: true,
      javascriptChannels: {jsChannel},
      withJavascript: true,
    );
  }

  @override
  void dispose() {
    flutterWebViewPlugin.dispose();

    super.dispose();
  }

  void _renderKatex() {
    var katex = widget.input;
    var js = """katex.render("$katex", document.body, {
    throwOnError: false
});

html2canvas(document.body, {backgroundColor: 'rgba(0, 0, 0, 0)', removeContainer: true,}).then(function(canvas) {
    var img = canvas.toDataURL("image/png");
    Print.postMessage(img);
});
""";
    flutterWebViewPlugin.evalJavascript(js);
  }

  @override
  Widget build(BuildContext context) {
    if (imagePath == null) {
      return Container();
    }

    print("Building Network Image");
    return Image.file(File(imagePath));
  }
}
