import 'package:markdown/markdown.dart' as md;

import 'package:gitjournal/core/note.dart';

class ChecklistLegacyMigrator {
  Note _note;
  List<md.Node> nodes;

  ChecklistLegacyMigrator(this._note) {
    var doc = md.Document(
      encodeHtml: false,
      inlineSyntaxes: [TaskListSyntax()],
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );

    nodes = doc.parseInline(_note.body);
    _cleanupNodes(nodes);
  }

  void _cleanupNodes(List<md.Node> nodes) {
    if (nodes.length <= 1) {
      return;
    }

    var last = nodes.last;
    var secLast = nodes[nodes.length - 2];

    if (last is! md.Text) {
      return;
    }
    if (secLast is! md.Element) {
      return;
    }
    var elem = secLast as md.Element;
    if (elem.tag != 'input' || elem.attributes['type'] != 'checkbox') {
      return;
    }

    // Some times we get an extra \n in the end, not sure why.
    if (last.textContent == '\n') {
      nodes.length = nodes.length - 1;
      if (!elem.attributes["text"].endsWith('\n')) {
        elem.attributes["text"] += '\n';
      }
    }
  }

  Note get note {
    if (nodes.isEmpty) return _note;

    var renderer = CustomRenderer();
    _note.body = renderer.render(nodes);

    return _note;
  }
}

/// Copied from flutter-markdown - cannot be merged as we added xUpperCase and changed the regexp
/// Parse [task list items](https://github.github.com/gfm/#task-list-items-extension-).
class TaskListSyntax extends md.InlineSyntax {
  // FIXME: Waiting for dart-lang/markdown#269 to land
  static final String _pattern = r'^ *\[([ xX])\] +(.*)';

  TaskListSyntax() : super(_pattern, startCharacter: '['.codeUnitAt(0));

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    md.Element el = md.Element.withTag('input');
    el.attributes['type'] = 'checkbox';
    el.attributes['checked'] = '${match[1].trim().isNotEmpty}';
    var m = match[1].trim();
    if (m.isNotEmpty) {
      el.attributes['xUpperCase'] = (m[0] == 'X').toString();
    }
    el.attributes['text'] = '${match[2]}';
    parser.addNode(el);

    var lenToConsume = match[0].length;
    if (match.end + 1 < match.input.length) {
      lenToConsume += 1; // Consume \n
    }
    parser.consume(lenToConsume);
    return false; // We are advancing manually
  }
}

class CustomRenderer implements md.NodeVisitor {
  StringBuffer buffer;

  @override
  bool visitElementBefore(md.Element element) {
    return true;
  }

  @override
  void visitText(md.Text text) {
    //print("visitText ${text.text}#");
    buffer.write(text.text);
  }

  @override
  void visitElementAfter(md.Element element) {
    final String tag = element.tag;

    if (tag == 'input') {
      var el = element;
      if (el is md.Element && el.attributes['type'] == 'checkbox') {
        bool val = el.attributes['checked'] != 'false';
        if (val) {
          if (el.attributes['xUpperCase'] != 'false') {
            buffer.write('- [x] ');
          } else {
            buffer.write('- [X] ');
          }
        } else {
          buffer.write('- [ ] ');
        }
        var text = el.attributes['text'];
        buffer.write(text);
        //print("writeElem $text#");
        if (!text.endsWith('\n')) {
          //print("writeElem newLine#");
          buffer.write('\n');
        }
      }
    }
  }

  String render(List<md.Node> nodes) {
    buffer = StringBuffer();

    for (final node in nodes) {
      node.accept(this);
    }
    return buffer.toString();
  }
}
