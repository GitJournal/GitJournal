import 'package:markdown/markdown.dart';
import 'package:markdown/markdown.dart' as md;

var text = """# Title 1

How are you doing?

[ ] item 1
[x] item 2
[X] item 3
[ ] item 4

Booga Wooga""";

void main() {
  print(markdownToHtml(
    text,
    extensionSet: ExtensionSet.gitHubWeb,
    inlineSyntaxes: [TaskListSyntax()],
  ));

  var doc = md.Document(
    encodeHtml: false,
    inlineSyntaxes: [TaskListSyntax()],
    extensionSet: ExtensionSet.gitHubWeb,
  );

  final MarkdownBuilder builder = MarkdownBuilder();
  builder.build(doc.parseInline(text));
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
    el.attributes['disabled'] = 'true';
    el.attributes['checked'] = '${match[1].trim().isNotEmpty}';
    parser.addNode(el);
    return true;
  }
}

class MarkdownBuilder implements md.NodeVisitor {
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
      }
    }
  }

  String build(List<md.Node> nodes) {
    print("---build---");
    for (md.Node node in nodes) {
      node.accept(this);
    }
    print("---build---");

    return "";
  }
}
