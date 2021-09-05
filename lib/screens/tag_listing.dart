import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/flattened_notes_folder.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/note_serializer.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/core/views/inline_tags_view.dart';
import 'package:gitjournal/features.dart';
import 'package:gitjournal/folder_views/folder_view.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/widgets/app_bar_menu_button.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:gitjournal/widgets/pro_overlay.dart';

class TagListingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var rootFolder = Provider.of<NotesFolderFS>(context);
    var inlineTagsView = InlineTagsView.of(context);
    var allTags = inlineTagsView == null
        ? SplayTreeSet<String>()
        : rootFolder.getNoteTagsRecursively(inlineTagsView);

    Widget body;
    if (allTags.isNotEmpty) {
      body = ListView(
        children: <Widget>[
          for (var tag in allTags) _buildTagTile(context, tag),
        ],
      );
    } else {
      body = Center(
        child: Text(
          tr("screens.tags.empty"),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.w300,
            color: Colors.grey[350],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(LocaleKeys.screens_tags_title)),
        leading: GJAppBarMenuButton(),
      ),
      body: Scrollbar(
        child: ProOverlay(
          feature: Feature.tags,
          child: body,
        ),
      ),
      drawer: AppDrawer(),
    );
  }

  Widget _buildTagTile(BuildContext context, String tag) {
    var theme = Theme.of(context);
    var titleColor = theme.textTheme.headline1!.color;

    return ListTile(
      leading: FaIcon(FontAwesomeIcons.tag, color: titleColor),
      title: Text(tag),
      onTap: () {
        var route = MaterialPageRoute(
          builder: (context) => FutureBuilderWithProgress(
            future: _tagFolderView(context, tag),
          ),
          settings: const RouteSettings(name: '/tags/'),
        );
        Navigator.of(context).push(route);
      },
    );
  }
}

Future<FolderView> _tagFolderView(BuildContext context, String tag) async {
  var rootFolder = Provider.of<NotesFolderFS>(context, listen: false);
  var inlineTagsView = InlineTagsView.of(context);

  var folder = await FlattenedNotesFolder.load(
    rootFolder,
    filter: (Note n) async {
      if (n.tags.contains(tag)) {
        return true;
      }

      var inlineTags = inlineTagsView?.fetch(n);
      if (inlineTags != null && inlineTags.contains(tag)) {
        return true;
      }

      return false;
    },
    title: tag,
  );

  final propNames = NoteSerializationSettings();
  return FolderView(
    notesFolder: folder,
    newNoteExtraProps: {
      propNames.tagsKey: [tag],
    },
  );
}

class FutureBuilderWithProgress<T> extends StatelessWidget {
  final Future<T> future;

  const FutureBuilderWithProgress({
    Key? key,
    required this.future,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      builder: (context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasData) {
          return snapshot.data as Widget;
        }
        return const CircularProgressIndicator();
      },
      future: future,
    );
  }
}
