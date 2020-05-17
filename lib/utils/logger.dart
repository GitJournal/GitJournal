import 'dart:convert';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class Log {
  static String logFolderPath;
  static RandomAccessFile logFile;

  static Future<void> init() async {
    if (foundation.kDebugMode) {
      Fimber.plantTree(DebugTree.elapsed(useColors: true));
    } else {
      Fimber.plantTree(DebugTree.elapsed(useColors: false));
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
    Fimber.v(msg, ex: ex, stacktrace: stacktrace);
    _write('v', msg, ex, stacktrace, props);
  }

  static void d(String msg,
      {dynamic ex, StackTrace stacktrace, Map<String, dynamic> props}) {
    Fimber.d(msg, ex: ex, stacktrace: stacktrace);
    _write('d', msg, ex, stacktrace, props);
  }

  static void i(String msg,
      {dynamic ex, StackTrace stacktrace, Map<String, dynamic> props}) {
    Fimber.i(msg, ex: ex, stacktrace: stacktrace);
    _write('i', msg, ex, stacktrace, props);
  }

  static void e(String msg,
      {dynamic ex, StackTrace stacktrace, Map<String, dynamic> props}) {
    Fimber.e(msg, ex: ex, stacktrace: stacktrace);
    _write('e', msg, ex, stacktrace, props);
  }

  static void w(String msg,
      {dynamic ex, StackTrace stacktrace, Map<String, dynamic> props}) {
    Fimber.w(msg, ex: ex, stacktrace: stacktrace);
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
    var today = DateTime.now().toString().substring(0, 10);
    for (var msg in fetchLogsForDate(today)) {
      yield msg;
    }
  }

  static Iterable<LogMessage> fetchLogsForDate(String date) sync* {
    var file = File(p.join(logFolderPath, '$date.jsonl'));
    var str = file.readAsStringSync();
    for (var line in LineSplitter.split(str)) {
      try {
        yield LogMessage.fromMap(json.decode(line));
      } catch (e) {
        Log.e(e);
      }
    }
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
