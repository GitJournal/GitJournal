/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:isolate';

import 'package:function_types/function_types.dart';
import 'package:synchronized/synchronized.dart';

// This doesn't really work properly for all functions
// Waiting for this to merge - https://github.com/dart-lang/sdk/issues/36097
class WorkerQueue<INPUT, OUTPUT> {
  Isolate? _isolate;
  SendPort? _sendPort;

  final _receivePort = ReceivePort();
  final _loadingLock = Lock();

  Func1<INPUT, OUTPUT> func;

  WorkerQueue(this.func);

  Future<void> _initIsolate() async {
    if (_isolate != null && _sendPort != null) return;

    return await _loadingLock.synchronized(() async {
      if (_isolate != null && _sendPort != null) return;
      if (_isolate != null) {
        _isolate!.kill(priority: Isolate.immediate);
        _isolate = null;
      }
      _isolate = await Isolate.spawn(_isolateMain, _receivePort.sendPort);

      var data = await _receivePort.first;
      assert(data is SendPort);
      _sendPort = data as SendPort;
    });
  }

  Future<OUTPUT> call(INPUT input) async {
    await _initIsolate();

    var rec = ReceivePort();
    _sendPort!.send(_LoadingMessage(input, func, rec.sendPort));

    var msg = (await rec.first) as _OutputMessage<OUTPUT>;
    if (msg.output != null) {
      return msg.output!;
    }
    if (msg.exception != null) {
      throw msg.exception!;
    }
    throw msg.error!;
  }
}

class _LoadingMessage<INPUT, OUTPUT> {
  INPUT input;
  SendPort sendPort;
  Func1<INPUT, OUTPUT> func;

  _LoadingMessage(this.input, this.func, this.sendPort);
}

class _OutputMessage<OUTPUT> {
  OUTPUT? output;
  Exception? exception;
  Error? error;

  _OutputMessage({this.output, this.exception, this.error});
}

void _isolateMain(SendPort toMainSender) {
  ReceivePort fromMainRec = ReceivePort();
  toMainSender.send(fromMainRec.sendPort);

  // ignore: cancel_subscriptions
  var _ = fromMainRec.listen((data) async {
    assert(data is _LoadingMessage);
    var msg = data as _LoadingMessage;

    try {
      var output = msg.func(msg.input);
      msg.sendPort.send(_OutputMessage(output: output));
    } on Exception catch (e) {
      msg.sendPort.send(_OutputMessage(exception: e));
    } on Error catch (e) {
      msg.sendPort.send(_OutputMessage(error: e));
    }
  });
}
