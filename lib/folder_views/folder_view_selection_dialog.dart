/*
 * SPDX-FileCopyrightText: 2023 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/folder_views/common_types.dart';
import 'package:gitjournal/l10n.dart';

class FolderViewSelectionDialog extends StatelessWidget {
  final FolderViewType viewType;
  final void Function(FolderViewType?) onViewChange;

  const FolderViewSelectionDialog({
    super.key,
    required this.viewType,
    required this.onViewChange,
  });

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      RadioListTile<FolderViewType>(
        title: Text(context.loc.widgetsFolderViewViewsStandard),
        value: FolderViewType.Standard,
        groupValue: viewType,
        onChanged: onViewChange,
      ),
      RadioListTile<FolderViewType>(
        title: Text(context.loc.widgetsFolderViewViewsJournal),
        value: FolderViewType.Journal,
        groupValue: viewType,
        onChanged: onViewChange,
      ),
      RadioListTile<FolderViewType>(
        title: Text(context.loc.widgetsFolderViewViewsGrid),
        value: FolderViewType.Grid,
        groupValue: viewType,
        onChanged: onViewChange,
      ),
      RadioListTile<FolderViewType>(
        title: Text(context.loc.widgetsFolderViewViewsCard),
        value: FolderViewType.Card,
        groupValue: viewType,
        onChanged: onViewChange,
      ),
      // RadioListTile<FolderViewType>(
      //   title: Text(context.loc.widgetsFolderViewViewsCalendar),
      //   value: FolderViewType.Calendar,
      //   groupValue: viewType,
      //   onChanged: onViewChange,
      // ),
    ];

    return AlertDialog(
      title: Text(context.loc.widgetsFolderViewViewsSelect),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
