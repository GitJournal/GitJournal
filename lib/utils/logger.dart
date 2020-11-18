import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' as foundation;

import 'package:fimber/fimber.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:time/time.dart';

class Log {
  static String logFolderPath;
  static RandomAccessFile logFile;

  static Future<void> init() async {
    if (foundation.kDebugMode) {
      Fimber.plantTree(DebugTree.elapsed(useColors: true));
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

  static void v(String msg,
      {dynamic ex, StackTrace stacktrace, Map<String, dynamic> props}) {
    stacktrace = Trace.from(stacktrace).terse;

    if (foundation.kDebugMode) {
      Fimber.log("V", msg,
          ex: ex, stacktrace: stacktrace, tag: LogTree.getTag(stackIndex: 2));
    }
    _write('v', msg, ex, stacktrace, props);
  }

  static void d(String msg,
      {dynamic ex, StackTrace stacktrace, Map<String, dynamic> props}) {
    stacktrace = Trace.from(stacktrace).terse;

    if (foundation.kDebugMode) {
      Fimber.log("D", msg,
          ex: ex, stacktrace: stacktrace, tag: LogTree.getTag(stackIndex: 2));
    }
    _write('d', msg, ex, stacktrace, props);
  }

  static void i(String msg,
      {dynamic ex, StackTrace stacktrace, Map<String, dynamic> props}) {
    stacktrace = Trace.from(stacktrace).terse;

    if (foundation.kDebugMode) {
      Fimber.log("I", msg,
          ex: ex, stacktrace: stacktrace, tag: LogTree.getTag(stackIndex: 2));
    }
    _write('i', msg, ex, stacktrace, props);
  }

  static void e(String msg,
      {dynamic ex, StackTrace stacktrace, Map<String, dynamic> props}) {
    stacktrace = Trace.from(stacktrace).terse;

    if (foundation.kDebugMode) {
      Fimber.log("E", msg,
          ex: ex, stacktrace: stacktrace, tag: LogTree.getTag(stackIndex: 2));
    }
    _write('e', msg, ex, stacktrace, props);
  }

  static void w(String msg,
      {dynamic ex, StackTrace stacktrace, Map<String, dynamic> props}) {
    stacktrace = Trace.from(stacktrace).terse;

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
    StackTrace stackTrace,
    Map<String, dynamic> props,
  ) {
    if (logFile == null) {
      return;
    }

    var logMsg = LogMessage(
      t: DateTime.now().millisecondsSinceEpoch,
      l: level,
      msg: msg.replaceAll('\n', ' '),
      ex: ex != null ? ex.toString().replaceAll('\n', ' ') : null,
      stack: stackTrace != null
          ? stackTrace.toString().replaceAll('\n', ' ')
          : null,
      props: props,
    );

    var str = json.encode(logMsg.toMap());
    logFile.writeStringSync(str + '\n');
  }

  static Future<void> setLogCapture(bool state) async {
    if (state) {
      var today = DateTime.now().toString().substring(0, 10);
      var logFilePath = p.join(logFolderPath, '$today.jsonl');
      logFile = await File(logFilePath).open(mode: FileMode.append);
      print("Writing logs to file $logFilePath");
    } else {
      if (logFile != null) {
        await logFile.close();
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
      Log.i("No log file for $date");
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
  int t;
  String l;
  String msg;
  String ex;
  String stack;
  Map<String, dynamic> props;

  LogMessage({
    @required this.t,
    @required this.l,
    @required this.msg,
    this.ex,
    this.stack,
    this.props,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      't': t,
      'l': l,
      'msg': msg,
      if (ex != null && ex.isNotEmpty) 'ex': ex,
      if (stack != null && stack.isNotEmpty) 'stack': stack,
      if (props != null && props.isNotEmpty) 'p': props,
    };
  }

  LogMessage.fromMap(Map<String, dynamic> map) {
    t = map['t'];
    l = map['l'];
    msg = map['msg'];
    ex = map['ex'];
    stack = map['stack'];
    props = map['p'];
  }
}
