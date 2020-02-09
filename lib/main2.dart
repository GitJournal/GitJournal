import 'package:markdown/markdown.dart' as md;

var text = """# Title 1

How are you doing?

[ ] item 1
[x] item 2
[X] item 3
[ ] item 4

Booga Wooga""";

void main() {
  var doc = md.Document(
    encodeHtml: false,
    inlineSyntaxes: [TaskListSyntax()],
    extensionSet: md.ExtensionSet.gitHubWeb,
  );

  final MarkdownBuilder builder = MarkdownBuilder();
  var nodes = doc.parseInline(text);
  var elems = builder.build(nodes);
  elems[0].attributes['checked'] = 'true';

  var renderer = CustomRenderer();
  var output = renderer.render(nodes);
  print(output);
}

/// Parse [task list items](https://github.github.com/gfm/#task-list-items-extension-).
class TaskListSyntax extends md.InlineSyntax {
  // FIXME: Waiting for dart-lang/markdown#269 to land
  static final String _pattern = r'^ *\[([ xX])\] +';

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
    parser.addNode(el);
    return true;
  }
}

class MarkdownBuilder implements md.NodeVisitor {
  List<md.Element> list;

  @override
  bool visitElementBefore(md.Element element) {
    return true;
  }

  @override
  void visitText(md.Text text) {
    print("text: ${text.text}");
  }

  @override
  void visitElementAfter(md.Element element) {
    final String tag = element.tag;

    print("Tag: $tag");
    if (tag == 'input') {
      var el = element;
      if (el is md.Element && el.attributes['type'] == 'checkbox') {
        bool val = el.attributes['checked'] != 'false';
        print("VAL $val");
        list.add(el);
      }
    }
  }

  List<md.Element> build(List<md.Node> nodes) {
    print("---build---");
    list = <md.Element>[];
    for (md.Node node in nodes) {
      node.accept(this);
    }
    print("---build---");

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
    print("text: ${text.text}");
  }

  @override
  void visitElementAfter(md.Element element) {
    final String tag = element.tag;

    print("Tag: $tag");
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
        print("VAL $val");
      }
    }
  }

  String render(List<md.Node> nodes) {
    print("---render---");
    buffer = StringBuffer();

    for (final node in nodes) {
      node.accept(this);
    }

    print("---render---");
    return buffer.toString();
  }
}
