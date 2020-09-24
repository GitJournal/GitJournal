import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:git_bindings/git_bindings.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import 'package:gitjournal/app_settings.dart';
import 'package:gitjournal/screens/settings_widgets.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/setup/screens.dart';
import 'package:gitjournal/setup/sshkey.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/utils/logger.dart';

class GitRemoteSettingsScreen extends StatefulWidget {
  @override
  _GitRemoteSettingsScreenState createState() =>
      _GitRemoteSettingsScreenState();
}

class _GitRemoteSettingsScreenState extends State<GitRemoteSettingsScreen> {
  String publicKey = "";

  @override
  void initState() {
    super.initState();
    getSSHPublicKey().then((String val) {
      if (!mounted) return;
      setState(() {
        publicKey = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var settings = Provider.of<Settings>(context);

    var body = Column(
      children: <Widget>[
        Text(
          tr('setup.sshKeyUserProvided.public'),
          style: textTheme.bodyText1,
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 16.0),
        PublicKeyWidget(publicKey),
        const SizedBox(height: 16.0),
        const Divider(),
        Builder(
          builder: (BuildContext context) => Button(
            text: tr('setup.sshKey.copy'),
            onPressed: () => _copyKeyToClipboard(context),
          ),
        ),
        Builder(
          builder: (BuildContext context) => Button(
            text: tr('setup.sshKey.regenerate'),
            onPressed: () => _generateSshKey(context),
          ),
        ),
        ListPreference(
          title: tr('settings.ssh.syncFreq'),
          currentOption: settings.remoteSyncFrequency.toPublicString(),
          options: RemoteSyncFrequency.options
              .map((f) => f.toPublicString())
              .toList(),
          onChange: (String publicStr) {
            var val = RemoteSyncFrequency.fromPublicString(publicStr);
            settings.remoteSyncFrequency = val;
            settings.save();
            setState(() {});
          },
        ),
        RedButton(
          text: tr('settings.ssh.reset'),
          onPressed: () => _resetGitHost(context),
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(tr("settings.gitRemote.title")),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: body,
      ),
    );
  }

  void _copyKeyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: publicKey));
    showSnackbar(context, tr('setup.sshKey.copied'));
  }

  void _generateSshKey(BuildContext context) {
    var comment = "GitJournal-" +
        Platform.operatingSystem +
        "-" +
        DateTime.now().toIso8601String().substring(0, 10); // only the date

    generateSSHKeys(comment: comment).then((String publicKey) {
      setState(() {
        this.publicKey = publicKey;
        Log.d("PublicKey: " + publicKey);
        _copyKeyToClipboard(context);
      });
    });
  }

  void _resetGitHost(BuildContext context) async {
    var ok = await showDialog(
      context: context,
      builder: (_) => HostChangeConfirmationDialog(),
    );
    if (ok == null) {
      return;
    }

    var stateContainer = Provider.of<StateContainer>(context);
    var appSettings = Provider.of<AppSettings>(context);
    var gitDir = appSettings.gitBaseDirectory;

    // Figure out the next available folder
    String repoFolderName = "journal_";
    var num = 0;
    while (true) {
      var repoFolderPath = p.join(gitDir, "$repoFolderName$num");
      if (!Directory(repoFolderPath).existsSync()) {
        break;
      }
      num++;
    }
    repoFolderName = repoFolderName + num.toString();

    var route = MaterialPageRoute(
      builder: (context) => GitHostSetupScreen(
        repoFolderName,
        stateContainer.completeGitHostSetup,
      ),
      settings: const RouteSettings(name: '/setupRemoteGit'),
    );
    await Navigator.of(context).push(route);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class Button extends StatelessWidget {
  final String text;
  final Function onPressed;

  Button({@required this.text, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: RaisedButton(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.button,
        ),
        color: Theme.of(context).primaryColor,
        onPressed: onPressed,
      ),
    );
  }
}

class RedButton extends StatelessWidget {
  final String text;
  final Function onPressed;

  RedButton({@required this.text, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: RaisedButton(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.button,
        ),
        color: Colors.red,
        onPressed: onPressed,
      ),
    );
  }
}

class HostChangeConfirmationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(tr("settings.gitRemote.changeHost.title")),
      content: Text(tr("settings.gitRemote.changeHost.subtitle")),
      actions: <Widget>[
        FlatButton(
          child: Text(tr("settings.gitRemote.changeHost.ok")),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        FlatButton(
          child: Text(tr("settings.gitRemote.changeHost.cancel")),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
