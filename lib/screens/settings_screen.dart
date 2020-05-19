import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/screens/debug_screen.dart';
import 'package:gitjournal/screens/settings_editors.dart';
import 'package:gitjournal/screens/settings_images.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/screens/settings_widgets.dart';
import 'package:gitjournal/screens/settings_git_remote.dart';
import 'package:gitjournal/screens/settings_note_metadata.dart';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:gitjournal/widgets/folder_selection_dialog.dart';
import 'package:gitjournal/widgets/pro_overlay.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('settings.title')),
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
  final gitAuthorKey = GlobalKey<FormFieldState<String>>();
  final gitAuthorEmailKey = GlobalKey<FormFieldState<String>>();
  final fontSizeKey = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    var stateContainer = Provider.of<StateContainer>(context, listen: false);

    var remoteGitConfigured = stateContainer.appState.remoteGitRepoConfigured;
    var settings = Settings.instance;

    var saveGitAuthor = (String gitAuthor) {
      Settings.instance.gitAuthor = gitAuthor;
      Settings.instance.save();
    };

    var gitAuthorForm = Form(
      child: TextFormField(
        key: gitAuthorKey,
        style: Theme.of(context).textTheme.headline6,
        decoration: InputDecoration(
          icon: Icon(Icons.person),
          hintText: tr('settings.author.hint'),
          labelText: tr('settings.author.label'),
        ),
        validator: (String value) {
          value = value.trim();
          if (value.isEmpty) {
            return tr('settings.author.validator');
          }
          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: saveGitAuthor,
        onSaved: saveGitAuthor,
        initialValue: Settings.instance.gitAuthor,
      ),
      onChanged: () {
        if (!gitAuthorKey.currentState.validate()) return;
        var gitAuthor = gitAuthorKey.currentState.value;
        saveGitAuthor(gitAuthor);
      },
    );

    var saveGitAuthorEmail = (String gitAuthorEmail) {
      Settings.instance.gitAuthorEmail = gitAuthorEmail;
      Settings.instance.save();
    };
    var gitAuthorEmailForm = Form(
      child: TextFormField(
        key: gitAuthorEmailKey,
        style: Theme.of(context).textTheme.headline6,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          icon: Icon(Icons.email),
          hintText: tr('settings.email.hint'),
          labelText: tr('settings.email.label'),
        ),
        validator: (String value) {
          value = value.trim();
          if (value.isEmpty) {
            return tr('settings.email.validator.empty');
          }

          bool emailValid =
              RegExp(r"^[a-zA-Z0-9.\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z\-]+")
                  .hasMatch(value);
          if (!emailValid) {
            return tr('settings.email.validator.invalid');
          }
          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: saveGitAuthorEmail,
        onSaved: saveGitAuthorEmail,
        initialValue: Settings.instance.gitAuthorEmail,
      ),
      onChanged: () {
        if (!gitAuthorEmailKey.currentState.validate()) return;
        var gitAuthorEmail = gitAuthorEmailKey.currentState.value;
        saveGitAuthorEmail(gitAuthorEmail);
      },
    );

    var brightness = DynamicTheme.of(context).brightness;
    var defaultNewFolder = Settings.instance.defaultNewNoteFolderSpec;
    if (defaultNewFolder.isEmpty) {
      defaultNewFolder = tr("rootFolder");
    }

    return ListView(children: [
      SettingsHeader(tr('settings.display.title')),
      SwitchListTile(
        title: Text(tr('settings.display.darkTheme')),
        value: brightness == Brightness.dark,
        onChanged: (bool newVal) {
          var b = newVal ? Brightness.dark : Brightness.light;
          var dynamicTheme = DynamicTheme.of(context);
          dynamicTheme.setBrightness(b);
        },
      ),
      ProOverlay(
        child: ListPreference(
          title: tr('settings.display.homeScreen'),
          currentOption: settings.homeScreen.toPublicString(),
          options: SettingsHomeScreen.options
              .map((f) => f.toPublicString())
              .toList(),
          onChange: (String publicStr) {
            var s = SettingsHomeScreen.fromPublicString(publicStr);
            Settings.instance.homeScreen = s;
            Settings.instance.save();
            setState(() {});
          },
        ),
      ),
      SettingsHeader('Note Settings'),
      ListTile(
        title: const Text("Default Folder for new notes"),
        subtitle: Text(defaultNewFolder),
        onTap: () async {
          var destFolder = await showDialog<NotesFolderFS>(
            context: context,
            builder: (context) => FolderSelectionDialog(),
          );
          if (destFolder != null) {
            Settings.instance.defaultNewNoteFolderSpec = destFolder.pathSpec();
            Settings.instance.save();
            setState(() {});
          }
        },
      ),
      SettingsHeader(tr('settings.gitAuthor')),
      ListTile(title: gitAuthorForm),
      ListTile(title: gitAuthorEmailForm),
      ListTile(
        title: const Text("Git Remote Settings"),
        subtitle: const Text("Configure where your notes are synced"),
        onTap: () {
          var route = MaterialPageRoute(
            builder: (context) => GitRemoteSettingsScreen(),
          );
          Navigator.of(context).push(route);
        },
        enabled: remoteGitConfigured,
      ),
      const SizedBox(height: 16.0),
      ListTile(
        title: const Text("Editor Settings"),
        subtitle: const Text("Configure how different editors work"),
        onTap: () {
          var route = MaterialPageRoute(
            builder: (context) => SettingsEditorsScreen(),
          );
          Navigator.of(context).push(route);
        },
      ),
      SettingsHeader("Storage"),
      ListPreference(
        title: "File Name",
        currentOption: settings.noteFileNameFormat.toPublicString(),
        options:
            NoteFileNameFormat.options.map((f) => f.toPublicString()).toList(),
        onChange: (String publicStr) {
          var format = NoteFileNameFormat.fromPublicString(publicStr);
          Settings.instance.noteFileNameFormat = format;
          Settings.instance.save();
          setState(() {});
        },
      ),
      ListTile(
        title: const Text("Note Metadata Settings"),
        subtitle: const Text("Configure how the YAML Metadata is saved"),
        onTap: () {
          var route = MaterialPageRoute(
            builder: (context) => NoteMetadataSettingsScreen(),
          );
          Navigator.of(context).push(route);
        },
      ),
      ListTile(
        title: Text(tr('settings.images.title')),
        subtitle: Text(tr('settings.images.subtitle')),
        onTap: () {
          var route = MaterialPageRoute(
            builder: (context) => SettingsImagesScreen(),
          );
          Navigator.of(context).push(route);
        },
      ),
      const SizedBox(height: 16.0),
      SettingsHeader(tr('settings.analytics')),
      SwitchListTile(
        title: Text(tr('settings.usageStats')),
        value: Settings.instance.collectUsageStatistics,
        onChanged: (bool val) {
          Settings.instance.collectUsageStatistics = val;
          Settings.instance.save();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: Text(tr('settings.crashReports')),
        value: Settings.instance.collectCrashReports,
        onChanged: (bool val) {
          Settings.instance.collectCrashReports = val;
          Settings.instance.save();
          setState(() {});
        },
      ),
      VersionNumberTile(),
      ListTile(
        title: Text(tr('settings.debug')),
        subtitle: Text(tr('settings.debugLog')),
        onTap: () {
          var route = MaterialPageRoute(
            builder: (context) => DebugScreen(),
          );
          Navigator.of(context).push(route);
        },
      ),
    ]);
  }
}

class SettingsHeader extends StatelessWidget {
  final String text;
  SettingsHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 0.0, top: 20.0),
      child: Text(
        text,
        style: TextStyle(
            color: Theme.of(context).accentColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class VersionNumberTile extends StatefulWidget {
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
      var str = await getVersionString();
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
      title: Text(tr('settings.versionInfo'), style: textTheme.subtitle1),
      subtitle: Text(
        versionText,
        style: textTheme.bodyText2,
        textAlign: TextAlign.left,
      ),
      enabled: false,
    );
  }
}
