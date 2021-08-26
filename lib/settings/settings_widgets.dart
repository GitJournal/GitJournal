import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';

class ListPreference extends StatelessWidget {
  final String title;
  final String? currentOption;
  final List<String> options;
  final Function onChange;
  final bool enabled;

  ListPreference({
    required this.title,
    required this.currentOption,
    required this.options,
    required this.onChange,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(currentOption!),
      onTap: () async {
        var option = await showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              var children = <Widget>[];
              for (var o in options) {
                var tile = _LabeledRadio(
                  label: o,
                  value: o,
                  groupValue: currentOption,
                  onChanged: (String? val) {
                    Navigator.of(context).pop(val);
                  },
                );
                children.add(tile);
              }
              return AlertDialog(
                title: Text(title),
                content: SingleChildScrollView(
                  child: Column(
                    children: children,
                    mainAxisSize: MainAxisSize.min,
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(tr(LocaleKeys.settings_cancel)),
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

class _LabeledRadio extends StatelessWidget {
  const _LabeledRadio({
    required this.label,
    required this.groupValue,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String? groupValue;
  final String? value;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (value != groupValue) onChanged(value);
      },
      child: Row(
        children: <Widget>[
          Radio<String?>(
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
