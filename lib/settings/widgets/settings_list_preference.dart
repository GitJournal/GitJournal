/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:function_types/function_types.dart';
import 'package:gitjournal/l10n.dart';

class ListPreference extends StatelessWidget {
  final String title;
  final String? currentOption;
  final List<String> options;
  final Func1<String, void> onChange;
  final bool enabled;
  final Widget Function(String? currentOption, String option)?
      optionLabelBuilder;
  final List<Widget> Function(BuildContext context, String? currentOption)?
      actionsBuilder;

  const ListPreference({
    required this.title,
    required this.currentOption,
    required this.options,
    required this.onChange,
    this.enabled = true,
    super.key,
    this.optionLabelBuilder,
    this.actionsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(currentOption!),
      onTap: () async {
        var option = await showDialog<String>(
          context: context,
          builder: (_) => ListPreferenceSelectionDialog(
            title: title,
            options: options,
            currentOption: currentOption,
            actionsBuilder: actionsBuilder,
            optionLabelBuilder: optionLabelBuilder,
          ),
        );

        if (option != null) {
          onChange(option);
        }
      },
      enabled: enabled,
    );
  }
}

class ListPreferenceSelectionDialog extends StatelessWidget {
  final List<String> options;
  final String? currentOption;
  final String title;
  final List<Widget> Function(BuildContext context, String? currentOption)?
      actionsBuilder;
  final Widget Function(String? currentOption, String option)?
      optionLabelBuilder;

  const ListPreferenceSelectionDialog({
    super.key,
    required this.options,
    this.currentOption,
    required this.title,
    this.actionsBuilder,
    this.optionLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      content: SizedBox(
        width: double.maxFinite,
        child: ScrollConfiguration(
          behavior: _NoScrollBehavior(),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (var o in options)
                _LabeledRadio(
                  label: optionLabelBuilder != null
            ? optionLabelBuilder!(currentOption, o)
            : Text(o),
                  value: o,
                  groupValue: currentOption,
                  onChanged: (String? val) {
                    Navigator.of(context).pop(val);
                  },
                ),
            ],
          ),
        ),
      ),
      contentPadding: EdgeInsets.zero,
      actions: actionsBuilder != null
          ? actionsBuilder!(context, currentOption)
          : <Widget>[
              TextButton(
                child: Text(context.loc.settingsCancel),
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

  final Widget label;
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
            label,
          ],
        ),
      ),
    );
  }
}

class _NoScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
