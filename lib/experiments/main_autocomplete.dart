/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

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
      home: const MyHomePage(title: 'AutoCompleter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _textFieldKey = GlobalKey();
  final TextStyle _textFieldStyle = const TextStyle(fontSize: 20);

  TextEditingController? _textController;

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
      textController: _textController!,
      child: textField,
      tags: const ['Hello', 'Howdy', 'Pooper'],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            child: textField,
            width: 400.0,
          ),
        ),
      ),
    );
  }
}
