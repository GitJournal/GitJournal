import 'package:markdown/markdown.dart' as md;

// Mathjax :
// \\[ x = {-b \pm \sqrt{b^2-4ac} \over 2a} \\]
// \\( x = {-b \pm \sqrt{b^2-4ac} \over 2a} \\)
// FIXME: Should it be with a \\ or just \

// $$ \begin{equation} \label{label} ... \end{equation} $$
// `$$x = {-b \pm \sqrt{b^2-4ac} \over 2a}.$$`
// `$$c=\sqrt{a^2 + b^2}$$`
// with $$ it can span multiple lines

// For inline mode, you can either use $...$ or \(...\). As an example, \(E = mc^2\) yields E=mc2.
// Alternatively, \begin{math} and \end{math} can be used.

class MathJaxInlineSyntax extends md.InlineSyntax {
  static final String _pattern = r'\\(.*\\)';

  MathJaxInlineSyntax() : super(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var text = match[1]!;

    var el = md.Element('span', [md.Text(text)]);
    el.attributes['type'] = 'mathjax';

    parser.addNode(el);
    return true;
  }
}
