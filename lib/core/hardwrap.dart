import 'package:markdown/markdown.dart' as md;

/// Represents a hard line break.
class HardWrapSyntax extends md.InlineSyntax {
  HardWrapSyntax() : super(r'\n');

  /// Create a void <br> element.
  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.empty('br'));
    return true;
  }
}