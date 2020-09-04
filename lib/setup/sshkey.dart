import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:function_types/function_types.dart';

import 'button.dart';
import 'key_editors.dart';
import 'loading.dart';

class GitHostSetupSshKeyKnownProvider extends StatelessWidget {
  final Func0<void> doneFunction;
  final Func0<void> regenerateFunction;
  final Func1<BuildContext, void> copyKeyFunction;
  final String publicKey;

  final Func0<void> openDeployKeyPage;

  GitHostSetupSshKeyKnownProvider({
    @required this.doneFunction,
    @required this.regenerateFunction,
    @required this.copyKeyFunction,
    @required this.openDeployKeyPage,
    @required this.publicKey,
  });

  @override
  Widget build(BuildContext context) {
    if (publicKey == null || publicKey.isEmpty) {
      return GitHostSetupLoadingPage(tr("setup.sshKey.generate"));
    }

    var columns = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          tr("setup.sshKey.title"),
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 32.0),

        // Step 1
        Text(
          tr("setup.sshKey.step1"),
          style: Theme.of(context).textTheme.subtitle2,
        ),
        const SizedBox(height: 8.0),
        PublicKeyWidget(publicKey),
        const SizedBox(height: 8.0),

        GitHostSetupButton(
          text: tr("setup.sshKey.copy"),
          onPressed: () => copyKeyFunction(context),
        ),
        GitHostSetupButton(
          text: tr("setup.sshKey.regenerate"),
          onPressed: regenerateFunction,
        ),
        const SizedBox(height: 16.0),

        // Step 2
        Text(
          tr("setup.sshKey.step2a"),
          style: Theme.of(context).textTheme.subtitle2,
        ),
        const SizedBox(height: 8.0),
        GitHostSetupButton(
          text: tr("setup.sshKey.openDeploy"),
          onPressed: openDeployKeyPage,
        ),
        const SizedBox(height: 16.0),

        // Step 3
        Text(
          tr("setup.sshKey.step3"),
          style: Theme.of(context).textTheme.subtitle2,
        ),
        const SizedBox(height: 8.0),
        GitHostSetupButton(
          text: tr("setup.sshKey.clone"),
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

class GitHostSetupSshKeyUnknownProvider extends StatelessWidget {
  final Func0<void> doneFunction;
  final Func0<void> regenerateFunction;
  final Func1<BuildContext, void> copyKeyFunction;
  final String publicKey;

  GitHostSetupSshKeyUnknownProvider({
    @required this.doneFunction,
    @required this.regenerateFunction,
    @required this.copyKeyFunction,
    @required this.publicKey,
  });

  @override
  Widget build(BuildContext context) {
    if (publicKey == null || publicKey.isEmpty) {
      return GitHostSetupLoadingPage(tr("setup.sshKey.generate"));
    }

    var columns = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          tr("setup.sshKey.title"),
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 32.0),

        // Step 1
        Text(
          tr("setup.sshKey.step1"),
          style: Theme.of(context).textTheme.subtitle2,
        ),
        const SizedBox(height: 8.0),
        PublicKeyWidget(publicKey),
        const SizedBox(height: 8.0),

        GitHostSetupButton(
          text: tr("setup.sshKey.copy"),
          onPressed: () => copyKeyFunction(context),
        ),
        GitHostSetupButton(
          text: tr("setup.sshKey.regenerate"),
          onPressed: regenerateFunction,
        ),
        const SizedBox(height: 16.0),

        // Step 2
        Text(
          tr("setup.sshKey.step2b"),
          style: Theme.of(context).textTheme.subtitle2,
        ),
        const SizedBox(height: 16.0),

        // Step 3
        Text(
          tr("setup.sshKey.step3"),
          style: Theme.of(context).textTheme.subtitle2,
        ),
        const SizedBox(height: 8.0),
        GitHostSetupButton(
          text: tr("setup.sshKey.clone"),
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

class GitHostSetupKeyChoice extends StatelessWidget {
  final Func0<void> onGenerateKeys;
  final Func0<void> onUserProvidedKeys;

  GitHostSetupKeyChoice({
    @required this.onGenerateKeys,
    @required this.onUserProvidedKeys,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            tr("setup.sshKeyChoice.title"),
            style: Theme.of(context).textTheme.headline5,
          ),
          const SizedBox(height: 16.0),
          GitHostSetupButton(
            text: tr("setup.sshKeyChoice.generate"),
            onPressed: onGenerateKeys,
          ),
          const SizedBox(height: 8.0),
          GitHostSetupButton(
            text: tr("setup.sshKeyChoice.custom"),
            onPressed: onUserProvidedKeys,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}

class GitHostUserProvidedKeys extends StatefulWidget {
  final Func2<String, String, void> doneFunction;

  GitHostUserProvidedKeys({
    @required this.doneFunction,
  });

  @override
  _GitHostUserProvidedKeysState createState() =>
      _GitHostUserProvidedKeysState();
}

class _GitHostUserProvidedKeysState extends State<GitHostUserProvidedKeys> {
  GlobalKey<FormState> _publicFormKey;
  GlobalKey<FormState> _privateFormKey;
  TextEditingController _publicKeyController;
  TextEditingController _privateKeyController;

  @override
  void initState() {
    super.initState();

    _publicFormKey = GlobalKey<FormState>();
    _privateFormKey = GlobalKey<FormState>();
    _publicKeyController = TextEditingController();
    _privateKeyController = TextEditingController();
  }

  @override
  void dispose() {
    _publicKeyController.dispose();
    _privateKeyController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            tr("setup.sshKeyUserProvided.public"),
            style: Theme.of(context).textTheme.headline5,
          ),
          const SizedBox(height: 8.0),
          PublicKeyEditor(_publicFormKey, _publicKeyController),
          const SizedBox(height: 8.0),
          Text(
            tr("setup.sshKeyUserProvided.private"),
            style: Theme.of(context).textTheme.headline5,
          ),
          const SizedBox(height: 8.0),
          PrivateKeyEditor(_privateFormKey, _privateKeyController),
          const SizedBox(height: 16.0),
          GitHostSetupButton(
            text: tr("setup.next"),
            onPressed: () {
              var publicValid = _publicFormKey.currentState.validate();
              var privateValid = _privateFormKey.currentState.validate();

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

              widget.doneFunction(publicKey, privateKey);
            },
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}

class PublicKeyWidget extends StatelessWidget {
  final String publicKey;

  PublicKeyWidget(this.publicKey);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 160.0,
      child: Container(
        color: Theme.of(context).buttonColor,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              publicKey,
              textAlign: TextAlign.left,
              maxLines: null,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        ),
      ),
    );
  }
}
