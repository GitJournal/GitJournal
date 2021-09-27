/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';

import 'package:markdown/markdown.dart' as md;
import 'package:path/path.dart' as p;
import 'package:synchronized/synchronized.dart';

import 'package:gitjournal/core/link.dart';

class LinksLoader {
  Isolate? _isolate;
  final _receivePort = ReceivePort();
  SendPort? _sendPort;

  final _loadingLock = Lock();

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

  Future<List<Link>> parseLinks(
      {required String body, required String filePath}) async {
    await _initIsolate();

    var rec = ReceivePort();
    _sendPort!.send(_LoadingMessage(body, filePath, rec.sendPort));

    var data = await rec.first;
    assert(data is List<Link>);

    return data;
  }
}

class _LoadingMessage {
  String body;
  String filePath;
  SendPort sendPort;

  _LoadingMessage(this.body, this.filePath, this.sendPort);
}

void _isolateMain(SendPort toMainSender) {
  ReceivePort fromMainRec = ReceivePort();
  toMainSender.send(fromMainRec.sendPort);

  var _ = fromMainRec.listen((data) async {
    assert(data is _LoadingMessage);
    var msg = data as _LoadingMessage;

    var links = parseLinks(msg.body, msg.filePath);
    msg.sendPort.send(links);
  });
}

@visibleForTesting
List<Link> parseLinks(String body, String filePath) {
  var parentFolderPath = p.dirname(filePath);

  final doc = md.Document(
    encodeHtml: false,
    extensionSet: md.ExtensionSet.gitHubFlavored,
    inlineSyntaxes: [WikiLinkSyntax()],
  );

  var lines = LineSplitter.split(body).toList();
  var nodes = doc.parseLines(lines);
  var possibleLinks = LinkExtractor(filePath).visit(nodes);

  var links = <Link>[];
  for (var l in possibleLinks) {
    if (l.isWikiLink) {
      links.add(l);
      continue;
    }

    l.filePath = p.join(parentFolderPath, p.normalize(l.filePath!));
    links.add(l);
  }

  doc.linkReferences.forEach((key, value) {
    var path = value.destination;
    if (LinkExtractor.isExternalLink(path)) {
      return;
    }

    var l = Link(publicTerm: value.label, filePath: "", alt: value.title);

    if (path.startsWith('#') || path.startsWith('//')) {
      l.headingID = path;
      l.filePath = filePath;
    } else {
      l.filePath = p.normalize(p.join(parentFolderPath, path));
    }
    links.add(l);
  });

  return links;
}
