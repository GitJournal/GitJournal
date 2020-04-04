import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart' as foundation;

class Log {
  static void init() {
    if (foundation.kDebugMode) {
      Fimber.plantTree(DebugTree.elapsed(useColors: true));
    } else {
      Fimber.plantTree(DebugTree.elapsed(useColors: false));
    }
  }

  static void v(String msg, {dynamic ex, StackTrace stacktrace}) {
    Fimber.v(msg, ex: ex, stacktrace: stacktrace);
  }

  static void d(String msg, {dynamic ex, StackTrace stacktrace}) {
    Fimber.d(msg, ex: ex, stacktrace: stacktrace);
  }

  static void i(String msg, {dynamic ex, StackTrace stacktrace}) {
    Fimber.i(msg, ex: ex, stacktrace: stacktrace);
  }

  static void e(String msg, {dynamic ex, StackTrace stacktrace}) {
    Fimber.e(msg, ex: ex, stacktrace: stacktrace);
  }

  static void w(String msg, {dynamic ex, StackTrace stacktrace}) {
    Fimber.w(msg, ex: ex, stacktrace: stacktrace);
  }
}
