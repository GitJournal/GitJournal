/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:typed_data';

import 'package:markdown/markdown.dart' as md;

import 'generated/markdown.pb.dart' as pb;

class MarkdownCodec {
  static Uint8List encode(List<md.Node> nodes) {
    var pbNodes = pb.NodeList(node: nodes.map(_encode).toList());
    return pbNodes.writeToBuffer();
  }

  static List<md.Node> decode(List<int> bytes) {
    var nodes = pb.NodeList.fromBuffer(bytes);
    return nodes.node.map(_decode).toList();
  }
}

pb.Node _encode(md.Node mdNode) {
  if (mdNode is md.Text) {
    return pb.Node(text: mdNode.text);
  }

  if (mdNode is md.Element) {
    var node = pb.Node(
      element: pb.Element(
        tag: mdNode.tag,
        attributes: mdNode.attributes,
        children: mdNode.children?.map(_encode),
        generatedId: mdNode.generatedId,
      ),
    );
    return node;
  }

  throw Exception("Markdown Node of Invalid Type");
}

md.Node _decode(pb.Node pbNode) {
  if (pbNode.hasText()) {
    return md.Text(pbNode.text);
  }

  if (pbNode.hasElement()) {
    var pbElem = pbNode.element;
    var children = pbElem.children.map(_decode).toList();

    var elem = md.Element(pbElem.tag, children.isEmpty ? null : children);
    elem.attributes.addAll(pbElem.attributes);
    if (pbElem.hasGeneratedId()) {
      elem.generatedId = pbElem.generatedId;
    }
    return elem;
  }

  throw Exception("Markdown Protobuf Node of Invalid Type");
}

// TODO: Use protobuf.omit_field_names?
