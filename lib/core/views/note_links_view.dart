/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/link.dart';
import 'package:gitjournal/core/links_loader.dart';
import 'package:gitjournal/core/transformers/base.dart';
import 'notes_materialized_view.dart';

part 'note_links_view.g.dart';

// Only needed because Hive cannot store List<T> directly
@HiveType(typeId: 1)
class _LinksList {
  @HiveField(0)
  final List<Link> list;
  _LinksList(this.list);
}

class NoteLinksView extends NotesMaterializedView<_LinksList> {
  NoteLinksView({
    required String name,
    required NotesViewComputer<_LinksList> computeFn,
    required String repoPath,
  }) : super(name: name, computeFn: computeFn, repoPath: repoPath);

  Future<List<Link>> fetchLinks(Note note) async {
    var linksList = await fetch(note);
    return linksList.list;
  }
}

class NoteLinksProvider extends SingleChildStatelessWidget {
  final String repoPath;

  const NoteLinksProvider({
    Key? key,
    Widget? child,
    required this.repoPath,
  }) : super(key: key, child: child);

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Provider(
      create: (_) {
        return NoteLinksView(
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

Future<_LinksList> _compute(Note note) async {
  var list = await _linksLoader.parseLinks(
    body: note.body,
    filePath: note.filePath,
  );
  return _LinksList(list);
}
