import 'dart:convert';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class Log {
  static String logFolderPath;
  static RandomAccessFile logFile;

  static void init() async {
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

    setLogCapture(true);
  }

  static void v(String msg, {dynamic ex, StackTrace stacktrace}) {
    Fimber.v(msg, ex: ex, stacktrace: stacktrace);
    _write('v', msg, ex, stacktrace);
  }

  static void d(String msg, {dynamic ex, StackTrace stacktrace}) {
    Fimber.d(msg, ex: ex, stacktrace: stacktrace);
    _write('d', msg, ex, stacktrace);
  }

  static void i(String msg, {dynamic ex, StackTrace stacktrace}) {
    Fimber.i(msg, ex: ex, stacktrace: stacktrace);
    _write('i', msg, ex, stacktrace);
  }

  static void e(String msg, {dynamic ex, StackTrace stacktrace}) {
    Fimber.e(msg, ex: ex, stacktrace: stacktrace);
    _write('e', msg, ex, stacktrace);
  }

  static void w(String msg, {dynamic ex, StackTrace stacktrace}) {
    Fimber.w(msg, ex: ex, stacktrace: stacktrace);
    _write('w', msg, ex, stacktrace);
  }

  static void _write(
    String level,
    String msg,
    dynamic ex,
    StackTrace stackTrace,
  ) {
    if (logFile == null) return;
    var map = <String, dynamic>{
      't': DateTime.now().millisecondsSinceEpoch,
      'l': level,
      'msg': msg.replaceAll('\n', ' '),
      if (ex != null) 'ex': ex.toString().replaceAll('\n', ' '),
      if (stackTrace != null)
        'stack': stackTrace.toString().replaceAll('\n', ' '),
    };
    var str = json.encode(map);
    logFile.writeStringSync(str + '\n');
  }

  static void setLogCapture(bool state) async {
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
}
