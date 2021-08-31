import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:gitjournal/core/processors/inline_tags.dart';
import 'package:gitjournal/core/transformers/base.dart';
import 'notes_materialized_view.dart';

class InlineTagsView extends StatelessWidget {
  final Widget child;
  final String repoPath;

  InlineTagsView({
    Key? key,
    required this.child,
    required this.repoPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureProvider(
      create: (_) {
        return NotesMaterializedView.loadView<Set<String>>(
          name: 'inline_tags',
          repoPath: repoPath,
          computeFn: _compute,
        );
      },
      initialData: null,
      child: child,
    );
  }

  static NotesMaterializedView<Set<String>>? of(BuildContext context) {
    return Provider.of<NotesMaterializedView<Set<String>>?>(context);
  }
}

// FIXME: When building this, take the title type into account
//         If the summary starts with the title, then remove it
Set<String> _compute(Note note) {
  var tagPrefixes = note.parent.config.inlineTagPrefixes;
  var p = InlineTagsProcessor(tagPrefixes: tagPrefixes);
  return p.extractTags(note.body);
}
