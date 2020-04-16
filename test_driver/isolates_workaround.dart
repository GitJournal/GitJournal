import 'dart:async';

import 'package:flutter_driver/flutter_driver.dart';

/// Workaround for bug: https://github.com/flutter/flutter/issues/24703
///
/// USAGE
///
/// ```
/// FlutterDriver driver;
/// IsolatesWorkaround workaround;
///
/// setUpAll(() async {
///   driver = await FlutterDriver.connect();
///   workaround = IsolatesWorkaround(driver);
///   await workaround.resumeIsolates();
/// });
///
/// tearDownAll(() async {
///   if (driver != null) {
///     await driver.close();
///     await workaround.tearDown();
///   }
/// });
/// ```
class IsolatesWorkaround {
  IsolatesWorkaround(this._driver, {this.log = false});
  final FlutterDriver _driver;
  final bool log;
  StreamSubscription _streamSubscription;

  /// workaround for isolates
  /// https://github.com/flutter/flutter/issues/24703
  Future<void> resumeIsolates() async {
    final vm = await _driver.serviceClient.getVM();
    // // unpause any paused isolated
    for (final isolateRef in vm.isolates) {
      final isolate = await isolateRef.load();
      if (isolate.isPaused) {
        isolate.resume();
        if (log) {
          print("Resuming isolate: ${isolate.numberAsString}:${isolate.name}");
        }
      }
    }
    if (_streamSubscription != null) {
      return;
    }
    _streamSubscription = _driver.serviceClient.onIsolateRunnable
        .asBroadcastStream()
        .listen((isolateRef) async {
      final isolate = await isolateRef.load();
      if (isolate.isPaused) {
        isolate.resume();
        if (log) {
          print("Resuming isolate: ${isolate.numberAsString}:${isolate.name}");
        }
      }
    });
  }

  Future<void> tearDown() async {
    if (_streamSubscription != null) {
      await _streamSubscription.cancel();
    }
  }
}
