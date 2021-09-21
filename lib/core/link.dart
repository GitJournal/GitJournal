/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:hive/hive.dart';
import 'package:markdown/markdown.dart' as md;

part 'link.g.dart';

// FIXME: This should be split into 2 classes, that way it would be easier
//        to access to members with null safety

@HiveType(typeId: 0)
class Link {
  @HiveField(0)
  String? publicTerm;

  @HiveField(1)
  String? filePath;

  @HiveField(2)
  String? headingID;

  @HiveField(3)
  String? alt;

  @HiveField(5)
  String? wikiTerm;

  Link({
    required this.publicTerm,
    required this.filePath,
    this.headingID,
    this.alt,
  }) {
    if (publicTerm?.isEmpty == true) {
      publicTerm = null;
    }
    if (headingID?.isEmpty == true) {
      headingID = null;
    }
    if (alt?.isEmpty == true) {
      alt = null;
    }
  }
  Link.wiki(this.wikiTerm);

  bool get isWikiLink => wikiTerm != null;

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
    return wikiTerm != null
        ? 'WikiLink($wikiTerm)'
        : 'Link{publicTerm: $publicTerm, filePath: $filePath, headingID: $headingID, alt: $alt}';
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

        links.add(link);
        return;
      }

      var alt = el.attributes['title'];
      var title = _getText(el.children);

      var url = el.attributes['href'];
      if (url == null || isExternalLink(url)) {
        return;
      }

      if (url.startsWith('#') || url.startsWith('//')) {
        // FIXME: The heading ID seems incorrect
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

  String _getText(List<md.Node>? nodes) {
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
  static const String _pattern = r'\[\[([^\[\]]+)\]\]';

  // In Obsidian style, the link is like [[fileToLinkTo|display text]]
  final bool obsidianStyle;

  WikiLinkSyntax({this.obsidianStyle = true}) : super(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var term = match[1]!.trim();
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
