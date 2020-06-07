import 'package:meta/meta.dart';
import 'package:markdown/markdown.dart' as md;

class Link {
  String term;
  String filePath;

  Link({@required this.term, @required this.filePath});

  @override
  int get hashCode => filePath.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Link &&
          runtimeType == other.runtimeType &&
          filePath == other.filePath;

  @override
  String toString() {
    return 'Link{term: $term, filePath: $filePath}';
  }
}

class LinkExtractor implements md.NodeVisitor {
  List<Link> links = [];

  @override
  bool visitElementBefore(md.Element element) {
    return true;
  }

  @override
  void visitText(md.Text text) {}

  @override
  void visitElementAfter(md.Element el) {
    final String tag = el.tag;

    if (tag == 'a') {
      var title = el.attributes['title'] ?? "";
      if (title.isEmpty) {
        for (var child in el.children) {
          if (child is md.Text) {
            title += child.text;
          }
        }
      }

      var url = el.attributes['href'];
      var link = Link(term: title, filePath: url);
      links.add(link);
    }
  }

  List<Link> visit(List<md.Node> nodes) {
    for (final node in nodes) {
      node.accept(this);
    }
    return links;
  }
}
