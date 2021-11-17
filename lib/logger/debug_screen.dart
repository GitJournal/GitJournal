/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:time/time.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:gitjournal/utils/utils.dart';

class DebugScreen extends StatefulWidget {
  static const routePath = '/settings/debug';

  const DebugScreen({Key? key}) : super(key: key);

  @override
  _DebugScreenState createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final ScrollController _controller = ScrollController();

  late List<LogMessage> _logs;

  @override
  void initState() {
    super.initState();

    _logs = Log.fetchLogs().toList();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToTop() {
    _controller.animateTo(
      _controller.position.minScrollExtent,
      duration: 10.milliseconds,
      curve: Curves.easeOut,
    );
  }

  void _scrollToBottom() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: 10.milliseconds,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(LocaleKeys.settings_debug_title)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyToClipboard,
          ),
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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 1000.0,
            child: ListView(
              controller: _controller,
              children: <Widget>[
                ..._fetchLogWidgets(),
              ],
              padding: const EdgeInsets.all(16.0),
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldDisplay(LogMessage msg) {
    var appConfig = Provider.of<AppConfig>(context);
    var filterLevel = appConfig.debugLogLevel;

    if (filterLevel.isEmpty) {
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

  Future<void> _copyToClipboard() async {
    var messages = <String>[];
    for (var logMsg in _logs) {
      var msg = json.encode(logMsg.toMap());
      messages.add(msg);
    }

    Clipboard.setData(ClipboardData(text: messages.join('\n')));
    showSnackbar(context, tr(LocaleKeys.settings_debug_copy));
  }

  Widget _buildLogWidget(LogMessage msg) {
    var origTextStyle = Theme.of(context)
        .textTheme
        .bodyText2!
        .copyWith(fontFamily: "Roboto Mono");

    var textStyle = origTextStyle.copyWith(color: _colorForLevel(msg.l));

    var dt = DateTime.fromMillisecondsSinceEpoch(msg.t);
    var timeStr = dt.toIso8601String().substring(11, 11 + 8);
    var str = ' ' + msg.msg;

    var props = <TextSpan>[];
    msg.props?.forEach((key, value) {
      var emptySpace = TextSpan(
          text: '\n           ',
          style: textStyle.copyWith(fontWeight: FontWeight.bold));
      props.add(emptySpace);

      var keySpan = TextSpan(
        text: '$key: ',
        style: textStyle.copyWith(
          fontWeight: FontWeight.w600,
        ),
      );
      var valueSpan = TextSpan(text: value.toString());

      props.add(keySpan);
      props.add(valueSpan);
    });

    var errorSpans = <TextSpan>[];
    if (msg.ex != null) {
      var emptySpace = TextSpan(
          text: '\n         ',
          style: origTextStyle.copyWith(fontWeight: FontWeight.bold));

      var exSpan = TextSpan(
        text: '${msg.ex}',
        style: textStyle.copyWith(
          fontWeight: FontWeight.bold,
        ),
      );

      errorSpans.add(emptySpace);
      errorSpans.add(exSpan);
    }

    if (msg.stack != null) {
      var emptySpace = TextSpan(
          text: '\n           ',
          style: textStyle.copyWith(fontWeight: FontWeight.bold));

      var largestMemberLength = 0;
      for (var entry in msg.stack!) {
        var member = entry['member'];
        if (member != null && member is String) {
          if (member.length > largestMemberLength) {
            largestMemberLength = member.length;
          }
        }
      }

      for (var entry in msg.stack!) {
        var member = entry['member'];
        if (member != null) {
          var exSpan = TextSpan(
            text: '$member'.padRight(largestMemberLength),
            style: origTextStyle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          );

          errorSpans.add(emptySpace);
          errorSpans.add(exSpan);
        }

        var location = entry['location'];
        if (location != null && location is String) {
          const prefix = 'package:';
          if (location.startsWith(prefix)) {
            location = location.substring(prefix.length);
          }
          var locSpan = TextSpan(
            text: ' - $location',
            style: origTextStyle,
          );

          // errorSpans.add(emptySpace);
          errorSpans.add(locSpan);
        }
      }
    }

    return SelectableText.rich(
      TextSpan(children: [
        TextSpan(
            text: timeStr,
            style: textStyle.copyWith(fontWeight: FontWeight.bold)),
        TextSpan(text: str),
        ...props,
        ...errorSpans,
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
        .headline6!
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

  Future<void> _showFilterSelection() async {
    var appConfig = Provider.of<AppConfig>(context);
    var filterLevel = appConfig.debugLogLevel;

    var dialog = AlertDialog(
      title: Text(tr(LocaleKeys.settings_debug_levels_title)),
      content: Column(
        children: <Widget>[
          FilterListTile(
              tr(LocaleKeys.settings_debug_levels_error), 'e', filterLevel),
          FilterListTile(
              tr(LocaleKeys.settings_debug_levels_warning), 'w', filterLevel),
          FilterListTile(
              tr(LocaleKeys.settings_debug_levels_info), 'i', filterLevel),
          FilterListTile(
              tr(LocaleKeys.settings_debug_levels_debug), 'd', filterLevel),
          FilterListTile(
              tr(LocaleKeys.settings_debug_levels_verbose), 'v', filterLevel),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
    );
    var l = await showDialog(context: context, builder: (context) => dialog);
    if (l != null) {
      appConfig.debugLogLevel = l;
      appConfig.save();
    }
  }
}

class FilterListTile extends StatelessWidget {
  final String publicLevel;
  final String internalLevel;
  final String currentLevel;

  const FilterListTile(
    this.publicLevel,
    this.internalLevel,
    this.currentLevel, {
    Key? key,
  }) : super(key: key);

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
    var color = theme.textTheme.headline6!.color;
    if (_isSelected()) {
      switch (theme.brightness) {
        case Brightness.light:
          color = theme.primaryColor;
          break;
        case Brightness.dark:
          color = theme.colorScheme.secondary;
          break;
      }
    }

    switch (internalLevel) {
      case 'e':
        return Icon(Icons.report, color: color);
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
