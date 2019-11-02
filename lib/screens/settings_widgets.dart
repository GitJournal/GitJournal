import 'package:flutter/material.dart';

class ListPreference extends StatelessWidget {
  final String title;
  final String currentOption;
  final List<String> options;
  final Function onChange;
  final bool enabled;

  ListPreference({
    @required this.title,
    @required this.currentOption,
    @required this.options,
    @required this.onChange,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(currentOption),
      onTap: () async {
        var option = await showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              var children = <Widget>[];
              for (var o in options) {
                var tile = RadioListTile<String>(
                  title: Text(o),
                  value: o,
                  groupValue: currentOption,
                  onChanged: (String val) {
                    Navigator.of(context).pop(val);
                  },
                );
                children.add(tile);
              }
              return AlertDialog(
                title: Text(title),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: children,
                  ),
                ),
                contentPadding: const EdgeInsets.all(0.0),
                actions: <Widget>[
                  FlatButton(
                    child: const Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });

        if (option != null) {
          onChange(option);
        }
      },
      enabled: enabled,
    );
  }
}

class BoolPreference extends StatelessWidget {
  final String title;
  final bool defaultValue;
  final Function(bool) onChange;

  BoolPreference({
    @required this.title,
    @required this.defaultValue,
    @required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Switch(
        value: defaultValue,
        onChanged: onChange,
      ),
      onTap: () => onChange(!defaultValue),
    );
  }
}
