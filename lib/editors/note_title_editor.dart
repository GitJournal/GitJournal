/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/l10n.dart';

class NoteTitleEditor extends StatelessWidget {
  final TextEditingController textController;
  final Function onChanged;

  const NoteTitleEditor(this.textController, this.onChanged);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.headline6;

    return TextField(
      keyboardType: TextInputType.text,
      style: style,
      decoration: InputDecoration(
        hintText: context.loc.editorsCommonDefaultTitleHint,
        border: InputBorder.none,
        fillColor: theme.scaffoldBackgroundColor,
        hoverColor: theme.scaffoldBackgroundColor,
        contentPadding: const EdgeInsets.all(0.0),
      ),
      controller: textController,
      textCapitalization: TextCapitalization.sentences,
      maxLines: null,
      onChanged: (_) => onChanged(),
    );
  }
}
