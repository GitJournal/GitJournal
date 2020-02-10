import 'package:markdown/markdown.dart' as md;

import 'package:gitjournal/core/note.dart';

class ChecklistItem {
  md.Element element;

  bool get checked {
    return element.attributes['checked'] != "false";
  }

  set checked(bool val) {
    element.attributes['checked'] = val.toString();
  }

  String get text {
    return element.attributes['text'];
  }

  set text(String val) {
    element.attributes['text'] = val;
  }

  ChecklistItem.fromMarkdownElement(this.element);

  @override
  String toString() => 'ChecklistItem: $checked $text';
}

class Checklist {
  Note _note;
  List<ChecklistItem> items;
  List<md.Node> nodes;

  Checklist(this._note) {
    var doc = md.Document(
      encodeHtml: false,
      inlineSyntaxes: [TaskListSyntax()],
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );

    nodes = doc.parseInline(_note.body);
    items = ChecklistBuilder().build(nodes);
  }

  Note get note {
    if (nodes.isEmpty) return _note;

    var renderer = CustomRenderer();
    _note.body = renderer.render(nodes);

    return _note;
  }

  @override
  String toString() {
    return [
      '[',
      items.map((x) => x.toString()).join(', '),
      ']',
    ].join(' ');
  }

  void addItem(bool value, String text) {
    var elem = md.Element.withTag("input");
    elem.attributes["type"] = "checkbox";
    elem.attributes["checked"] = value.toString();
    elem.attributes["xUpperCase"] = "false";
    elem.attributes["text"] = text + "\n";

    items.add(ChecklistItem.fromMarkdownElement(elem));
    nodes.add(elem);
  }
}

/// Copied from flutter-markdown - cannot be merged as we added xUpperCase and changed the regexp
/// Parse [task list items](https://github.github.com/gfm/#task-list-items-extension-).
class TaskListSyntax extends md.InlineSyntax {
  // FIXME: Waiting for dart-lang/markdown#269 to land
  static final String _pattern = r'^ *\[([ xX])\] +(.*)$';

  TaskListSyntax() : super(_pattern);

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
    return true;
  }
}

class ChecklistBuilder implements md.NodeVisitor {
  List<ChecklistItem> list;

  @override
  bool visitElementBefore(md.Element element) {
    return true;
  }

  @override
  void visitText(md.Text text) {}

  @override
  void visitElementAfter(md.Element el) {
    final String tag = el.tag;

    if (tag == 'input') {
      if (el is md.Element && el.attributes['type'] == 'checkbox') {
        list.add(ChecklistItem.fromMarkdownElement(el));
      }
    }
  }

  List<ChecklistItem> build(List<md.Node> nodes) {
    list = <ChecklistItem>[];
    for (md.Node node in nodes) {
      node.accept(this);
    }

    return list;
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
            buffer.write('[x] ');
          } else {
            buffer.write('[X] ');
          }
        } else {
          buffer.write('[ ] ');
        }
        buffer.write(el.attributes['text']);
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
