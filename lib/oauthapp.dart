import 'package:flutter/material.dart';
import 'package:journal/apis/git.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

const _platform = const MethodChannel('gitjournal.io/git');

// Actual message handler:
Future _handleMessages(MethodCall call) async {
  switch (call.method) {
    case "onURL":
      print("Call onURL" + call.arguments.toString());
    // Do something nice using call.arguments["URL"]
  }
}

class OAuthApp extends StatefulWidget {
  @override
  OAuthAppState createState() {
    return new OAuthAppState();
  }
}

class OAuthAppState extends State<OAuthApp> {
  void initState() {
    super.initState();
    _platform.setMethodCallHandler(_handleMessages);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'OAuth App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('OAuth Test'),
        ),
        body: Column(children: <Widget>[
          RaisedButton(
            child: Text("Open OAuth URL"),
            onPressed: () {
              var url =
                  "https://github.com/login/oauth/authorize?client_id=aa3072cbfb02b1db14ed&scope=repo";
              launch(url);
            },
          ),
        ]),
      ),
    );
  }
}
