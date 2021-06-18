import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dart_git/dart_git.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import 'package:gitjournal/repository.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/settings_widgets.dart';
import 'package:gitjournal/setup/screens.dart';
import 'package:gitjournal/setup/sshkey.dart';
import 'package:gitjournal/ssh/keygen.dart';
import 'package:gitjournal/utils/logger.dart';
import 'package:gitjournal/utils/utils.dart';

class GitRemoteSettingsScreen extends StatefulWidget {
  final String sshPublicKey;

  GitRemoteSettingsScreen(this.sshPublicKey);

  @override
  _GitRemoteSettingsScreenState createState() =>
      _GitRemoteSettingsScreenState();
}

class _GitRemoteSettingsScreenState extends State<GitRemoteSettingsScreen> {
  var branches = <String>[];
  var remoteHost = "";
  var currentBranch = "";

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var settings = Provider.of<Settings>(context);
    var repo = Provider.of<GitJournalRepo>(context);

    if (remoteHost.isEmpty) {
      repo.remoteConfigs().then((list) {
        setState(() {
          if (!mounted) return;
          remoteHost = list.first.url;
        });
      });
    }

    if (branches.isEmpty) {
      currentBranch = repo.currentBranch ?? "";
      repo.branches().then((list) {
        setState(() {
          if (!mounted) return;
          branches = list;
        });
      });
    }

    var body = Column(
      children: <Widget>[
        if (remoteHost.isNotEmpty)
          Text(
            tr('settings.gitRemote.host'),
            style: textTheme.bodyText1,
            textAlign: TextAlign.left,
          ),
        if (remoteHost.isNotEmpty) ListTile(title: Text(remoteHost)),
        if (branches.isNotEmpty)
          ListPreference(
            title: tr('settings.gitRemote.branch'),
            currentOption: currentBranch, // FIXME
            options: branches,
            onChange: (String branch) {
              repo.checkoutBranch(branch);
              setState(() {
                currentBranch = branch;
              });
            },
          ),
        const SizedBox(height: 8.0),
        Text(
          tr('setup.sshKeyUserProvided.public'),
          style: textTheme.bodyText1,
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 16.0),
        PublicKeyWidget(widget.sshPublicKey),
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
        Builder(
          builder: (BuildContext context) => Button(
            text: tr('setup.sshKeyChoice.custom'),
            onPressed: _customSshKeys,
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
          onPressed: _resetGitHost,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: body,
        ),
      ),
    );
  }

  void _customSshKeys() {
    var route = MaterialPageRoute(
      builder: (context) => Scaffold(
        body: GitHostUserProvidedKeysPage(
          doneFunction: _updateKeys,
          saveText: tr("setup.sshKey.save"),
        ),
        appBar: AppBar(
          title: Text(tr('setup.sshKeyChoice.custom')),
        ),
      ),
      settings: const RouteSettings(name: '/settings/gitRemote/customKeys'),
    );
    Navigator.of(context).push(route);
  }

  void _updateKeys(String publicKey, String privateKey, String password) {
    var settings = Provider.of<Settings>(context, listen: false);

    if (publicKey.isEmpty || privateKey.isEmpty) {
      return;
    }
    settings.sshPublicKey = publicKey;
    settings.sshPrivateKey = privateKey;
    settings.sshPassword = password;
    settings.save();

    Navigator.of(context).pop();
  }

  void _copyKeyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.sshPublicKey));
    showSnackbar(context, tr('setup.sshKey.copied'));
  }

  void _generateSshKey(BuildContext context) {
    var comment = "GitJournal-" +
        Platform.operatingSystem +
        "-" +
        DateTime.now().toIso8601String().substring(0, 10); // only the date

    generateSSHKeys(comment: comment).then((SshKey? sshKey) {
      var settings = Provider.of<Settings>(context, listen: false);
      settings.sshPublicKey = sshKey!.publicKey;
      settings.sshPrivateKey = sshKey.publicKey;
      settings.sshPassword = sshKey.password;
      settings.save();

      Log.d("PublicKey: " + sshKey.publicKey);
      _copyKeyToClipboard(context);
    });
  }

  void _resetGitHost() async {
    var ok = await showDialog(
      context: context,
      builder: (_) => IrreversibleActionConfirmationDialog(
        tr("settings.gitRemote.changeHost.title"),
      ),
    );
    if (ok == null) {
      return;
    }

    var repo = context.read<GitJournalRepo>();
    var gitDir = repo.gitBaseDirectory;

    // Figure out the next available folder
    String repoFolderName = "journal_";
    var num = 0;
    while (true) {
      var repoFolderPath = p.join(gitDir, "$repoFolderName$num");
      if (!Directory(repoFolderPath).existsSync()) {
        await GitRepository.init(repoFolderPath);
        break;
      }
      num++;
    }
    repoFolderName = repoFolderName + num.toString();

    var settings = Provider.of<Settings>(context, listen: false);
    settings.folderName = repoFolderName;
    settings.storeInternally = true;
    await settings.save();

    var route = MaterialPageRoute(
      builder: (context) => GitHostSetupScreen(
        repoFolderName: repoFolderName,
        remoteName: 'origin',
        onCompletedFunction: repo.completeGitHostSetup,
      ),
      settings: const RouteSettings(name: '/setupRemoteGit'),
    );
    await Navigator.of(context).push(route);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class Button extends StatelessWidget {
  final String text;
  final void Function() onPressed;

  Button({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.button,
        ),
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class RedButton extends StatelessWidget {
  final String text;
  final void Function() onPressed;

  RedButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.button,
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class IrreversibleActionConfirmationDialog extends StatelessWidget {
  final String title;

  IrreversibleActionConfirmationDialog(this.title);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(tr("settings.gitRemote.changeHost.subtitle")),
      actions: <Widget>[
        TextButton(
          child: Text(tr("settings.gitRemote.changeHost.ok")),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        TextButton(
          child: Text(tr("settings.gitRemote.changeHost.cancel")),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
