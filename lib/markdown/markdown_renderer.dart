/*
 * SPDX-FileCopyrightText: 2020-2021 Roland Fredenhagen <important@van-fredenhagen.de>
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:function_types/function_types.dart';
import 'package:gitjournal/core/link.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/editors/note_body_editor.dart';
import 'package:gitjournal/folder_views/common.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/markdown/parsers/hardwrap.dart';
import 'package:gitjournal/markdown/parsers/html_entities_syntax.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/utils/link_resolver.dart';
import 'package:gitjournal/utils/utils.dart';
import 'package:gitjournal/widgets/images/markdown_image.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'builders/katex_builder.dart';

class MarkdownRenderer extends StatelessWidget {
  final Note note;
  final Func1<Note, void> onNoteTapped;

  const MarkdownRenderer({
    super.key,
    required this.note,
    required this.onNoteTapped,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    var settings = Provider.of<Settings>(context);
    theme = theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        titleMedium: theme.textTheme.titleMedium,
      ),
    );

    var isDark = theme.brightness == Brightness.dark;

    // Copied from MarkdownStyleSheet except Grey is replaced with Highlight color
    // p is changed
    var markdownStyleSheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: NoteBodyEditor.textStyle(context),
      code: theme.textTheme.bodyMedium!.copyWith(
        backgroundColor: theme.dialogBackgroundColor,
        fontFamily: 'monospace',
        fontSize: theme.textTheme.bodyMedium!.fontSize! * 0.85,
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
      checkbox: theme.textTheme.bodyMedium!.copyWith(
        color: isDark ? theme.primaryColorLight : theme.primaryColor,
      ),
    );

    var view = MarkdownBody(
      data: note.body,
      // selectable: false, -> making this true breaks link navigation
      styleSheet: markdownStyleSheet,
      onTapLink: (String _, String? link, String __) async {
        final linkResolver = LinkResolver(note);

        var linkedNote = linkResolver.resolve(link!);
        if (linkedNote != null) {
          onNoteTapped(linkedNote);
          return;
        }

        if (LinkResolver.isWikiLink(link)) {
          var opened =
              openNewNoteEditor(context, LinkResolver.stripWikiSyntax(link));
          if (!opened) {
            showErrorMessageSnackbar(
              context,
              context.loc.widgetsNoteViewerLinkInvalid(link),
            );
          }
          return;
        }

        // External Link
        try {
          var _ = await launchUrl(
            Uri.parse(link),
            mode: LaunchMode.externalApplication,
          );
        } catch (e, stackTrace) {
          Log.e('Opening Link', ex: e, stacktrace: stackTrace);
          showErrorMessageSnackbar(
            context,
            context.loc.widgetsNoteViewerLinkNotFound(link),
          );
        }
      },
      imageBuilder: (url, title, alt) => MarkdownImage(
          url, p.join(note.repoPath, note.parent.folderPath),
          titel: title, altText: alt),
      extensionSet: markdownExtensions(hardWrapEnabled: settings.hardWrap),
      builders: {
        KatexBuilder.tag: KatexBuilder(),
      },
    );

    return view;
  }

  static md.ExtensionSet markdownExtensions({bool hardWrapEnabled = false}) {
    // It's important to add both these inline syntaxes before the other
    // syntaxes as the LinkSyntax intefers with WikiLinks and TaskLists
    var inline = <md.InlineSyntax>[
      HtmlEntitiesSyntax(),
      if (hardWrapEnabled) HardWrapSyntax(),
      WikiLinkSyntax(),
      ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
      KatexBuilder.inlineParser,
    ];

    var block = <md.BlockSyntax>[
      ...md.ExtensionSet.gitHubFlavored.blockSyntaxes,
      // KatexBuilder.blockParser,
    ];

    return md.ExtensionSet(block, inline);
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
