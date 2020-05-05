import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gitjournal/utils/logger.dart';

class DebugScreen extends StatefulWidget {
  @override
  _DebugScreenState createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('settings.debug')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        children: <Widget>[
          for (var msg in Log.fetchLogs()) _buildLogWidget(msg),
        ],
      ),
    );
  }

  Widget _buildLogWidget(LogMessage msg) {
    var textStyle = Theme.of(context).textTheme.subhead;
    textStyle = textStyle.copyWith(color: _colorForLevel(msg.l));

    var str = DateTime.fromMillisecondsSinceEpoch(msg.t).toIso8601String() +
        ' ' +
        msg.msg;

    if (msg.ex != null) {
      str += ' ' + msg.ex;
    }
    if (msg.stack != null) {
      str += ' ' + msg.stack;
    }
    return Text(str, style: textStyle);
  }

  Color _colorForLevel(String l) {
    switch (l) {
      case 'e':
        return Colors.red;
    }
    return Colors.black;
  }
}
