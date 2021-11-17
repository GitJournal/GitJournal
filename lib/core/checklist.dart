/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/error_reporting.dart';

class ChecklistItem {
  bool checked;
  String text;

  String? pre;
  bool upperCase;
  int lineNo;

  ChecklistItem({
    required this.checked,
    required this.text,
    this.pre = '',
    this.upperCase = false,
    this.lineNo = -1,
  });

  @override
  String toString() => '$pre- [$_x] $text';

  String get _x => checked
      ? upperCase
          ? 'X'
          : 'x'
      : ' ';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChecklistItem &&
          runtimeType == other.runtimeType &&
          checked == other.checked &&
          text == other.text &&
          pre == other.pre &&
          upperCase == other.upperCase &&
          lineNo == other.lineNo;

  @override
  int get hashCode => text.hashCode ^ pre.hashCode ^ checked.hashCode;
}

class Checklist {
  static final _pattern = RegExp(
    r'^(.*)- \[([ xX])\] ?(.*)$',
    multiLine: false,
  );

  // FIXME: Added on 2020-05-01: Remove after 3-4 months
  static final _oldPattern = RegExp(
    r'^ *\[([ xX])\] +(.*)$',
    multiLine: false,
  );

  final Note _note;
  List<ChecklistItem> items = [];

  late List<String> _lines;
  late bool endsWithNewLine;

  Checklist(this._note) {
    _lines = LineSplitter.split(_note.body).toList();
    endsWithNewLine = _note.body.endsWith('\n');

    for (var i = 0; i < _lines.length; i++) {
      var line = _lines[i];
      var oldPatMatch = _oldPattern.firstMatch(line);
      if (oldPatMatch != null) {
        line = '- ' + line;
      }

      var match = _pattern.firstMatch(line);
      if (match == null) {
        continue;
      }

      var pre = match.group(1);
      var state = match.group(2);
      var post = match.group(3)!;

      var item = ChecklistItem(
        pre: pre,
        checked: state != ' ',
        upperCase: state == 'X',
        text: post,
        lineNo: i,
      );
      items.add(item);
    }
  }

  Note get note {
    for (var item in items) {
      _lines[item.lineNo] = item.toString();
    }
    var body = _lines.join('\n');
    if (endsWithNewLine) {
      body += '\n';
    }
    _note.apply(body: body);
    return _note;
  }

  @override
  String toString() {
    return [
      '[',
      items.map((x) => x.toString()).join(', '),
      ']',
    ].join(' ');
  }

  ChecklistItem buildItem(bool value, String text) {
    var item = ChecklistItem(checked: value, text: text);
    return item;
  }

  void removeItem(ChecklistItem item) {
    assert(items.contains(item));

    var i = items.indexOf(item);
    assert(i != -1);
    if (i == -1) {
      logException(
        Exception('Checklist removeItem does not exist'),
        StackTrace.current,
      );
      return;
    }

    var _ = removeAt(i);
  }

  ChecklistItem removeAt(int index) {
    assert(index >= 0 && index <= items.length);
    dynamic _;

    var item = items[index];
    _ = items.removeAt(index);
    _ = _lines.removeAt(item.lineNo);
    for (var j = index; j < items.length; j++) {
      items[j].lineNo -= 1;
    }

    return item;
  }

  void addItem(ChecklistItem item) {
    assert(item.lineNo == -1);

    if (items.isEmpty) {
      item.lineNo = _lines.length;
      items.add(item);
      _lines.add(item.toString());
      return;
    }

    var prevItem = items.last;
    item.lineNo = prevItem.lineNo + 1;
    items.add(item);
    _lines.insert(item.lineNo, item.toString());
  }

  void insertItem(int index, ChecklistItem item) {
    assert(index <= items.length);
    if (index == 0 && items.isEmpty) {
      addItem(item);
      return;
    }

    if (index == 0) {
      var nextItem = items[0];
      item.lineNo = nextItem.lineNo;
      _lines.insert(item.lineNo, item.toString());

      for (var item in items) {
        item.lineNo++;
      }
      items.insert(0, item);
      return;
    }

    if (index >= items.length) {
      var prevItem = items.last;
      item.lineNo = prevItem.lineNo + 1;
      items.add(item);
      _lines.insert(item.lineNo, item.toString());
      return;
    }

    var prevItem = items[index];
    item.lineNo = prevItem.lineNo;
    _lines.insert(item.lineNo, item.toString());

    for (var i = index; i < items.length; i++) {
      items[i].lineNo++;
    }
    items.insert(index, item);
  }
}
