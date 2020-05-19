import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gitjournal/utils/logger.dart';

class DebugScreen extends StatefulWidget {
  @override
  _DebugScreenState createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  ScrollController _controller = ScrollController();
  String filterLevel = 'v';

  @override
  void initState() {
    super.initState();

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
        title: Text(tr('settings.debug')),
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
    for (var msg in Log.fetchLogs()) {
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
      child: Text(
        text,
        style: textStyle,
        textAlign: TextAlign.center,
      ),
      padding: const EdgeInsets.all(8.0),
    );
  }

  void _showFilterSelection() async {
    var dialog = AlertDialog(
      title: const Text("Purchase Failed"),
      content: Column(
        children: <Widget>[
          FilterListTile('Error', 'e', filterLevel),
          FilterListTile('Warning', 'w', filterLevel),
          FilterListTile('Info', 'i', filterLevel),
          FilterListTile('Debug', 'd', filterLevel),
          FilterListTile('Verbose', 'v', filterLevel),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
    );
    var l = await showDialog(context: context, builder: (context) => dialog);
    if (l != null) {
      setState(() {
        filterLevel = l;
      });
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
