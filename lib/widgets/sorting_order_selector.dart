import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:gitjournal/core/sorting_mode.dart';

class SortingOrderSelector extends StatelessWidget {
  final SortingMode selectedMode;

  SortingOrderSelector(this.selectedMode);

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      _buildSortingTile(context, SortingMode.Modified),
      _buildSortingTile(context, SortingMode.Created),
      _buildSortingTile(context, SortingMode.Title),
      _buildSortingTile(context, SortingMode.FileName),
    ];

    return AlertDialog(
      title: Text(tr("widgets.SortingOrderSelector.title")),
      content: Column(
        children: children,
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }

  RadioListTile<SortingMode> _buildSortingTile(
    BuildContext context,
    SortingMode sm,
  ) {
    return RadioListTile<SortingMode>(
      title: Text(sm.toPublicString()),
      value: sm,
      groupValue: selectedMode,
      onChanged: (SortingMode sm) => Navigator.of(context).pop(sm),
    );
  }
}
