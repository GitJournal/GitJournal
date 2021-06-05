import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:gitjournal/core/sorting_mode.dart';
import 'package:gitjournal/settings/settings_screen.dart';

class SortingModeSelector extends StatefulWidget {
  final SortingMode selectedMode;

  SortingModeSelector(this.selectedMode);

  @override
  _SortingModeSelectorState createState() => _SortingModeSelectorState();
}

class _SortingModeSelectorState extends State<SortingModeSelector> {
  late SortingField field;
  late SortingOrder order;

  @override
  void initState() {
    super.initState();
    field = widget.selectedMode.field;
    order = widget.selectedMode.order;
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      SettingsHeader(tr('settings.sortingMode.field')),
      for (var sf in SortingField.options) _buildSortingTile(sf),
      SettingsHeader(tr('settings.sortingMode.order')),
      for (var so in SortingOrder.options) _buildSortingOrderTile(so),
    ];

    return AlertDialog(
      title: Text(tr("widgets.SortingOrderSelector.title")),
      content: Column(
        children: children,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      actions: [
        OutlinedButton(
          key: const ValueKey("Cancel"),
          child: Text(tr('settings.cancel')),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        OutlinedButton(
          key: const ValueKey("Ok"),
          child: Text(tr('settings.ok')),
          onPressed: () {
            Navigator.of(context).pop(SortingMode(field, order));
          },
        ),
      ],
    );
  }

  RadioListTile<SortingField> _buildSortingTile(SortingField sf) {
    return RadioListTile<SortingField>(
      title: Text(sf.toPublicString()),
      value: sf,
      groupValue: field,
      onChanged: (SortingField? sf) {
        setState(() {
          field = sf!;
        });
      },
    );
  }

  RadioListTile<SortingOrder> _buildSortingOrderTile(SortingOrder so) {
    return RadioListTile<SortingOrder>(
      title: Text(so.toPublicString()),
      value: so,
      groupValue: order,
      onChanged: (SortingOrder? so) {
        setState(() {
          order = so!;
        });
      },
    );
  }
}
