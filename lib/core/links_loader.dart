import 'dart:io';
import 'dart:isolate';

import 'package:gitjournal/core/link.dart';
import 'package:synchronized/synchronized.dart';
import 'package:path/path.dart' as p;

import 'package:markdown/markdown.dart' as md;

class LinksLoader {
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
      _isolate = await Isolate.spawn(_isolateMain, _receivePort.sendPort);

      var data = await _receivePort.first;
      assert(data is SendPort);
      _sendPort = data as SendPort;
    });
  }

  Future<List<Link>> parseLinks(String body, String parentFolderPath) async {
    await _initIsolate();

    var rec = ReceivePort();
    _sendPort.send(_LoadingMessage(body, parentFolderPath, rec.sendPort));

    var data = await rec.first;
    assert(data is List<Link>);

    return data;
  }
}

class _LoadingMessage {
  String body;
  String parentFolderPath;
  SendPort sendPort;

  _LoadingMessage(this.body, this.parentFolderPath, this.sendPort);
}

void _isolateMain(SendPort toMainSender) {
  ReceivePort fromMainRec = ReceivePort();
  toMainSender.send(fromMainRec.sendPort);

  fromMainRec.listen((data) async {
    assert(data is _LoadingMessage);
    var msg = data as _LoadingMessage;

    var links = _parseLinks(msg.body, msg.parentFolderPath);
    msg.sendPort.send(links);
  });
}

List<Link> _parseLinks(String body, String parentFolderPath) {
  final doc = md.Document(
    encodeHtml: false,
    extensionSet: md.ExtensionSet.gitHubFlavored,
    inlineSyntaxes: [WikiLinkSyntax()],
  );

  var lines = body.replaceAll('\r\n', '\n').split('\n');
  var nodes = doc.parseLines(lines);
  var possibleLinks = LinkExtractor().visit(nodes);

  var links = <Link>[];
  for (var l in possibleLinks) {
    var path = l.filePath;
    if (path == null) {
      links.add(l);
      continue;
    }

    var isLocal = !path.contains('://');
    if (isLocal) {
      l.filePath = p.join(parentFolderPath, p.normalize(l.filePath));
      links.add(l);
    }
  }

  doc.linkReferences.forEach((key, value) {
    var filePath = value.destination;
    links.add(Link(term: key, filePath: filePath));
  });

  return links;
}
