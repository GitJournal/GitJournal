/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:function_types/function_types.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';

class ListPreference extends StatelessWidget {
  final String title;
  final String? currentOption;
  final List<String> options;
  final Func1<String, void> onChange;
  final bool enabled;

  const ListPreference({
    required this.title,
    required this.currentOption,
    required this.options,
    required this.onChange,
    this.enabled = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(currentOption!),
      onTap: () async {
        var option = await showDialog<String>(
          context: context,
          builder: _dialogBuilder,
        );

        if (option != null) {
          onChange(option);
        }
      },
      enabled: enabled,
    );
  }

  Widget _dialogBuilder(BuildContext context) {
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
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      content: SizedBox(
        width: double.maxFinite,
        child: ScrollConfiguration(
          behavior: _NoScrollBehavior(),
          child: ListView(
            children: children,
            shrinkWrap: true,
          ),
        ),
      ),
      contentPadding: EdgeInsets.zero,
      actions: <Widget>[
        TextButton(
          child: Text(tr(LocaleKeys.settings_cancel)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
      actionsPadding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
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
  final Func1<String?, void> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (value != groupValue) onChanged(value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
      ),
    );
  }
}

class _NoScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
