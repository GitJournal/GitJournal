/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:function_types/function_types.dart';
import 'package:gitjournal/l10n.dart';

import 'button.dart';
import 'key_editors.dart';
import 'loading.dart';

class GitHostSetupSshKeyKnownProviderPage extends StatelessWidget {
  final Func0<void> doneFunction;
  final Func0<void> regenerateFunction;
  final Func1<BuildContext, void> copyKeyFunction;
  final String? publicKey;

  final Func0<void> openDeployKeyPage;

  const GitHostSetupSshKeyKnownProviderPage({
    required this.doneFunction,
    required this.regenerateFunction,
    required this.copyKeyFunction,
    required this.openDeployKeyPage,
    required this.publicKey,
  });

  @override
  Widget build(BuildContext context) {
    if (publicKey == null || publicKey!.isEmpty) {
      return GitHostSetupLoadingPage(context.loc.setup.sshKey.generate);
    }

    var columns = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.loc.setup.sshKey.title,
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 32.0),

        // Step 1
        Text(
          context.loc.setup.sshKey.step1,
          style: Theme.of(context).textTheme.subtitle2,
        ),
        const SizedBox(height: 8.0),
        PublicKeyWidget(publicKey!),
        const SizedBox(height: 8.0),

        GitHostSetupButton(
          text: context.loc.setup.sshKey.copy,
          onPressed: () => copyKeyFunction(context),
        ),
        GitHostSetupButton(
          text: context.loc.setup.sshKey.regenerate,
          onPressed: regenerateFunction,
        ),
        const SizedBox(height: 16.0),

        // Step 2
        Text(
          context.loc.setup.sshKey.step2a,
          style: Theme.of(context).textTheme.subtitle2,
        ),
        const SizedBox(height: 8.0),
        GitHostSetupButton(
          text: context.loc.setup.sshKey.openDeploy,
          onPressed: openDeployKeyPage,
        ),
        const SizedBox(height: 16.0),

        // Step 3
        Text(
          context.loc.setup.sshKey.step3,
          style: Theme.of(context).textTheme.subtitle2,
        ),
        const SizedBox(height: 8.0),
        GitHostSetupButton(
          text: context.loc.setup.sshKey.clone,
          onPressed: doneFunction,
        ),
      ],
    );

    return Center(
      child: SingleChildScrollView(
        child: columns,
      ),
    );
  }
}

class GitHostSetupSshKeyUnknownProviderPage extends StatelessWidget {
  final Func0<void> doneFunction;
  final Func0<void> regenerateFunction;
  final Func1<BuildContext, void> copyKeyFunction;
  final String? publicKey;

  const GitHostSetupSshKeyUnknownProviderPage({
    required this.doneFunction,
    required this.regenerateFunction,
    required this.copyKeyFunction,
    required this.publicKey,
  });

  @override
  Widget build(BuildContext context) {
    if (publicKey == null || publicKey!.isEmpty) {
      return GitHostSetupLoadingPage(context.loc.setup.sshKey.generate);
    }

    var columns = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          context.loc.setup.sshKey.title,
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 32.0),

        // Step 1
        Text(
          context.loc.setup.sshKey.step1,
          style: Theme.of(context).textTheme.subtitle2,
        ),
        const SizedBox(height: 8.0),
        PublicKeyWidget(publicKey!),
        const SizedBox(height: 8.0),

        GitHostSetupButton(
          text: context.loc.setup.sshKey.copy,
          onPressed: () => copyKeyFunction(context),
        ),
        GitHostSetupButton(
          text: context.loc.setup.sshKey.regenerate,
          onPressed: regenerateFunction,
        ),
        const SizedBox(height: 16.0),

        // Step 2
        Text(
          context.loc.setup.sshKey.step2b,
          style: Theme.of(context).textTheme.subtitle2,
        ),
        const SizedBox(height: 16.0),

        // Step 3
        Text(
          context.loc.setup.sshKey.step3,
          style: Theme.of(context).textTheme.subtitle2,
        ),
        const SizedBox(height: 8.0),
        GitHostSetupButton(
          text: context.loc.setup.sshKey.clone,
          onPressed: doneFunction,
        ),
      ],
    );

    return Center(
      child: SingleChildScrollView(
        child: columns,
      ),
    );
  }
}

