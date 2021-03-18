import 'package:markdown/markdown.dart' as md;
import 'package:meta/meta.dart';

class Link {
  String publicTerm = "";
  String filePath = "";
  String headingID = "";
  String alt = "";

  String wikiTerm = "";

  Link({
    @required this.publicTerm,
    @required this.filePath,
    this.headingID = "",
    this.alt = "",
  });
  Link.wiki(this.wikiTerm);

  bool get isWikiLink => wikiTerm.isNotEmpty;

  @override
  int get hashCode => filePath.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Link &&
          runtimeType == other.runtimeType &&
          filePath == other.filePath &&
          publicTerm == other.publicTerm &&
          wikiTerm == other.wikiTerm &&
          headingID == other.headingID &&
          alt == other.alt;

  @override
  String toString() {
    return wikiTerm.isNotEmpty
        ? 'WikiLink($wikiTerm)'
        : 'Link{publicTerm: $publicTerm, filePath: $filePath, headingID: $headingID}';
  }
}

class LinkExtractor implements md.NodeVisitor {
  final String filePath;
  List<Link> links = [];

  LinkExtractor(this.filePath);

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
      var type = el.attributes['type'] ?? "";
      if (type == "wiki") {
        var term = el.attributes['term'];
        var link = Link.wiki(term);

        assert(link.filePath.isEmpty);
        assert(link.publicTerm.isEmpty);
        assert(link.alt.isEmpty);
        assert(link.headingID.isEmpty);

        links.add(link);
        return;
      }

      var alt = el.attributes['title'] ?? "";
      var title = _getText(el.children);

      var url = el.attributes['href'];
      if (isExternalLink(url)) {
        return;
      }

      if (url.startsWith('#') || url.startsWith('//')) {
        var link = Link(
          publicTerm: title,
          filePath: filePath,
          alt: alt,
          headingID: url,
        );
        links.add(link);
        return;
      }

      var link = Link(publicTerm: title, filePath: url, alt: alt);
      links.add(link);
      return;
    }
  }

  static bool isExternalLink(String url) {
    return url.startsWith(RegExp(r'[A-Za-z]{2,5}:\/\/'));
  }

  List<Link> visit(List<md.Node> nodes) {
    for (final node in nodes) {
      node.accept(this);
    }
    return links;
  }

  String _getText(List<md.Node> nodes) {
    if (nodes == null) {
      return "";
    }

    var text = "";
    for (final node in nodes) {
      if (node is md.Text) {
        text += node.text;
      } else if (node is md.Element) {
        text += _getText(node.children);
      }
    }

    return text;
  }
}

/// Parse [[term]]
class WikiLinkSyntax extends md.InlineSyntax {
  static final String _pattern = r'\[\[([^\[\]]+)\]\]';

  // In Obsidian style, the link is like [[fileToLinkTo|display text]]
  final bool obsidianStyle;

  WikiLinkSyntax({this.obsidianStyle = true}) : super(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var term = match[1].trim();
    var displayText = term;

    if (term.contains('|')) {
      var s = term.split('|');
      if (obsidianStyle) {
        term = s[0].trimRight();
        displayText = s[1].trimLeft();
      } else {
        displayText = s[0].trimRight();
        term = s[1].trimLeft();
      }
    }

    var el = md.Element('a', [md.Text(displayText)]);
    el.attributes['type'] = 'wiki';
    el.attributes['href'] = '[[$term]]';
    el.attributes['term'] = term;

    parser.addNode(el);
    return true;
  }
}
