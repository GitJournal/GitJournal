/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/folder/notes_folder_config.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/settings/widgets/settings_list_preference.dart';
import 'package:gitjournal/widgets/folder_selection_dialog.dart';

class SettingsImagesScreen extends StatefulWidget {
  static const routePath = '/settings/images';

  @override
  SettingsImagesScreenState createState() => SettingsImagesScreenState();
}

class SettingsImagesScreenState extends State<SettingsImagesScreen> {
  @override
  Widget build(BuildContext context) {
    var folderConfig = Provider.of<NotesFolderConfig>(context);
    var folder = Provider.of<NotesFolderFS>(context)
        .getFolderWithSpec(folderConfig.imageLocationSpec);

    // If the Custom Folder specified no longer exists
    if (folderConfig.imageLocationSpec != "." && folder == null) {
      folderConfig.imageLocationSpec = ".";
      folderConfig.save();
    }

    var sameFolder = tr("settings.images.currentFolder");
    var customFolder = tr("settings.images.customFolder");

    var body = ListView(children: <Widget>[
      ListPreference(
        title: tr("settings.images.imageLocation"),
        currentOption:
            folderConfig.imageLocationSpec == '.' ? sameFolder : customFolder,
        options: [sameFolder, customFolder],
        onChange: (String publicStr) {
          if (publicStr == sameFolder) {
            folderConfig.imageLocationSpec = ".";
          } else {
            folderConfig.imageLocationSpec = "";
          }
          folderConfig.save();
          setState(() {});
        },
      ),
      if (folderConfig.imageLocationSpec != '.')
        ListTile(
          title: Text(customFolder),
          subtitle: Text(folder != null ? folder.publicName : "/"),
          onTap: () async {
            var destFolder = await showDialog<NotesFolderFS>(
              context: context,
              builder: (context) => FolderSelectionDialog(),
            );

            folderConfig.imageLocationSpec =
                destFolder != null ? destFolder.folderPath : "";
            folderConfig.save();
            setState(() {});
          },
        ),
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(LocaleKeys.settings_images_title)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: body,
    );
  }
}
