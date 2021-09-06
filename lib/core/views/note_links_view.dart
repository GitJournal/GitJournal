import 'package:flutter/material.dart';

import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/link.dart';
import 'package:gitjournal/core/links_loader.dart';
import 'package:gitjournal/core/transformers/base.dart';
import 'notes_materialized_view.dart';

typedef NoteLinksView = NotesMaterializedView<List<Link>>;

class NoteLinksProvider extends SingleChildStatelessWidget {
  final String repoPath;

  NoteLinksProvider({
    Key? key,
    Widget? child,
    required this.repoPath,
  }) : super(key: key, child: child);

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Provider(
      create: (_) {
        return NotesMaterializedView<List<Link>>(
          name: 'note_links',
          repoPath: repoPath,
          computeFn: _compute,
        );
      },
      child: child,
    );
  }

  static NoteLinksView of(BuildContext context) {
    return Provider.of<NoteLinksView>(context);
  }
}

final _linksLoader = LinksLoader();

Future<List<Link>> _compute(Note note) async {
  return await _linksLoader.parseLinks(
    body: note.body,
    filePath: note.filePath,
  );
}
