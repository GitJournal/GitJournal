/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';

import 'package:flutter/foundation.dart' as foundation;

import 'package:fimber/fimber.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:time/time.dart';
import 'package:universal_io/io.dart';

import 'package:gitjournal/apis/githost.dart';

// FIXME: Only catch Exception? type. Something else needs to be done with Errors
class Log {
  static late String logFolderPath;
  static RandomAccessFile? logFile;

  static Future<void> init({bool ignoreFimber = false}) async {
    if (foundation.kDebugMode && !ignoreFimber) {
      Fimber.plantTree(CustomFormatTree(
        logFormat:
            '${CustomFormatTree.levelToken} ${CustomFormatTree.tagToken}: ${CustomFormatTree.messageToken}',
        useColors: true,
      ));
    }

    var cacheDir = await getTemporaryDirectory();
    logFolderPath = p.join(cacheDir.path, "logs");
    try {
      Directory(logFolderPath).createSync();
    } catch (e) {
      // Ignore if it already exists
    }

    await setLogCapture(true);
  }

  static void v(
    String msg, {
    dynamic ex,
    StackTrace? stacktrace,
    Map<String, dynamic>? props,
  }) {
    if (stacktrace != null) {
      stacktrace = Trace.from(stacktrace).terse;
    }

    if (foundation.kDebugMode) {
      Fimber.log("V", msg,
          ex: ex, stacktrace: stacktrace, tag: LogTree.getTag(stackIndex: 2));
    }
    _write('v', msg, ex, stacktrace, props);
  }

  static void d(
    String msg, {
    dynamic ex,
    StackTrace? stacktrace,
    Map<String, dynamic>? props,
  }) {
    if (stacktrace != null) {
      stacktrace = Trace.from(stacktrace).terse;
    }

    if (foundation.kDebugMode) {
      Fimber.log("D", msg,
          ex: ex, stacktrace: stacktrace, tag: LogTree.getTag(stackIndex: 2));
    }
    _write('d', msg, ex, stacktrace, props);
  }

  static void i(
    String msg, {
    dynamic ex,
    StackTrace? stacktrace,
    Map<String, dynamic>? props,
  }) {
    if (stacktrace != null) {
      stacktrace = Trace.from(stacktrace).terse;
    }

    if (foundation.kDebugMode) {
      var debugMsg = msg;
      if (props != null && props.isNotEmpty) {
        debugMsg += " $props";
      }
      Fimber.log("I", debugMsg,
          ex: ex, stacktrace: stacktrace, tag: LogTree.getTag(stackIndex: 2));
    }
    _write('i', msg, ex, stacktrace, props);
  }

  static void e(
    String msg, {
    dynamic ex,
    StackTrace? stacktrace,
    Map<String, dynamic>? props,
    Result? result,
  }) {
    if (result != null) {
      ex ??= result.error;
      stacktrace ??= result.stackTrace;
    }

    if (stacktrace != null) {
      stacktrace = Trace.from(stacktrace).terse;
    }

    if (foundation.kDebugMode) {
      Fimber.log("E", msg + ex.toString() + stacktrace.toString(),
          ex: ex, stacktrace: stacktrace, tag: LogTree.getTag(stackIndex: 2));
    }
    _write('e', msg, ex, stacktrace, props);
  }

  static void w(
    String msg, {
    dynamic ex,
    StackTrace? stacktrace,
    Map<String, dynamic>? props,
  }) {
    if (stacktrace != null) {
      stacktrace = Trace.from(stacktrace).terse;
    }

    if (foundation.kDebugMode) {
      Fimber.log("W", msg,
          ex: ex, stacktrace: stacktrace, tag: LogTree.getTag(stackIndex: 2));
    }
    _write('w', msg, ex, stacktrace, props);
  }

