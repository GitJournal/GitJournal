import 'package:flutter/material.dart';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gitjournal/app_settings.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/features.dart';
import 'package:gitjournal/screens/debug_screen.dart';
import 'package:gitjournal/screens/feature_timeline_screen.dart';
import 'package:gitjournal/screens/settings_editors.dart';
import 'package:gitjournal/screens/settings_experimental.dart';
import 'package:gitjournal/screens/settings_git_remote.dart';
import 'package:gitjournal/screens/settings_images.dart';
import 'package:gitjournal/screens/settings_misc.dart';
import 'package:gitjournal/screens/settings_note_metadata.dart';
import 'package:gitjournal/screens/settings_tags.dart';
import 'package:gitjournal/screens/settings_widgets.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/widgets/folder_selection_dialog.dart';
import 'package:gitjournal/widgets/pro_overlay.dart';

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
    var settings = Provider.of<Settings>(context);
    var appSettings = Provider.of<AppSettings>(context);
    var remoteGitConfigured = settings.remoteGitRepoConfigured;

    var saveGitAuthor = (String gitAuthor) {
      settings.gitAuthor = gitAuthor;
      settings.save();
    };

    var gitAuthorForm = Form(
      child: TextFormField(
        key: gitAuthorKey,
        style: Theme.of(context).textTheme.headline6,
        decoration: InputDecoration(
          icon: const Icon(Icons.person),
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
        initialValue: settings.gitAuthor,
      ),
      onChanged: () {
        if (!gitAuthorKey.currentState.validate()) return;
        var gitAuthor = gitAuthorKey.currentState.value;
        saveGitAuthor(gitAuthor);
      },
    );

    var saveGitAuthorEmail = (String gitAuthorEmail) {
      settings.gitAuthorEmail = gitAuthorEmail;
      settings.save();
    };
    var gitAuthorEmailForm = Form(
      child: TextFormField(
        key: gitAuthorEmailKey,
        style: Theme.of(context).textTheme.headline6,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          icon: const Icon(Icons.email),
          hintText: tr('settings.email.hint'),
          labelText: tr('settings.email.label'),
        ),
        validator: (String value) {
          value = value.trim();
          if (value.isEmpty) {
            return tr('settings.email.validator.empty');
          }

          bool emailValid = RegExp(
                  r"^[a-zA-Z0-9.\-!#$%&'*+/=?^_``{|}~]+@[a-zA-Z0-9\-]+\.[a-zA-Z\-]+")
              .hasMatch(value);

          if (!emailValid) {
            return tr('settings.email.validator.invalid');
          }
          return null;
        },
        textInputAction: TextInputAction.done,
        onFieldSubmitted: saveGitAuthorEmail,
        onSaved: saveGitAuthorEmail,
        initialValue: settings.gitAuthorEmail,
      ),
      onChanged: () {
        if (!gitAuthorEmailKey.currentState.validate()) return;
        var gitAuthorEmail = gitAuthorEmailKey.currentState.value;
        saveGitAuthorEmail(gitAuthorEmail);
      },
    );

    var brightness = DynamicTheme.of(context).brightness;
    var defaultNewFolder = settings.defaultNewNoteFolderSpec;
    if (defaultNewFolder.isEmpty) {
      defaultNewFolder = tr("rootFolder");
    } else {
      if (!folderWithSpecExists(context, defaultNewFolder)) {
        setState(() {
          defaultNewFolder = tr("rootFolder");

          settings.defaultNewNoteFolderSpec = "";
          settings.save();
        });
      }
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
        feature: Feature.customizeHomeScreen,
        child: ListPreference(
          title: tr('settings.display.homeScreen'),
          currentOption: settings.homeScreen.toPublicString(),
          options: SettingsHomeScreen.options
              .map((f) => f.toPublicString())
              .toList(),
          onChange: (String publicStr) {
            var s = SettingsHomeScreen.fromPublicString(publicStr);
            settings.homeScreen = s;
            settings.save();
            setState(() {});
          },
        ),
      ),
      SettingsHeader(tr('settings.note.title')),
      ListTile(
        title: Text(tr('settings.note.defaultFolder')),
        subtitle: Text(defaultNewFolder),
        onTap: () async {
          var destFolder = await showDialog<NotesFolderFS>(
            context: context,
            builder: (context) => FolderSelectionDialog(),
          );
          if (destFolder != null) {
            settings.defaultNewNoteFolderSpec = destFolder.pathSpec();
            settings.save();
            setState(() {});
          }
        },
      ),
      SettingsHeader(tr('settings.gitAuthor')),
      ListTile(title: gitAuthorForm),
      ListTile(title: gitAuthorEmailForm),
      ListTile(
        title: Text(tr("settings.gitRemote.title")),
        subtitle: Text(tr("settings.gitRemote.subtitle")),
        onTap: () {
          var route = MaterialPageRoute(
            builder: (context) => GitRemoteSettingsScreen(),
            settings: const RouteSettings(name: '/settings/gitRemote'),
          );
          Navigator.of(context).push(route);
        },
        enabled: remoteGitConfigured,
      ),
      const SizedBox(height: 16.0),
      ListTile(
        title: Text(tr("settings.editors.title")),
        subtitle: Text(tr("settings.editors.subtitle")),
        onTap: () {
          var route = MaterialPageRoute(
            builder: (context) => SettingsEditorsScreen(),
            settings: const RouteSettings(name: '/settings/editors'),
          );
          Navigator.of(context).push(route);
        },
      ),
      SettingsHeader(tr('settings.storage.title')),
      ListPreference(
        title: tr('settings.note.fileName'),
        currentOption: settings.noteFileNameFormat.toPublicString(),
        options:
            NoteFileNameFormat.options.map((f) => f.toPublicString()).toList(),
        onChange: (String publicStr) {
          var format = NoteFileNameFormat.fromPublicString(publicStr);
          settings.noteFileNameFormat = format;
          settings.save();
          setState(() {});
        },
      ),
      ListTile(
        title: Text(tr("settings.noteMetaData.title")),
        subtitle: Text(tr("settings.noteMetaData.subtitle")),
        onTap: () {
          var route = MaterialPageRoute(
            builder: (context) => NoteMetadataSettingsScreen(),
            settings: const RouteSettings(name: '/settings/noteMetaData'),
          );
          Navigator.of(context).push(route);
        },
      ),
      ProOverlay(
        feature: Feature.inlineTags,
        child: ListTile(
          title: Text(tr("settings.tags.title")),
          subtitle: Text(tr("settings.tags.subtitle")),
          onTap: () {
            var route = MaterialPageRoute(
              builder: (context) => SettingsTagsScreen(),
              settings: const RouteSettings(name: '/settings/tags'),
            );
            Navigator.of(context).push(route);
          },
        ),
      ),
      ListTile(
        title: Text(tr('settings.images.title')),
        subtitle: Text(tr('settings.images.subtitle')),
        onTap: () {
          var route = MaterialPageRoute(
            builder: (context) => SettingsImagesScreen(),
            settings: const RouteSettings(name: '/settings/images'),
          );
          Navigator.of(context).push(route);
        },
      ),
      ListTile(
        title: Text(tr('settings.misc.title')),
        onTap: () {
          var route = MaterialPageRoute(
            builder: (context) => SettingsMisc(),
            settings: const RouteSettings(name: '/settings/misc'),
          );
          Navigator.of(context).push(route);
        },
      ),
      const SizedBox(height: 16.0),
      ListTile(
        title: Text(tr("feature_timeline.title")),
        onTap: () {
          var route = MaterialPageRoute(
            builder: (context) => FeatureTimelineScreen(),
            settings: const RouteSettings(name: '/featureTimeline'),
          );
          Navigator.of(context).push(route);
        },
      ),
      const SizedBox(height: 16.0),
      SwitchListTile(
        title: Text(tr('settings.usageStats')),
        value: appSettings.collectUsageStatistics,
        onChanged: (bool val) {
          appSettings.collectUsageStatistics = val;
          appSettings.save();
          setState(() {});
        },
      ),
      SwitchListTile(
        title: Text(tr('settings.crashReports')),
        value: appSettings.collectCrashReports,
        onChanged: (bool val) {
          appSettings.collectCrashReports = val;
          appSettings.save();
          setState(() {});
        },
      ),
      VersionNumberTile(),
      ListTile(
        title: Text(tr('settings.debug.title')),
        subtitle: Text(tr('settings.debug.subtitle')),
        onTap: () {
          var route = MaterialPageRoute(
            builder: (context) => DebugScreen(),
            settings: const RouteSettings(name: '/settings/debug'),
          );
          Navigator.of(context).push(route);
        },
      ),
      ListTile(
        title: Text(tr('settings.experimental.title')),
        subtitle: Text(tr('settings.experimental.subtitle')),
        onTap: () {
          var route = MaterialPageRoute(
            builder: (context) => ExperimentalSettingsScreen(),
            settings: const RouteSettings(name: '/settings/experimental'),
          );
          Navigator.of(context).push(route);
        },
      ),
      ListTile(
        title: Text(tr('settings.privacy')),
        onTap: () {
          launch("https://gitjournal.io/privacy");
        },
      ),
      ListTile(
        title: Text(tr('settings.terms')),
        onTap: () {
          launch("https://gitjournal.io/terms");
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
