/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/core/folder/sorting_mode.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/settings/widgets/settings_header.dart';

class SortingModeSelector extends StatefulWidget {
  final SortingMode selectedMode;

  const SortingModeSelector(this.selectedMode);

  @override
  _SortingModeSelectorState createState() => _SortingModeSelectorState();
}

class _SortingModeSelectorState extends State<SortingModeSelector> {
  late SortingField _field;
  late SortingOrder _order;

  @override
  void initState() {
    super.initState();
    _field = widget.selectedMode.field;
    _order = widget.selectedMode.order;
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      SettingsHeader(context.loc.settingsSortingModeField),
      for (var sf in SortingField.options) _buildSortingTile(sf),
      SettingsHeader(context.loc.settingsSortingModeOrder),
      for (var so in SortingOrder.options) _buildSortingOrderTile(so),
    ];

    return AlertDialog(
      title: Text(context.loc.widgetsSortingOrderSelectorTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
      actions: [
        OutlinedButton(
          key: const ValueKey("Cancel"),
          child: Text(
            context.loc.settingsCancel,
            style: Theme.of(context).textTheme.bodyText2,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        OutlinedButton(
          key: const ValueKey("Ok"),
          child: Text(
            context.loc.settingsOk,
            style: Theme.of(context).textTheme.bodyText2,
          ),
          onPressed: () {
            Navigator.of(context).pop(SortingMode(_field, _order));
          },
        ),
      ],
    );
  }

  RadioListTile<SortingField> _buildSortingTile(SortingField sf) {
    return RadioListTile<SortingField>(
      title: Text(sf.toPublicString(context)),
      value: sf,
      groupValue: _field,
      onChanged: (SortingField? sf) {
        setState(() {
          _field = sf!;
        });
      },
    );
  }

  RadioListTile<SortingOrder> _buildSortingOrderTile(SortingOrder so) {
    return RadioListTile<SortingOrder>(
      title: Text(so.toPublicString(context)),
      value: so,
      groupValue: _order,
      onChanged: (SortingOrder? so) {
        setState(() {
          _order = so!;
        });
      },
    );
  }
}
