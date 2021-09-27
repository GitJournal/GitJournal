/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:gitjournal/generated/locale_keys.g.dart';

class NoteBodyEditor extends StatelessWidget {
  final TextEditingController textController;
  final bool autofocus;
  final Function onChanged;

  const NoteBodyEditor({
    Key? key,
    required this.textController,
    required this.autofocus,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return TextField(
      autofocus: autofocus,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      style: textStyle(context),
      decoration: InputDecoration(
        hintText: tr(LocaleKeys.editors_common_defaultBodyHint),
        border: InputBorder.none,
        fillColor: theme.scaffoldBackgroundColor,
        hoverColor: theme.scaffoldBackgroundColor,
        contentPadding: const EdgeInsets.all(0.0),
      ),
      controller: textController,
      textCapitalization: TextCapitalization.sentences,
      scrollPadding: const EdgeInsets.all(0.0),
      onChanged: (_) => onChanged(),
    );
  }

  static TextStyle textStyle(BuildContext context) {
    var theme = Theme.of(context);
    return theme.textTheme.subtitle1!;
  }
}
