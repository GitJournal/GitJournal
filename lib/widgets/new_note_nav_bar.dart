/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:function_types/function_types.dart';

import 'package:gitjournal/editors/common_types.dart';

// FIXME: Remove note_editor import!!

class NewNoteNavBar extends StatelessWidget {
  final Func1<EditorType, void> onPressed;

  const NewNoteNavBar({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context).bottomAppBarColor,
      shape: const CircularNotchedRectangle(),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconButton(
              icon: const FaIcon(FontAwesomeIcons.tasks),
              onPressed: () => onPressed(EditorType.Checklist),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconButton(
              icon: const FaIcon(FontAwesomeIcons.markdown),
              onPressed: () => onPressed(EditorType.Markdown),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconButton(
              icon: const FaIcon(FontAwesomeIcons.book),
              onPressed: () => onPressed(EditorType.Journal),
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }
}
