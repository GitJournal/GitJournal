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

  ChecklistItem buildItem(bool value, String text) {
    var elem = md.Element.withTag("input");
    elem.attributes["type"] = "checkbox";
    elem.attributes["checked"] = value.toString();
    elem.attributes["xUpperCase"] = "false";
    elem.attributes["text"] = text;

    return ChecklistItem.fromMarkdownElement(elem);
  }

  void removeItem(ChecklistItem item) {
    assert(nodes.contains(item.element));
    assert(items.contains(item));

    nodes.remove(item.element);
    items.remove(item);
  }

  ChecklistItem removeAt(int index) {
    assert(index >= 0 && index <= items.length);

    var item = items[index];
    assert(nodes.contains(item.element));

    nodes.remove(item.element);
    items.removeAt(index);

    return item;
  }

  void addItem(ChecklistItem item) {
    items.add(item);
    nodes.add(item.element);
  }

  void insertItem(int index, ChecklistItem item) {
    if (index == 0) {
      items.insert(0, item);
      nodes.insert(0, item.element);
      return;
    }
    if (index == items.length) {
      addItem(item);
      return;
    }

    var prevItem = items[index];
    var nodeIndex = nodes.indexOf(prevItem.element);

    nodes.insert(nodeIndex + 1, item.element);
    items.insert(index, item);
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

class ChecklistBuilder implements md.NodeVisitor {
  List<ChecklistItem> list;

  @override
  bool visitElementBefore(md.Element element) {
    return true;
  }

  @override
  void visitText(md.Text text) {
    //print("builder text: ${text.text}#");
  }

  @override
  void visitElementAfter(md.Element el) {
    final String tag = el.tag;

    if (tag == 'input') {
      if (el is md.Element && el.attributes['type'] == 'checkbox') {
        list.add(ChecklistItem.fromMarkdownElement(el));
      }
    }
    //print("builder tag: $tag");
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
            buffer.write('[x] ');
          } else {
            buffer.write('[X] ');
          }
        } else {
          buffer.write('[ ] ');
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
