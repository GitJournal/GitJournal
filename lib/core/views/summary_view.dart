import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:gitjournal/core/transformers/base.dart';
import 'package:gitjournal/utils/markdown.dart';
import 'notes_materialized_view.dart';

class NoteSummaryView extends StatelessWidget {
  final Widget child;
  final String repoPath;

  NoteSummaryView({
    Key? key,
    required this.child,
    required this.repoPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureProvider(
      create: (_) {
        return NotesMaterializedView.loadView<String>(
          name: 'summary',
          repoPath: repoPath,
          computeFn: _compute,
        );
      },
      initialData: null,
      child: child,
    );
  }

  static NotesMaterializedView<String>? of(BuildContext context) {
    return Provider.of<NotesMaterializedView<String>?>(context);
  }
}

// FIXME: When building this, take the title type into account
//         If the summary starts with the title, then remove it
String _compute(Note note) {
  return stripMarkdownFormatting(note.body);
}
