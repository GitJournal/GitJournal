import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:path/path.dart' as p;
import 'package:mutex/mutex.dart';

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

    jsChannel = JavascriptChannel(
      name: 'Print',
      onMessageReceived: (JavascriptMessage message) {
        print("-----JS CHANNEL ----");
        print(message.message);

        var uri = UriData.parse(message.message);

        String tmpFile;
        var num = 0;
        while (true) {
          tmpFile = p.join(Directory.systemTemp.path, "katex_$num.png");
          if (!File(tmpFile).existsSync()) {
            break;
          }
          num += 1;
        }
        File(tmpFile).writeAsBytesSync(uri.contentAsBytes());

        if (mounted) {
          setState(() {
            print("State has been set $tmpFile");
            imagePath = tmpFile;
          });
        }

        flutterWebViewPlugin.close();
        _onStateChanged.cancel();
        _onStateChanged = null;

        print("Releasing Katex mutex lock ${widget.input}");
        _globalMutex.release();
      },
    );

    _initAsync();
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
    if (imagePath == null) {
      return Container();
    }

    print("Building Network Image $imagePath");
    return Image.file(File(imagePath));
  }
}
