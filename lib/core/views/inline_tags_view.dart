/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/core/processors/inline_tags.dart';
import 'package:gitjournal/core/transformers/base.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'notes_materialized_view.dart';

typedef InlineTagsView = NotesMaterializedView<List<String>>;

class InlineTagsProvider extends SingleChildStatelessWidget {
  final String repoId;

  const InlineTagsProvider({super.key, super.child, required this.repoId});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Provider(
      create: (_) {
        return NotesMaterializedView<List<String>>(
          name: 'inline_tags',
          repoId: repoId,
          computeFn: _compute,
        );
      },
      child: child,
    );
  }

  static InlineTagsView of(BuildContext context, {bool listen = true}) {
    return Provider.of<InlineTagsView>(context, listen: listen);
  }
}

Future<List<String>> _compute(Note note) async {
  var tagPrefixes = note.parent.config.inlineTagPrefixes;
  var p = InlineTagsProcessor(tagPrefixes: tagPrefixes);
  return p.extractTags(note.body).toList();
}
