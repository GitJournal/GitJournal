import 'package:flutter/material.dart';

import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/transformers/base.dart';
import 'package:gitjournal/utils/markdown.dart';
import 'notes_materialized_view.dart';

class NoteSummaryView extends SingleChildStatelessWidget {
  final String repoPath;

  NoteSummaryView({
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

  static NotesMaterializedView<String> of(BuildContext context) {
    return Provider.of<NotesMaterializedView<String>>(context);
  }
}

// FIXME: When building this, take the title type into account
//         If the summary starts with the title, then remove it
Future<String> _compute(Note note) async {
  return stripMarkdownFormatting(note.body);
}
