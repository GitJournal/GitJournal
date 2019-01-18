import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SettingsForms(),
    );
  }
}

class SettingsForms extends StatefulWidget {
  @override
  SettingsFormsState createState() {
    return new SettingsFormsState();
  }
}

class SettingsFormsState extends State<SettingsForms> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            VersionNumberButton(),
          ],
        ),
      ),
    );
  }
}

class VersionNumberButton extends StatefulWidget {
  @override
  VersionNumberButtonState createState() {
    return new VersionNumberButtonState();
  }
}

class VersionNumberButtonState extends State<VersionNumberButton> {
  PackageInfo packageInfo;

  @override
  void initState() {
    super.initState();

    () async {
      PackageInfo info = await PackageInfo.fromPlatform();
      setState(() {
        packageInfo = info;
      });
    }();
  }

  @override
  Widget build(BuildContext context) {
    var text = "";
    if (packageInfo != null) {
      text = packageInfo.appName +
          " " +
          packageInfo.version +
          "+" +
          packageInfo.buildNumber;
    }

    return FlatButton(
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text,
          style: Theme.of(context).textTheme.subhead,
          textAlign: TextAlign.left,
        ),
      ),
      onPressed: () {},
    );
  }
}
