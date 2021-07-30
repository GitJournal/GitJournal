/*

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:crypto/crypto.dart';
import 'package:mutex/mutex.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart';

class KatexWidget extends StatefulWidget {
  final String input;

  KatexWidget(this.input, {Key key}) : super(key: key);

  @override
  _KatexWidgetState createState() => _KatexWidgetState();
}

class _KatexWidgetState extends State<KatexWidget> {
  static final _globalMutex = Mutex();
  static var flutterWebViewPlugin = FlutterWebviewPlugin();

  String imagePath;
  JavascriptChannel jsChannel;
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  final selectedUrl = 'https://gitjournal.io/test_katex.html';

  @override
  void initState() {
    super.initState();

    var inputHash = md5.convert(utf8.encode(widget.input)).toString();
    imagePath = p.join(Directory.systemTemp.path, "katex_$inputHash.png");

    jsChannel = JavascriptChannel(
      name: 'Print',
      onMessageReceived: (JavascriptMessage message) {
        print("-----JS CHANNEL ----");
        print(message.message);

        var uri = UriData.parse(message.message);
        File(imagePath).writeAsBytesSync(uri.contentAsBytes());

        // Underlying image file has been modified
        if (mounted) {
          setState(() {});
        }

        flutterWebViewPlugin.close();
        _onStateChanged.cancel();
        _onStateChanged = null;

        print("Releasing Katex mutex lock ${widget.input}");
        _globalMutex.release();
      },
    );

    if (File(imagePath).existsSync()) {
      print("Katex ${widget.input} in cache");
    } else {
      _initAsync();
    }
  }

  void _initAsync() async {
    print("Trying to acquire Katex mutex lock ${widget.input}");
    await _globalMutex.acquire();
    print("Acquired to Katex mutex lock ${widget.input}");

    flutterWebViewPlugin.close();

    _onStateChanged =
        flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if (!mounted) return;

      if (state.type == WebViewState.finishLoad) {
        _renderKatex();
      }
    });

    flutterWebViewPlugin.launch(
      selectedUrl,
      hidden: true,
      javascriptChannels: {jsChannel},
      withJavascript: true,
    );
  }

  @override
  void dispose() {
    // flutterWebViewPlugin.dispose();

    if (_onStateChanged != null) {
      _onStateChanged.cancel();
    }
    super.dispose();
  }

  void _renderKatex() {
    var katex = widget.input;
    print("Trying to render $katex");
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
    if (!File(imagePath).existsSync()) {
      return Container();
    }

    print("Building Network Image $imagePath");
    return Image.file(File(imagePath));
  }
}
*/
