import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:journal/analytics.dart';

class GitHostSetupUrl extends StatefulWidget {
  final Function doneFunction;

  GitHostSetupUrl({@required this.doneFunction});

  @override
  GitHostSetupUrlState createState() {
    return GitHostSetupUrlState();
  }
}

class GitHostSetupUrlState extends State<GitHostSetupUrl> {
  final GlobalKey<FormFieldState<String>> sshUrlKey =
      GlobalKey<FormFieldState<String>>();

  final _formKey = GlobalKey<FormState>();
  final inputFormFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final formSubmitted = () {
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();

        var url = sshUrlKey.currentState.value;
        this.widget.doneFunction(url.trim());
        inputFormFocus.unfocus();
      }
    };

    var inputForm = Form(
      key: _formKey,
      child: TextFormField(
        key: sshUrlKey,
        textAlign: TextAlign.center,
        autofocus: true,
        style: Theme.of(context).textTheme.title,
        decoration: const InputDecoration(
          hintText: 'git@github.com:GitJournal/GitJournal.git',
        ),
        validator: (String value) {
          value = value.trim();
          if (value.isEmpty) {
            return 'Please enter some text';
          }
          if (value.startsWith('https://') || value.startsWith('http://')) {
            return 'Only SSH urls are currently accepted';
          }

          RegExp regExp = RegExp(r"[a-zA-Z0-9.]+@[a-zA-Z0-9.]+:.+");
          if (!regExp.hasMatch(value)) {
            return "Invalid Input";
          }
        },
        focusNode: inputFormFocus,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (String _) => formSubmitted(),
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Enter the Git Clone URL",
            style: Theme.of(context).textTheme.headline,
          ),
        ),
        SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: inputForm,
        ),
        SizedBox(height: 8.0),
        GitHostSetupButton(
          text: "Next",
          onPressed: formSubmitted,
        ),
      ],
    );
  }
}

class GitHostSetupButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  final String iconUrl;

  GitHostSetupButton({
    @required this.text,
    @required this.onPressed,
    this.iconUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (iconUrl == null) {
      return SizedBox(
        width: double.infinity,
        child: RaisedButton(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.button,
          ),
          color: Theme.of(context).primaryColor,
          onPressed: this._onPressedWithAnalytics,
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: RaisedButton.icon(
          label: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.button,
          ),
          icon: Image.asset(iconUrl, width: 32, height: 32),
          color: Theme.of(context).primaryColor,
          onPressed: this._onPressedWithAnalytics,
        ),
      );
    }
  }

  void _onPressedWithAnalytics() {
    print("githostsetup_button_click " + text);
    getAnalytics().logEvent(
      name: "githostsetup_button_click",
      parameters: <String, dynamic>{
        'text': text,
        'icon_url': iconUrl == null ? "" : iconUrl,
      },
    );
    onPressed();
  }
}
