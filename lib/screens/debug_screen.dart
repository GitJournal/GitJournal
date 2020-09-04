import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils/logger.dart';

class DebugScreen extends StatefulWidget {
  @override
  _DebugScreenState createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  ScrollController _controller = ScrollController();

  List<LogMessage> _logs;

  @override
  void initState() {
    super.initState();

    _logs = Log.fetchLogs().toList();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToTop() {
    _controller.animateTo(
      _controller.position.minScrollExtent,
      duration: const Duration(milliseconds: 10),
      curve: Curves.easeOut,
    );
  }

  void _scrollToBottom() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 10),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('settings.debug.title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSelection,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_upward),
            onPressed: _scrollToTop,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_downward),
            onPressed: _scrollToBottom,
          ),
        ],
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

  bool _shouldDisplay(LogMessage msg) {
    var settings = Provider.of<Settings>(context);
    var filterLevel = settings.debugLogLevel;

    if (filterLevel == null || filterLevel.isEmpty) {
      return true;
    }

    if (filterLevel == 'v') {
      return true;
    }
    if (filterLevel == 'd' && msg.l == 'v') {
      return false;
    }
    if (filterLevel == 'i' && (msg.l == 'v' || msg.l == 'd')) {
      return false;
    }
    if (filterLevel == 'w' && (msg.l == 'v' || msg.l == 'd' || msg.l == 'i')) {
      return false;
    }
    if (filterLevel == 'e' &&
        (msg.l == 'v' || msg.l == 'd' || msg.l == 'i' || msg.l == 'w')) {
      return false;
    }
    return true;
  }

  Iterable<Widget> _fetchLogWidgets() sync* {
    var prevDate = "";
    for (var msg in _logs) {
      if (!_shouldDisplay(msg)) {
        continue;
      }

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

    return SelectableText.rich(
      TextSpan(children: [
        TextSpan(
            text: timeStr,
            style: textStyle.copyWith(fontWeight: FontWeight.bold)),
        TextSpan(text: str),
        ...props,
      ], style: textStyle),
    );
  }

  Color _colorForLevel(String l) {
    var theme = Theme.of(context);
    switch (l) {
      case 'e':
        return Colors.red;
    }
    return theme.brightness == Brightness.light ? Colors.black : Colors.white;
  }

  Widget _buildDateWidget(DateTime dt) {
    var textStyle = Theme.of(context)
        .textTheme
        .headline6
        .copyWith(fontFamily: "Roboto Mono");

    var text = dt.toIso8601String().substring(0, 10);
    return Padding(
      child: SelectableText(
        text,
        style: textStyle,
        textAlign: TextAlign.center,
      ),
      padding: const EdgeInsets.all(8.0),
    );
  }

  void _showFilterSelection() async {
    var settings = Provider.of<Settings>(context);
    var filterLevel = settings.debugLogLevel;

    var dialog = AlertDialog(
      title: Text(tr('settings.debug.levels.title')),
      content: Column(
        children: <Widget>[
          FilterListTile(tr('settings.debug.levels.error'), 'e', filterLevel),
          FilterListTile(tr('settings.debug.levels.warning'), 'w', filterLevel),
          FilterListTile(tr('settings.debug.levels.info'), 'i', filterLevel),
          FilterListTile(tr('settings.debug.levels.debug'), 'd', filterLevel),
          FilterListTile(tr('settings.debug.levels.verbose'), 'v', filterLevel),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
    );
    var l = await showDialog(context: context, builder: (context) => dialog);
    if (l != null) {
      settings.debugLogLevel = l;
      settings.save();
    }
  }
}

class FilterListTile extends StatelessWidget {
  final String publicLevel;
  final String internalLevel;
  final String currentLevel;

  FilterListTile(this.publicLevel, this.internalLevel, this.currentLevel);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _getIcon(context),
      title: Text(publicLevel),
      onTap: () {
        Navigator.pop(context, internalLevel);
      },
      selected: _isSelected(),
    );
  }

  Icon _getIcon(BuildContext context) {
    var theme = Theme.of(context);
    var color = theme.textTheme.headline6.color;
    if (_isSelected()) {
      switch (theme.brightness) {
        case Brightness.light:
          color = theme.primaryColor;
          break;
        case Brightness.dark:
          color = theme.accentColor;
          break;
      }
    }

    switch (internalLevel) {
      case 'e':
        return Icon(Icons.error, color: color);
      case 'w':
        return Icon(Icons.warning, color: color);
      case 'i':
        return Icon(Icons.info, color: color);
      case 'd':
        return Icon(Icons.bug_report, color: color);
      case 'v':
        return Icon(Icons.all_inclusive, color: color);
    }

    return Icon(Icons.all_inclusive, color: color);
  }

  bool _isSelected() {
    if (currentLevel == 'v') {
      return true;
    }
    if (currentLevel == 'd' && internalLevel == 'v') {
      return false;
    }
    if (currentLevel == 'i' && (internalLevel == 'v' || internalLevel == 'd')) {
      return false;
    }
    if (currentLevel == 'w' &&
        (internalLevel == 'v' ||
            internalLevel == 'd' ||
            internalLevel == 'i')) {
      return false;
    }
    if (currentLevel == 'e' &&
        (internalLevel == 'v' ||
            internalLevel == 'd' ||
            internalLevel == 'i' ||
            internalLevel == 'w')) {
      return false;
    }

    return true;
  }
}
