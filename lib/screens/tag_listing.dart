import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/flattened_notes_folder.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/note_serializer.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/features.dart';
import 'package:gitjournal/screens/folder_view.dart';
import 'package:gitjournal/widgets/app_bar_menu_button.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:gitjournal/widgets/pro_overlay.dart';

class TagListingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var rootFolder = Provider.of<NotesFolderFS>(context);
    var allTags = rootFolder.getNoteTagsRecursively();
    var allTagsSorted = SplayTreeSet<String>.from(allTags);

    var listView = ListView(
      children: <Widget>[
        for (var tag in allTagsSorted) _buildTagTile(context, tag),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('screens.tags.title')),
        leading: GJAppBarMenuButton(),
      ),
      body: Scrollbar(
        child: ProOverlay(
          feature: Feature.tags,
          child: listView,
        ),
      ),
      drawer: AppDrawer(),
    );
  }

  Widget _buildTagTile(BuildContext context, String tag) {
    var theme = Theme.of(context);
    var titleColor = theme.textTheme.headline1.color;

    return ListTile(
      leading: FaIcon(FontAwesomeIcons.tag, color: titleColor),
      title: Text(tag),
      onTap: () {
        var route = MaterialPageRoute(
          builder: (context) {
            var rootFolder = Provider.of<NotesFolderFS>(context);
            var folder = FlattenedNotesFolder(
              rootFolder,
              filter: (Note n) =>
                  n.tags.contains(tag) || n.inlineTags.contains(tag),
              title: tag,
            );

            final propNames = NoteSerializationSettings();
            return FolderView(
              notesFolder: folder,
              newNoteExtraProps: {
                propNames.tagsKey: [tag],
              },
            );
          },
          settings: const RouteSettings(name: '/tags/'),
        );
        Navigator.of(context).push(route);
      },
    );
  }
}
