/*
Copyright 2020-2021 Vishesh Handa <me@vhanda.in>
                    Roland Fredenhagen <important@van-fredenhagen.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:function_types/function_types.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import 'package:gitjournal/core/link.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/folder_views/common.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/utils/link_resolver.dart';
import 'package:gitjournal/utils/logger.dart';
import 'package:gitjournal/widgets/images/markdown_image.dart';

class MarkdownRenderer extends StatelessWidget {
  final Note note;
  final Func1<Note, void> onNoteTapped;

  const MarkdownRenderer({
    Key key,
    @required this.note,
    @required this.onNoteTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    theme = theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        subtitle1: theme.textTheme.subtitle1,
      ),
    );

    var isDark = theme.brightness == Brightness.dark;

    // Copied from MarkdownStyleSheet except Grey is replaced with Highlight color
    var markdownStyleSheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
      code: theme.textTheme.bodyText2.copyWith(
        backgroundColor: theme.dialogBackgroundColor,
        fontFamily: 'monospace',
        fontSize: theme.textTheme.bodyText2.fontSize * 0.85,
      ),
      tableBorder: TableBorder.all(color: theme.highlightColor, width: 0),
      tableCellsDecoration: BoxDecoration(color: theme.dialogBackgroundColor),
      codeblockDecoration: BoxDecoration(
        color: theme.dialogBackgroundColor,
        borderRadius: BorderRadius.circular(2.0),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 3.0, color: theme.highlightColor),
        ),
      ),
      blockquoteDecoration: BoxDecoration(
        color: theme.primaryColorLight,
        borderRadius: BorderRadius.circular(2.0),
      ),
      checkbox: theme.textTheme.bodyText2.copyWith(
        color: isDark ? theme.primaryColorLight : theme.primaryColor,
      ),
    );

    var view = MarkdownBody(
      data: note.body,
      // selectable: false, -> making this true breaks link navigation
      styleSheet: markdownStyleSheet,
      onTapLink: (String _, String link, String __) async {
        final linkResolver = LinkResolver(note);

        var linkedNote = linkResolver.resolve(link);
        if (linkedNote != null) {
          onNoteTapped(linkedNote);
          return;
        }

        if (LinkResolver.isWikiLink(link)) {
          var opened =
              openNewNoteEditor(context, LinkResolver.stripWikiSyntax(link));
          if (!opened) {
            showSnackbar(
              context,
              tr('widgets.NoteViewer.linkInvalid', args: [link]),
            );
          }
          return;
        }

        // External Link
        try {
          await launch(link);
        } catch (e, stackTrace) {
          Log.e('Opening Link', ex: e, stacktrace: stackTrace);
          showSnackbar(
            context,
            tr('widgets.NoteViewer.linkNotFound', args: [link]),
          );
        }
      },
      imageBuilder: (url, title, alt) => MarkdownImage(
          url, note.parent.folderPath + p.separator,
          titel: title, altText: alt),
      extensionSet: markdownExtensions(),
    );

    return view;
  }

  static md.ExtensionSet markdownExtensions() {
    // It's important to add both these inline syntaxes before the other
    // syntaxes as the LinkSyntax intefers with both of these
    var markdownExtensions = md.ExtensionSet(
      md.ExtensionSet.gitHubFlavored.blockSyntaxes,
      [
        WikiLinkSyntax(),
        TaskListSyntax(),
        ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
      ],
    );
    return markdownExtensions;
  }
}
/*

/// Parse ==Words==
class HighlightTermSyntax extends md.InlineSyntax {
  static final String _pattern = r'==(^=^=*)==';

  HighlightTermSyntax() : super(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var displayText = match[1];

    var el = md.Element('span', [md.Text(displayText)]);
    el.attributes['type'] = 'highlight';

    parser.addNode(el);
    return true;
  }
}

Notes:
You can't just use this builder as it's mandatory to override visitText
which results in links and other rich text elements not being rendered
correctly when inside the highlight.
You'll need to modify flutter_makrdown to allow such modifications.


class HighlightTermBuilder extends MarkdownElementBuilder {
  @override
  void visitElementBefore(md.Element element) {}

  @override
  Widget visitText(md.Text text, TextStyle style) {
    /*
    style = style.copyWith(backgroundColor: Colors.red);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(text.text, style: style),
      ],
    );*/
  }

  @override
  Widget visitElementAfter(md.Element element, TextStyle preferredStyle) =>
      null;
}

*/
