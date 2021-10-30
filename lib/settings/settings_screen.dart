/*
 * SPDX-FileCopyrightText: 2020-2021 Roland Fredenhagen <important@van-fredenhagen.de>
 * SPDX-FileCopyrightText: 2020-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/repository_manager.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/settings_git_remote.dart';
import 'package:gitjournal/settings/settings_misc.dart';
import 'package:gitjournal/utils/utils.dart';
import 'package:gitjournal/widgets/folder_selection_dialog.dart';

class SettingsScreen extends StatelessWidget {
  static const routePath = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(LocaleKeys.settings_title)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SettingsList(),
    );
  }
}

class SettingsList extends StatefulWidget {
  @override
  SettingsListState createState() {
    return SettingsListState();
  }
}

class SettingsListState extends State<SettingsList> {
  final fontSizeKey = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<Settings>(context);

    var defaultNewFolder = settings.defaultNewNoteFolderSpec;
    if (defaultNewFolder.isEmpty) {
      defaultNewFolder = tr(LocaleKeys.rootFolder);
    } else {
      if (!folderWithSpecExists(context, defaultNewFolder)) {
        setState(() {
          defaultNewFolder = tr(LocaleKeys.rootFolder);

          settings.defaultNewNoteFolderSpec = "";
          settings.save();
        });
      }
    }

    return ListView(children: [
      SettingsHeader(tr(LocaleKeys.settings_note_title)),
      ListTile(
        title: Text(tr(LocaleKeys.settings_note_defaultFolder)),
        subtitle: Text(defaultNewFolder),
        onTap: () async {
          var destFolder = await showDialog<NotesFolderFS>(
            context: context,
            builder: (context) => FolderSelectionDialog(),
          );
          if (destFolder != null) {
            settings.defaultNewNoteFolderSpec = destFolder.folderPath;
            settings.save();
            setState(() {});
          }
        },
      ),
      const SizedBox(height: 16.0),
      ListTile(
        title: Text(tr(LocaleKeys.settings_misc_title)),
        onTap: () {
          var route = MaterialPageRoute(
            builder: (context) => SettingsMisc(),
            settings: const RouteSettings(name: '/settings/misc'),
          );
          var _ = Navigator.push(context, route);
        },
      ),
      RedButton(
        text: tr(LocaleKeys.settings_deleteRepo),
        onPressed: () async {
          var ok = await showDialog(
            context: context,
            builder: (_) => IrreversibleActionConfirmationDialog(
              title: LocaleKeys.settings_deleteRepo.tr(),
              subtitle: LocaleKeys.settings_gitRemote_changeHost_subtitle.tr(),
            ),
          );
          if (ok == null) {
            return;
          }

          var repoManager = context.read<RepositoryManager>();
          await repoManager.deleteCurrent();

          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
    ]);
  }
}

class SettingsHeader extends StatelessWidget {
  final String text;
  const SettingsHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 0.0, top: 20.0),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class VersionNumberTile extends StatefulWidget {
  const VersionNumberTile({Key? key}) : super(key: key);

  @override
  VersionNumberTileState createState() {
    return VersionNumberTileState();
  }
}

class VersionNumberTileState extends State<VersionNumberTile> {
  String versionText = "";

  @override
  void initState() {
    super.initState();

    () async {
      var str = await getVersionString(includeAppName: false);
      if (!mounted) return;
      setState(() {
        versionText = str;
      });
    }();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return ListTile(
      leading: FaIcon(
        FontAwesomeIcons.stamp,
        color: textTheme.subtitle1!.color,
      ),
      title:
          Text(tr(LocaleKeys.settings_versionInfo), style: textTheme.subtitle1),
      subtitle: Text(versionText),
      onTap: () {
        Clipboard.setData(ClipboardData(text: versionText));
        showSnackbar(context, tr(LocaleKeys.settings_versionCopied));
      },
    );
  }
}
