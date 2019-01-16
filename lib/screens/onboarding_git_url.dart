import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnBoardingGitUrl extends StatefulWidget {
  final Function doneFunction;

  OnBoardingGitUrl({@required this.doneFunction});

  @override
  OnBoardingGitUrlState createState() {
    return new OnBoardingGitUrlState();
  }
}

class OnBoardingGitUrlState extends State<OnBoardingGitUrl> {
  final GlobalKey<FormFieldState<String>> sshUrlKey =
      GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final inputFormFocus = FocusNode();

    final formSubmitted = () {
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();

        var url = sshUrlKey.currentState.value;
        this.widget.doneFunction(url);
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
          hintText: 'Eg: git@github.com:GitJournal/GitJournal.git',
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter some text';
          }
          if (value.startsWith('https://') || value.startsWith('http://')) {
            return 'Only SSH urls are currently accepted';
          }

          RegExp regExp = new RegExp(r"[a-zA-Z0-9.]+@[a-zA-Z0-9.]+:.+");
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Enter the Git SSH URL',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.display1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Container(
            color: Theme.of(context).primaryColorLight,
            child: inputForm,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RaisedButton(
            child: Text("Next"),
            onPressed: formSubmitted,
          ),
        )
      ],
    );
  }
}
