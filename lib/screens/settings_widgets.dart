import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gitjournal/settings.dart';

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
                var tile = LabeledRadio(
                  label: o,
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
                content: Column(
                  children: children,
                  mainAxisSize: MainAxisSize.min,
                ),
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

class ProSettingOverlay extends StatelessWidget {
  final Widget child;

  ProSettingOverlay({@required this.child});

  @override
  Widget build(BuildContext context) {
    if (Settings.instance.proMode) {
      return child;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Banner(
        message: tr('pro'),
        location: BannerLocation.topEnd,
        color: Theme.of(context).accentColor,
        child: IgnorePointer(child: Opacity(opacity: 0.5, child: child)),
      ),
      onTap: () {
        Navigator.pushNamed(context, "/purchase");
      },
    );
  }
}

class LabeledRadio extends StatelessWidget {
  const LabeledRadio({
    this.label,
    this.groupValue,
    this.value,
    this.onChanged,
  });

  final String label;
  final String groupValue;
  final String value;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (value != groupValue) onChanged(value);
      },
      child: Row(
        children: <Widget>[
          Radio<String>(
            groupValue: groupValue,
            value: value,
            onChanged: onChanged,
          ),
          Text(label),
        ],
      ),
    );
  }
}
