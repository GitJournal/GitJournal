import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:gitjournal/editors/autocompletion_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutCompleter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'AutoCompleter'),
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
  }

  @override
  Widget build(BuildContext context) {
    Widget textField = TextField(
      controller: _textController,
      focusNode: _focusNode,
      key: _textFieldKey,
      style: _textFieldStyle,
      maxLines: 300,
    );

    textField = AutoCompletionWidget(
      textFieldStyle: _textFieldStyle,
      textFieldKey: _textFieldKey,
      textFieldFocusNode: _focusNode,
      textController: _textController,
      child: textField,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            child: textField,
            width: 400.0,
          ),
        ),
      ),
    );
  }
}
