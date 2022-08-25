/*
 * SPDX-FileCopyrightText: 2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/widgets.dart';

import 'package:function_types/function_types.dart';

import 'package:gitjournal/settings/git_config.dart';
import 'package:gitjournal/settings/widgets/settings_list_preference.dart';

class ListOptionPreference<T extends SettingsOption> extends StatelessWidget {
  final String title;
  final SettingsOption? currentOption;
  final T defaultValue;
  final List<T> values;
  final Func1<T, void> onChange;
  final bool enabled;

  const ListOptionPreference({
    required this.title,
    required this.defaultValue,
    required this.values,
    required this.currentOption,
    required this.onChange,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListPreference(
      title: title,
      currentOption: currentOption?.toPublicString(),
      options: values.map((e) => e.toPublicString()).toList(),
      onChange: (str) {
        var val = values.firstWhere(
          (e) => e.toPublicString() == str,
          orElse: () => defaultValue,
        );
        onChange(val);
      },
    );
  }
}