  static void _write(
    String level,
    String msg,
    dynamic ex,
    StackTrace? stackTrace,
    Map<String, dynamic>? props,
  ) {
    if (logFile == null) {
      return;
    }

    var logMsg = LogMessage(
      t: DateTime.now().millisecondsSinceEpoch,
      l: level,
      msg: msg.replaceAll('\n', ' '),
      ex: ex?.toString().replaceAll('\n', ' '),
      props: props,
    );
    if (stackTrace != null) {
      logMsg.stack = stackTrace.toListOfMap();
    }

    var str = json.encode(logMsg.toMap());
    logFile!.writeStringSync(str + '\n');
  }

  static Future<void> setLogCapture(bool state) async {
    if (state) {
      var today = DateTime.now().toString().substring(0, 10);
      var logFilePath = p.join(logFolderPath, '$today.jsonl');
      logFile = await File(logFilePath).open(mode: FileMode.append);
    } else {
      if (logFile != null) {
        await logFile!.close();
      }
      logFile = null;
    }
  }

  static Iterable<LogMessage> fetchLogs() sync* {
    var today = DateTime.now();

    var yesterday = today.add(-1.days);
    for (var msg in fetchLogsForDate(yesterday)) {
      yield msg;
    }

    for (var msg in fetchLogsForDate(today)) {
      yield msg;
    }
  }

  static Iterable<LogMessage> fetchLogsForDate(DateTime date) sync* {
    var file = File(filePathForDate(date));
    if (!file.existsSync()) {
      return;
    }

    var str = file.readAsStringSync();
    for (var line in LineSplitter.split(str)) {
      try {
        yield LogMessage.fromMap(json.decode(line));
      } catch (e) {
        //Log.e("fetchLogsForDate: $e");
      }
    }
  }

  static String filePathForDate(DateTime dt) {
    var date = dt.toString().substring(0, 10);
    return p.join(logFolderPath, '$date.jsonl');
  }

  static List<String> filePathsForDates(int n) {
    var today = DateTime.now();
    var l = <String>[];
    for (var i = 0; i < n; i++) {
      var fp = filePathForDate(today.subtract(i.days));
      if (File(fp).existsSync()) {
        l.add(fp);
      } else {
        Log.i("Log file $fp not found");
      }
    }

    return l;
  }
}

class LogMessage {
  late int t;
  late String l;
  late String msg;
  String? ex;
  List<Map<String, dynamic>>? stack;
  Map<String, dynamic>? props;

  LogMessage({
    required this.t,
    required this.l,
    required this.msg,
    this.ex,
    this.stack,
    this.props,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      't': t,
      'l': l,
      'msg': msg,
      if (ex != null && ex!.isNotEmpty) 'ex': ex,
      if (stack != null) 'stack': stack,
      if (props != null && props!.isNotEmpty) 'p': props,
    };
  }

  // todo: Make sure type conversion doesn't fuck up anything
  LogMessage.fromMap(Map<String, dynamic> map) {
    t = map['t'];
    l = map['l'];
    msg = map['msg'];
    ex = _checkForStringNull(map['ex']);
    stack = _parseJson(map['stack']);
    props = _checkForStringNull(map['p']);
  }
}

List<Map<String, dynamic>>? _parseJson(List<dynamic>? l) {
  if (l == null) {
    return null;
  }

  var list = <Map<String, dynamic>>[];
  for (var i in l) {
    list.add(i);
  }
  return list;
}

dynamic _checkForStringNull(dynamic e) {
  if (e == null) return e;
  if (e.runtimeType == String && e.toString().trim() == 'null') {
    return null;
  }
  return e;
}

extension TraceJsonEncoding on StackTrace {
  List<Map<String, dynamic>> toListOfMap() {
    var list = <Map<String, dynamic>>[];
    for (var f in Trace.from(this).frames) {
      list.add(f.toMap());
    }
    return list;
  }
}

extension FrameJsonEncoding on Frame {
  Map<String, dynamic> toMap() {
    return _removeNull({
      'column': column,
      'uri': uri.toString(),
      'line': line,
      'member': member,
      'isCore': isCore,
      'library': library,
      'location': location,
      'package': package,
    });
  }
}

Map<String, dynamic> _removeNull(Map<String, dynamic> map) {
  map.removeWhere((key, value) => value == null);
  return map;
}
