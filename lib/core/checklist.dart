import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;

import 'package:gitjournal/core/note.dart';

class ChecklistItem {
  bool checked;
  String text;
  md.Element element;

  ChecklistItem({
    @required this.checked,
    @required this.text,
    @required this.element,
  });

  @override
  String toString() => 'ChecklistItem: $checked $text';
}

class Checklist {
  Note note;
  List<ChecklistItem> items;

  Checklist(this.note) {
    items = ChecklistBuilder().parse(note.body);
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
  void visitElementAfter(md.Element element) {
    final String tag = element.tag;

    if (tag == 'input') {
      var el = element;
      if (el is md.Element && el.attributes['type'] == 'checkbox') {
        bool val = el.attributes['checked'] != 'false';
        var item = ChecklistItem(
          checked: val,
          text: el.attributes['text'],
          element: el,
        );
        list.add(item);
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

  List<ChecklistItem> parse(String text) {
    var doc = md.Document(
      encodeHtml: false,
      inlineSyntaxes: [TaskListSyntax()],
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );

    var nodes = doc.parseInline(text);
    return build(nodes);
  }
}
