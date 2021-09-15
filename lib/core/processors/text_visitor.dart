/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:function_types/function_types.dart';
import 'package:markdown/markdown.dart' as md;

/// Called for each text node of the markdown document. It is not called
/// for text inside a code block
class TextVisitor implements md.NodeVisitor {
  Func1<String, void> textCallback;

  TextVisitor(this.textCallback);

  @override
  bool visitElementBefore(md.Element el) {
    if (el.tag == 'code') {
      return false;
    }
    return true;
  }

  @override
  void visitText(md.Text text) {
    textCallback(text.text);
  }

  @override
  void visitElementAfter(md.Element el) {}

  void visit(List<md.Node> nodes) {
    for (final node in nodes) {
      node.accept(this);
    }
  }
}
