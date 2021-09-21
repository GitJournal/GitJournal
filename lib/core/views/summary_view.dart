/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/transformers/base.dart';
import 'package:gitjournal/utils/markdown.dart';
import 'notes_materialized_view.dart';

typedef NotesSummaryView = NotesMaterializedView<String>;

class NoteSummaryProvider extends SingleChildStatelessWidget {
  final String repoPath;

  const NoteSummaryProvider({
    Key? key,
    Widget? child,
    required this.repoPath,
  }) : super(key: key, child: child);

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Provider(
      create: (_) {
        return NotesMaterializedView<String>(
          name: 'summary',
          repoPath: repoPath,
          computeFn: _compute,
        );
      },
      child: child,
    );
  }

  static NotesSummaryView of(BuildContext context) {
    return Provider.of<NotesSummaryView>(context);
  }
}

// FIXME: When building this, take the title type into account
//         If the summary starts with the title, then remove it
Future<String> _compute(Note note) async {
  return stripMarkdownFormatting(note.body);
}