class GitHostSetupKeyChoicePage extends StatelessWidget {
  final Func0<void> onGenerateKeys;
  final Func0<void> onUserProvidedKeys;

  const GitHostSetupKeyChoicePage({
    required this.onGenerateKeys,
    required this.onUserProvidedKeys,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          context.loc.setup.sshKeyChoice.title,
          style: Theme.of(context).textTheme.headline5,
        ),
        const SizedBox(height: 16.0),
        GitHostSetupButton(
          text: context.loc.setup.sshKeyChoice.generate,
          onPressed: onGenerateKeys,
        ),
        const SizedBox(height: 8.0),
        GitHostSetupButton(
          text: context.loc.setup.sshKeyChoice.custom,
          onPressed: onUserProvidedKeys,
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}

class GitHostUserProvidedKeysPage extends StatefulWidget {
  final Func3<String, String, String, void>
      doneFunction; // public, private, password
  final String saveText;

  const GitHostUserProvidedKeysPage({
    required this.doneFunction,
    this.saveText = "",
  });

  @override
  _GitHostUserProvidedKeysPageState createState() =>
      _GitHostUserProvidedKeysPageState();
}

class _GitHostUserProvidedKeysPageState
    extends State<GitHostUserProvidedKeysPage> {
  late GlobalKey<FormState> _publicFormKey;
  late GlobalKey<FormState> _privateFormKey;
  late TextEditingController _publicKeyController;
  late TextEditingController _privateKeyController;
  late TextEditingController _passwordController;

  late String saveText;

  @override
  void initState() {
    super.initState();

    _publicFormKey = GlobalKey<FormState>();
    _privateFormKey = GlobalKey<FormState>();
    _publicKeyController = TextEditingController();
    _privateKeyController = TextEditingController();
    _passwordController = TextEditingController();

    saveText =
        widget.saveText.isEmpty ? context.loc.setupNext : widget.saveText;
  }

  @override
  void dispose() {
    _publicKeyController.dispose();
    _privateKeyController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var body = Column(
      children: <Widget>[
        Text(
          context.loc.setupSshKeyUserProvidedPublic,
          style: Theme.of(context).textTheme.headline5,
        ),
        const SizedBox(height: 8.0),
        PublicKeyEditor(_publicFormKey, _publicKeyController),
        const SizedBox(height: 8.0),
        Text(
          context.loc.setupSshKeyUserProvidedPrivate,
          style: Theme.of(context).textTheme.headline5,
        ),
        const SizedBox(height: 8.0),
        PrivateKeyEditor(_privateFormKey, _privateKeyController),
        const SizedBox(height: 8.0),
        TextField(
          controller: _passwordController,
          maxLines: 1,
          decoration: InputDecoration(
            helperText: context.loc.setupSshKeyUserProvidedPassword,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 16.0),
        GitHostSetupButton(
          text: saveText,
          onPressed: () {
            if (!mounted) return;

            var publicValid = _publicFormKey.currentState?.validate() ?? false;
            var privateValid =
                _privateFormKey.currentState?.validate() ?? false;

            if (!publicValid || !privateValid) {
              return;
            }

            var publicKey = _publicKeyController.text.trim();
            if (!publicKey.endsWith('\n')) {
              publicKey += '\n';
            }

            var privateKey = _privateKeyController.text.trim();
            if (!privateKey.endsWith('\n')) {
              privateKey += '\n';
            }

            widget.doneFunction(
              publicKey,
              privateKey,
              _passwordController.text,
            );
          },
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: body,
      ),
    );
  }
}

class PublicKeyWidget extends StatelessWidget {
  final String publicKey;

  const PublicKeyWidget(this.publicKey);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).splashColor,
      child: _DoubleScrollView(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            publicKey.trim(),
            textAlign: TextAlign.left,
            maxLines: null,
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ),
      ),
    );
  }
}

class _DoubleScrollView extends StatelessWidget {
  final Widget child;
  const _DoubleScrollView({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1000.0,
        child: SingleChildScrollView(child: child),
      ),
    );
  }
}
