/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dart_git/dart_git.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:universal_io/io.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/settings/git_config.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/storage_config.dart';
import 'package:gitjournal/settings/widgets/settings_list_preference.dart';
import 'package:gitjournal/setup/screens.dart';
import 'package:gitjournal/setup/sshkey.dart';
import 'package:gitjournal/ssh/keygen.dart';
import 'package:gitjournal/utils/utils.dart';
import 'package:gitjournal/widgets/future_builder_with_progress.dart';

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
    var settings = Provider.of<Settings>(context);
    var gitConfig = Provider.of<GitConfig>(context);
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
            tr(LocaleKeys.settings_gitRemote_host),
            style: textTheme.bodyText1,
            textAlign: TextAlign.left,
          ),
        if (remoteHost.isNotEmpty) ListTile(title: Text(remoteHost)),
        if (branches.isNotEmpty)
          ListPreference(
            title: tr(LocaleKeys.settings_gitRemote_branch),
            currentOption: currentBranch, // FIXME
            options: branches,
            onChange: (String branch) {
              var _ = repo.checkoutBranch(branch);
              setState(() {
                currentBranch = branch;
              });
            },
          ),
        const SizedBox(height: 8.0),
        Text(
          tr(LocaleKeys.setup_sshKeyUserProvided_public),
          style: textTheme.bodyText1,
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 16.0),
        PublicKeyWidget(gitConfig.sshPublicKey),
        const SizedBox(height: 16.0),
        const Divider(),
        Builder(
          builder: (BuildContext context) => Button(
            text: tr(LocaleKeys.setup_sshKey_copy),
            onPressed: () => _copyKeyToClipboard(context),
          ),
        ),
        Builder(
          builder: (BuildContext context) => Button(
            text: tr(LocaleKeys.setup_sshKey_regenerate),
            onPressed: () => _generateSshKey(context),
          ),
        ),
        Builder(
          builder: (BuildContext context) => Button(
            text: tr(LocaleKeys.setup_sshKeyChoice_custom),
            onPressed: _customSshKeys,
          ),
        ),
        ListPreference(
          title: tr(LocaleKeys.settings_ssh_syncFreq),
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
          text: tr(LocaleKeys.settings_gitRemote_changeHost_title),
          onPressed: _reconfigureGitHost,
        ),
        FutureBuilderWithProgress(future: () async {
          var repo = context.watch<GitJournalRepo>();
          var result = await repo.canResetHard();
          if (result.isFailure) {
            showSnackbar(context, result.error.toString());
            return const SizedBox();
          }
          var canReset = result.getOrThrow();
          if (!canReset) {
            return const SizedBox();
          }

          return RedButton(
            text: tr(LocaleKeys.settings_gitRemote_resetHard_title),
            onPressed: _resetGitHost,
          );
        }()),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(LocaleKeys.settings_gitRemote_title)),
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
          saveText: tr(LocaleKeys.setup_sshKey_save),
        ),
        appBar: AppBar(
          title: Text(tr(LocaleKeys.setup_sshKeyChoice_custom)),
        ),
      ),
      settings: const RouteSettings(name: '/settings/gitRemote/customKeys'),
    );
    var _ = Navigator.push(context, route);
  }

  void _updateKeys(String publicKey, String privateKey, String password) {
    var config = Provider.of<GitConfig>(context, listen: false);

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
    showSnackbar(context, tr(LocaleKeys.setup_sshKey_copied));
  }

  void _generateSshKey(BuildContext context) {
    var comment = "GitJournal-" +
        Platform.operatingSystem +
        "-" +
        DateTime.now().toIso8601String().substring(0, 10); // only the date

    generateSSHKeys(comment: comment).then((SshKey? sshKey) {
      var config = Provider.of<GitConfig>(context, listen: false);
      config.sshPublicKey = sshKey!.publicKey;
      config.sshPrivateKey = sshKey.publicKey;
      config.sshPassword = sshKey.password;
      config.save();

      Log.d("PublicKey: " + sshKey.publicKey);
      _copyKeyToClipboard(context);
    });
  }

  Future<void> _reconfigureGitHost() async {
    var ok = await showDialog(
      context: context,
      builder: (_) => IrreversibleActionConfirmationDialog(
        title: LocaleKeys.settings_gitRemote_changeHost_title.tr(),
        subtitle: LocaleKeys.settings_gitRemote_changeHost_subtitle.tr(),
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
        var r = await GitRepository.init(repoFolderPath, defaultBranch: 'main');
        showResultError(context, r);
        break;
      }
      num++;
    }
    repoFolderName = repoFolderName + num.toString();

    var storageConfig = Provider.of<StorageConfig>(context, listen: false);
    storageConfig.folderName = repoFolderName;
    storageConfig.storeInternally = true;
    await storageConfig.save();

    var route = MaterialPageRoute(
      builder: (context) => GitHostSetupScreen(
        repoFolderName: repoFolderName,
        remoteName: 'origin',
        onCompletedFunction: repo.completeGitHostSetup,
      ),
      settings: const RouteSettings(name: '/setupRemoteGit'),
    );
    var _ = await Navigator.push(context, route);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _resetGitHost() async {
    var ok = await showDialog(
      context: context,
      builder: (_) => IrreversibleActionConfirmationDialog(
        title: LocaleKeys.settings_gitRemote_resetHard_title.tr(),
        subtitle: LocaleKeys.settings_gitRemote_resetHard_subtitle.tr(),
      ),
    );
    if (ok == null) {
      return;
    }

    var repo = context.read<GitJournalRepo>();
    var result = await repo.resetHard();
    if (result.isFailure) {
      showSnackbar(context, result.error.toString());
      return;
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

  const RedButton({required this.text, required this.onPressed});

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
          child: Text(LocaleKeys.settings_gitRemote_changeHost_cancel.tr()),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(LocaleKeys.settings_gitRemote_changeHost_ok.tr()),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
