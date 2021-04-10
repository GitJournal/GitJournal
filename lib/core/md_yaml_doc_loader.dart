// @dart=2.9

import 'dart:io';
import 'dart:isolate';

import 'package:synchronized/synchronized.dart';

import 'package:gitjournal/core/md_yaml_doc.dart';
import 'package:gitjournal/core/md_yaml_doc_codec.dart';

class MdYamlDocLoader {
  Isolate _isolate;
  ReceivePort _receivePort = ReceivePort();
  SendPort _sendPort;

  var _loadingLock = Lock();

  Future<void> _initIsolate() async {
    if (_isolate != null && _sendPort != null) return;

    return await _loadingLock.synchronized(() async {
      if (_isolate != null && _sendPort != null) return;
      if (_isolate != null) {
        _isolate.kill(priority: Isolate.immediate);
        _isolate = null;
      }
      _isolate = await Isolate.spawn(
        _isolateMain,
        _receivePort.sendPort,
        errorsAreFatal: false,
      );

      var data = await _receivePort.first;
      assert(data is SendPort);
      _sendPort = data as SendPort;
    });
  }

  Future<MdYamlDoc> loadDoc(String filePath) async {
    await _initIsolate();

    final file = File(filePath);
    if (!file.existsSync()) {
      throw MdYamlDocNotFoundException(filePath);
    }

    var rec = ReceivePort();
    _sendPort.send(_LoadingMessage(filePath, rec.sendPort));

    var data = await rec.first;
    assert(data is _LoaderResponse);
    var resp = data as _LoaderResponse;
    assert(resp.filePath == filePath);

    if (resp.doc != null) {
      return resp.doc;
    }

    throw MdYamlParsingException(filePath, resp.err.toString());
  }
}

class _LoadingMessage {
  String filePath;
  SendPort sendPort;

  _LoadingMessage(this.filePath, this.sendPort);
}

void _isolateMain(SendPort toMainSender) {
  ReceivePort fromMainRec = ReceivePort();
  toMainSender.send(fromMainRec.sendPort);

  final _serializer = MarkdownYAMLCodec();

  fromMainRec.listen((data) async {
    assert(data is _LoadingMessage);
    var msg = data as _LoadingMessage;

    try {
      final file = File(msg.filePath);
      final fileData = await file.readAsString();
      var doc = _serializer.decode(fileData);

      msg.sendPort.send(_LoaderResponse(msg.filePath, doc));
    } catch (err) {
      msg.sendPort.send(_LoaderResponse(msg.filePath, null, err.toString()));
    }
  });
}

class _LoaderResponse {
  final String filePath;
  final MdYamlDoc doc;
  final String err;

  _LoaderResponse(this.filePath, this.doc, [this.err]);
}

class MdYamlDocNotFoundException implements Exception {
  final String filePath;
  MdYamlDocNotFoundException(this.filePath);

  @override
  String toString() => "MdYamlDocNotFoundException: $filePath";
}

class MdYamlParsingException implements Exception {
  final String filePath;
  final String error;

  MdYamlParsingException(this.filePath, this.error);

  @override
  String toString() => "MdYamlParsingException: $filePath - $error";
}
