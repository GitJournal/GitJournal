import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/screens/settings_widgets.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/widgets/folder_selection_dialog.dart';

class SettingsImagesScreen extends StatefulWidget {
  @override
  SettingsImagesScreenState createState() => SettingsImagesScreenState();
}

class SettingsImagesScreenState extends State<SettingsImagesScreen> {
  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<Settings>(context);
    var folder = Provider.of<NotesFolderFS>(context)
        .getFolderWithSpec(settings.imageLocationSpec);

    // If the Custom Folder specified no longer exists
    if (settings.imageLocationSpec != "." && folder == null) {
      settings.imageLocationSpec = ".";
      settings.save();
    }

    var sameFolder = tr("settings.images.currentFolder");
    var customFolder = tr("settings.images.customFolder");

    var body = ListView(children: <Widget>[
      ListPreference(
        title: tr("settings.images.imageLocation"),
        currentOption:
            settings.imageLocationSpec == '.' ? sameFolder : customFolder,
        options: [sameFolder, customFolder],
        onChange: (String publicStr) {
          if (publicStr == sameFolder) {
            settings.imageLocationSpec = ".";
          } else {
            settings.imageLocationSpec = "";
          }
          settings.save();
          setState(() {});
        },
      ),
      if (settings.imageLocationSpec != '.')
        ListTile(
          title: Text(customFolder),
          subtitle: Text(folder != null ? folder.publicName : "/"),
          onTap: () async {
            var destFolder = await showDialog<NotesFolderFS>(
              context: context,
              builder: (context) => FolderSelectionDialog(),
            );

            settings.imageLocationSpec =
                destFolder != null ? destFolder.pathSpec() : "";
            settings.save();
            setState(() {});
          },
        ),
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('settings.images.title')),
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
