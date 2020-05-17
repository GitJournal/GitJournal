import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gitjournal/utils/logger.dart';

class DebugScreen extends StatefulWidget {
  @override
  _DebugScreenState createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeOut,
      );
    });
  }

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
      body: Scrollbar(
        child: ListView(
          controller: _controller,
          children: <Widget>[
            ..._fetchLogWidgets(),
          ],
          padding: const EdgeInsets.all(16.0),
        ),
      ),
    );
  }

  Iterable<Widget> _fetchLogWidgets() sync* {
    var prevDate = "";
    for (var msg in Log.fetchLogs()) {
      var dt = DateTime.fromMillisecondsSinceEpoch(msg.t);
      var date = dt.toIso8601String().substring(0, 10);
      if (date != prevDate) {
        yield _buildDateWidget(dt);
        prevDate = date;
      }

      yield _buildLogWidget(msg);
    }
  }

  Widget _buildLogWidget(LogMessage msg) {
    var textStyle = Theme.of(context)
        .textTheme
        .bodyText2
        .copyWith(fontFamily: "Roboto Mono");

    textStyle = textStyle.copyWith(color: _colorForLevel(msg.l));

    var dt = DateTime.fromMillisecondsSinceEpoch(msg.t);
    var timeStr = dt.toIso8601String().substring(11, 11 + 8);
    var str = ' ' + msg.msg;

    if (msg.ex != null) {
      str += ' ' + msg.ex;
    }
    if (msg.stack != null) {
      str += ' ' + msg.stack;
    }

    var props = <TextSpan>[];
    msg.props?.forEach((key, value) {
      var emptySpace = TextSpan(
          text: '\n         ',
          style: textStyle.copyWith(fontWeight: FontWeight.bold));
      props.add(emptySpace);

      var keySpan = TextSpan(
        text: '$key: ',
        style: textStyle.copyWith(
          fontWeight: FontWeight.bold,
        ),
      );
      var valueSpan = TextSpan(text: value.toString());

      props.add(keySpan);
      props.add(valueSpan);
    });

    return RichText(
      text: TextSpan(children: [
        TextSpan(
            text: timeStr,
            style: textStyle.copyWith(fontWeight: FontWeight.bold)),
        TextSpan(text: str),
        ...props,
      ], style: textStyle),
    );
  }

  Color _colorForLevel(String l) {
    switch (l) {
      case 'e':
        return Colors.red;
    }
    return Colors.black;
  }

  Widget _buildDateWidget(DateTime dt) {
    var textStyle = Theme.of(context)
        .textTheme
        .headline6
        .copyWith(fontFamily: "Roboto Mono");

    var text = dt.toIso8601String().substring(0, 10);
    return Padding(
      child: Text(
        text,
        style: textStyle,
        textAlign: TextAlign.center,
      ),
      padding: const EdgeInsets.all(8.0),
    );
  }
}
