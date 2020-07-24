import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/screens/settings_widgets.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/widgets/folder_selection_dialog.dart';
import 'package:gitjournal/widgets/pro_overlay.dart';

class SettingsImagesScreen extends StatefulWidget {
  @override
  SettingsImagesScreenState createState() => SettingsImagesScreenState();
}

class SettingsImagesScreenState extends State<SettingsImagesScreen> {
  @override
  Widget build(BuildContext context) {
    var settings = Settings.instance;
    var folder = Provider.of<NotesFolderFS>(context)
        .getFolderWithSpec(settings.imageLocationSpec);

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
            Settings.instance.imageLocationSpec = ".";
          } else {
            Settings.instance.imageLocationSpec = "";
          }
          Settings.instance.save();
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

            Settings.instance.imageLocationSpec =
                destFolder != null ? destFolder.pathSpec() : "";
            Settings.instance.save();
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
      body: ProOverlay(child: body),
    );
  }
}

//
// Options to expose
// - Image Location
//   - Note Directory
//   - Custom Directory
// Bool use relative path if possible
// - Image FileName
//   - Original Name
//   - Note FileName + _num
//   - Custom Name
//
