import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/folder_views/common.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/utils/logger.dart';
import 'package:gitjournal/widgets/editor_scroll_view.dart';
import 'package:gitjournal/widgets/notes_backlinks.dart';

class NoteViewer extends StatelessWidget {
  final Note note;
  const NoteViewer({Key key, @required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    theme = theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        subtitle1: theme.textTheme.subtitle1,
      ),
    );

    // Copied from MarkdownStyleSheet except Grey is replaced with Highlight color
    var markdownStyleSheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
      code: theme.textTheme.bodyText2.copyWith(
        backgroundColor: theme.dialogBackgroundColor,
        fontFamily: "monospace",
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
    );

    // It's important to add both these inline syntaxes before the other
    // syntaxes as the LinkSyntax intefers with both of these
    var markdownExtensions = md.ExtensionSet.gitHubFlavored;
    markdownExtensions.inlineSyntaxes.insert(0, WikiLinkSyntax2());
    markdownExtensions.inlineSyntaxes.insert(1, TaskListSyntax());

    final rootFolder = Provider.of<NotesFolderFS>(context);
    var view = EditorScrollView(
      child: Column(
        children: <Widget>[
          NoteTitleHeader(note.title),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: MarkdownBody(
              data: note.body,
              // selectable: false, -> making this true breaks link navigation
              styleSheet: markdownStyleSheet,
              onTapLink: (String link) async {
                var spec = link;

                if (link.startsWith('[[') &&
                    link.endsWith(']]') &&
                    link.length > 4) {
                  // FIXME: What if the case is different?
                  spec = link.substring(2, link.length - 2) + ".md";
                }

                if (link.startsWith('./')) {
                  spec = link.substring(2);
                }

                var linkedNote = note.parent.getNoteWithSpec(spec);
                if (linkedNote != null) {
                  openNoteEditor(context, linkedNote);
                  return;
                }

                if (!spec.endsWith('.md')) {
                  linkedNote = note.parent.getNoteWithSpec(spec + '.md');
                  if (linkedNote != null) {
                    openNoteEditor(context, linkedNote);
                    return;
                  }
                }
                if (!spec.endsWith('.txt')) {
                  linkedNote = note.parent.getNoteWithSpec(spec + '.txt');
                  if (linkedNote != null) {
                    openNoteEditor(context, linkedNote);
                    return;
                  }
                }

                try {
                  await launch(link);
                } catch (e, stackTrace) {
                  Log.e("Opening Link", ex: e, stacktrace: stackTrace);
                  showSnackbar(context, "Link '$link' not found");
                }
              },
              imageBuilder: (url, title, alt) => kDefaultImageBuilder(
                  url, note.parent.folderPath + p.separator, null, null),
              extensionSet: markdownExtensions,
            ),
          ),
          const SizedBox(height: 16.0),
          if (Settings.instance.experimentalBacklinks)
            NoteBacklinkRenderer(note: note, rootFolder: rootFolder),
          // _buildFooter(context),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );

    return view;
  }

  /*
  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_left),
            tooltip: 'Previous Entry',
            onPressed: showPrevNoteFunc,
          ),
          Expanded(
            flex: 10,
            child: Text(''),
          ),
          IconButton(
            icon: Icon(Icons.arrow_right),
            tooltip: 'Next Entry',
            onPressed: showNextNoteFunc,
          ),
        ],
      ),
    );
  }
  */
}

class NoteTitleHeader extends StatelessWidget {
  final String header;
  NoteTitleHeader(this.header);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(header, style: textTheme.headline6),
    );
  }
}

//
// Copied from flutter_markdown
// But it uses CachedNetworkImage
//
typedef Widget ImageBuilder(
    Uri uri, String imageDirectory, double width, double height);

final ImageBuilder kDefaultImageBuilder = (
  Uri uri,
  String imageDirectory,
  double width,
  double height,
) {
  if (uri.scheme == 'http' || uri.scheme == 'https') {
    return CachedNetworkImage(
      imageUrl: uri.toString(),
      width: width,
      height: height,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  } else if (uri.scheme == 'data') {
    return _handleDataSchemeUri(uri, width, height);
  } else if (uri.scheme == "resource") {
    return Image.asset(uri.path, width: width, height: height);
  } else {
    Uri fileUri = imageDirectory != null
        ? Uri.parse(imageDirectory + uri.toString())
        : uri;
    if (fileUri.scheme == 'http' || fileUri.scheme == 'https') {
      return CachedNetworkImage(
        imageUrl: fileUri.toString(),
        width: width,
        height: height,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    } else {
      return Image.file(File.fromUri(fileUri), width: width, height: height);
    }
  }
};

Widget _handleDataSchemeUri(Uri uri, final double width, final double height) {
  final String mimeType = uri.data.mimeType;
  if (mimeType.startsWith('image/')) {
    return Image.memory(
      uri.data.contentAsBytes(),
      width: width,
      height: height,
    );
  } else if (mimeType.startsWith('text/')) {
    return Text(uri.data.contentAsString());
  }
  return const SizedBox();
}

/// Parse [[term]]
class WikiLinkSyntax2 extends md.InlineSyntax {
  static final String _pattern = r'\[\[([^\[\]]+)\]\]';

  WikiLinkSyntax2() : super(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    // print("-------- WIKI LINK -------");
    var term = match[1].trim();

    var el = md.Element('a', [md.Text(term)]);
    el.attributes['type'] = 'wiki';
    el.attributes['href'] = '[[$term]]';

    parser.addNode(el);
    return true;
  }
}
