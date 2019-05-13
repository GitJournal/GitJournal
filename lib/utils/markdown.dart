import 'dart:core';

import 'package:markdown/markdown.dart' as md;

/// Builds a plain text [String] from parsed Markdown.
class MarkdownBuilder implements md.NodeVisitor {
  List<String> _texts = [];

  String build(List<md.Node> nodes) {
    _texts.clear();

    for (md.Node node in nodes) {
      node.accept(this);
    }

    var stringBuffer = StringBuffer();
    _texts.forEach((String text) {
      var t = text.trim();
      if (t.isNotEmpty) {
        t = t.replaceAll('\n', ' ');
        t = t.trim();
        stringBuffer.write(t);
        stringBuffer.write(' ');
      }
    });

    var str = stringBuffer.toString();
    return str.substring(0, str.length - 1);
  }

  @override
  void visitText(md.Text text) {
    _texts.add(text.text);
  }

  @override
  bool visitElementBefore(md.Element element) {
    return true;
  }

  @override
  void visitElementAfter(md.Element element) {
    return;
  }
}

String stripMarkdownFormatting(String markdown) {
  final List<String> lines = markdown.replaceAll('\r\n', '\n').split('\n');
  var doc = md.Document(encodeHtml: false);

  final MarkdownBuilder builder = MarkdownBuilder();
  return builder.build(doc.parseLines(lines));
}
