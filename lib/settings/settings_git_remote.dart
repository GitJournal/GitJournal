/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:git_setup/keygen.dart';
import 'package:git_setup/sshkey.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/settings/git_config.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/storage_config.dart';
import 'package:gitjournal/settings/widgets/settings_list_preference.dart';
import 'package:gitjournal/ssh/keygen.dart';
import 'package:gitjournal/utils/utils.dart';
import 'package:gitjournal/widgets/future_builder_with_progress.dart';
import 'package:gitjournal/widgets/setup.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:universal_io/io.dart';

class GitRemoteSettingsScreen extends StatefulWidget {
  static const routePath = '/settings/gitRemote';

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
    var settings = context.watch<Settings>();
    var gitConfig = context.watch<GitConfig>();
    var repo = context.watch<GitJournalRepo>();

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (remoteHost.isNotEmpty)
          Text(
            context.loc.settingsGitRemoteHost,
            style: textTheme.bodyLarge,
            textAlign: TextAlign.left,
          ),
        if (remoteHost.isNotEmpty) ListTile(title: Text(remoteHost)),
        if (branches.isNotEmpty)
          ListPreference(
            title: context.loc.settingsGitRemoteBranch,
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
          context.loc.setupSshKeyUserProvidedPublic,
          style: textTheme.bodyLarge,
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 16.0),
        PublicKeyWidget(gitConfig.sshPublicKey),
        const SizedBox(height: 16.0),
        const Divider(),
        Builder(
          builder: (BuildContext context) => Button(
            text: context.loc.setupSshKeyCopy,
            onPressed: () => _copyKeyToClipboard(context),
          ),
        ),
        Builder(
          builder: (BuildContext context) => Button(
            text: context.loc.setupSshKeyRegenerate,
            onPressed: () => _generateSshKey(context),
          ),
        ),
        Builder(
          builder: (BuildContext context) => Button(
            text: context.loc.setupSshKeyChoiceCustom,
            onPressed: _customSshKeys,
          ),
        ),
        ListPreference(
          title: context.loc.settingsSshSyncFreq,
          currentOption: settings.remoteSyncFrequency.toPublicString(context),
          options: RemoteSyncFrequency.options
              .map((f) => f.toPublicString(context))
              .toList(),
          onChange: (String publicStr) {
            var val = RemoteSyncFrequency.fromPublicString(context, publicStr);
            settings.remoteSyncFrequency = val;
            settings.save();
            setState(() {});
          },
        ),
        RedButton(
          text: context.loc.settingsGitRemoteChangeHostTitle,
          onPressed: _reconfigureGitHost,
        ),
        FutureBuilderWithProgress(future: () async {
          try {
            var repo = context.watch<GitJournalRepo>();
            var canReset = await repo.canResetHard();
            if (!canReset) {
              return const SizedBox();
            }

            return RedButton(
              text: context.loc.settingsGitRemoteResetHardTitle,
              onPressed: _resetGitHost,
            );
          } catch (ex, st) {
            Log.e("SettingsGitRemote", ex: ex, stacktrace: st);
            return const SizedBox();
          }
        }()),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.settingsGitRemoteTitle),
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
          saveText: context.loc.setupSshKeySave,
        ),
        appBar: AppBar(
          title: Text(context.loc.setupSshKeyChoiceCustom),
        ),
      ),
      settings: const RouteSettings(name: '/settings/gitRemote/customKeys'),
    );
    Navigator.push(context, route);
  }

  void _updateKeys(String publicKey, String privateKey, String password) {
    var config = context.read<GitConfig>();

    if (publicKey.isEmpty || privateKey.isEmpty) {
      return;
    }
    config.sshPublicKey = publicKey;
    config.sshPrivateKey = privateKey;
    config.sshPassword = password;
    config.save();

    Navigator.of(context).pop();
  }

  void _copyKeyToClipboard(BuildContext context) {
    var gitConfig = context.read<GitConfig>();
    Clipboard.setData(ClipboardData(text: gitConfig.sshPublicKey));
    showSnackbar(context, context.loc.setupSshKeyCopied);
  }

  void _generateSshKey(BuildContext context) {
    var keyType = context.read<GitConfig>().sshKeyType;
    var comment =
        "GitJournal-${Platform.operatingSystem}-${DateTime.now().toIso8601String().substring(0, 10)}"; // only the date

    GitJournalKeygen()
        .generate(type: keyType, comment: comment)
        .then((SshKey? sshKey) {
      var config = context.read<GitConfig>();
      config.sshPublicKey = sshKey!.publicKey;
      config.sshPrivateKey = sshKey.publicKey;
      config.sshPassword = sshKey.password;
      config.save();

      Log.d("PublicKey: ${sshKey.publicKey}");
      _copyKeyToClipboard(context);
    });
  }

  Future<void> _reconfigureGitHost() async {
    var ok = await showDialog(
      context: context,
      builder: (_) => IrreversibleActionConfirmationDialog(
        title: context.loc.settingsGitRemoteChangeHostTitle,
        subtitle: context.loc.settingsGitRemoteChangeHostSubtitle,
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
        try {
          await repo.init(repoFolderPath);
        } catch (ex) {
          showErrorSnackbar(context, ex);
        }
        break;
      }
      num++;
    }
    repoFolderName = repoFolderName + num.toString();

    var storageConfig = context.read<StorageConfig>();
    storageConfig.folderName = repoFolderName;
    storageConfig.storeInternally = true;
    await storageConfig.save();

    var route = MaterialPageRoute(
      builder: (context) => GitJournalGitSetupScreen(
        repoFolderName: repoFolderName,
        onCompletedFunction: repo.completeGitHostSetup,
      ),
      settings: const RouteSettings(name: '/setupRemoteGit'),
    );
    await Navigator.push(context, route);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _resetGitHost() async {
    var ok = await showDialog(
      context: context,
      builder: (_) => IrreversibleActionConfirmationDialog(
        title: context.loc.settingsGitRemoteResetHardTitle,
        subtitle: context.loc.settingsGitRemoteResetHardSubtitle,
      ),
    );
    if (ok == null) {
      return;
    }

    try {
      var repo = context.read<GitJournalRepo>();
      await repo.resetHard();
    } catch (ex) {
      showErrorSnackbar(context, ex);
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class Button extends StatelessWidget {
  final String text;
  final void Function() onPressed;

  const Button({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
              WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
    );
  }
}

class RedButton extends StatelessWidget {
  final String text;
  final void Function() onPressed;

  const RedButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
        ),
        onPressed: onPressed,
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}

class IrreversibleActionConfirmationDialog extends StatelessWidget {
  final String title;
  final String subtitle;

  const IrreversibleActionConfirmationDialog(
      {required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(subtitle),
      actions: <Widget>[
        TextButton(
          child: Text(context.loc.settingsGitRemoteChangeHostCancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(context.loc.settingsGitRemoteChangeHostOk),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
