/*
 * SPDX-FileCopyrightText: 2020-2021 Roland Fredenhagen <important@van-fredenhagen.de>
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:function_types/function_types.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gitjournal/core/link.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/editors/note_body_editor.dart';
import 'package:gitjournal/folder_views/common.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/markdown/hardwrap.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/utils/link_resolver.dart';
import 'package:gitjournal/utils/utils.dart';
import 'package:gitjournal/widgets/images/markdown_image.dart';

class MarkdownRenderer extends StatelessWidget {
  final Note note;
  final Func1<Note, void> onNoteTapped;

  const MarkdownRenderer({
    Key? key,
    required this.note,
    required this.onNoteTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    var settings = Provider.of<Settings>(context);
    theme = theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        subtitle1: theme.textTheme.subtitle1,
      ),
    );

    var isDark = theme.brightness == Brightness.dark;

    // Copied from MarkdownStyleSheet except Grey is replaced with Highlight color
    // p is changed
    var markdownStyleSheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: NoteBodyEditor.textStyle(context),
      code: theme.textTheme.bodyText2!.copyWith(
        backgroundColor: theme.dialogBackgroundColor,
        fontFamily: 'monospace',
        fontSize: theme.textTheme.bodyText2!.fontSize! * 0.85,
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
      checkbox: theme.textTheme.bodyText2!.copyWith(
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
            showSnackbar(
              context,
              tr(LocaleKeys.widgets_NoteViewer_linkInvalid, args: [link]),
            );
          }
          return;
        }

        // External Link
        try {
          var _ = await launch(link);
        } catch (e, stackTrace) {
          Log.e('Opening Link', ex: e, stacktrace: stackTrace);
          showSnackbar(
            context,
            tr(LocaleKeys.widgets_NoteViewer_linkNotFound, args: [link]),
          );
        }
      },
      imageBuilder: (url, title, alt) => MarkdownImage(
          url, note.parent.folderPath + p.separator,
          titel: title, altText: alt),
      extensionSet: markdownExtensions(hardWrapEnabled: settings.hardWrap),
    );

    return view;
  }

  static md.ExtensionSet markdownExtensions({bool hardWrapEnabled = false}) {
    // It's important to add both these inline syntaxes before the other
    // syntaxes as the LinkSyntax intefers with both of these
    var markdownExtensions = md.ExtensionSet(
      md.ExtensionSet.gitHubFlavored.blockSyntaxes,
      hardWrapEnabled
          ? [
              HardWrapSyntax(),
              WikiLinkSyntax(),
              TaskListSyntax(),
              ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
            ]
          : [
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
