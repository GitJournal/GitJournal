/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;

import '../note.dart';

typedef NotesViewComputer<T> = Future<T> Function(Note note);

class NotesMaterializedView<T> {
  Box? storageBox;
  final String name;

  final NotesViewComputer<T> computeFn;
  final String repoPath;

  NotesMaterializedView({
    required this.name,
    required this.computeFn,
    required this.repoPath,
  }) {
    var path = repoPath;
    if (!path.endsWith(p.separator)) {
      path += p.separator;
    }
  }

  // FIXME: The return value doesn't need to be optional
  // FIXME: Use a LazyBox instead and add a cache on top?
  // FIXME: Maybe removing all the old keys after each put is too expensive?

  Future<T> fetch(Note note) async {
    assert(note.filePath.startsWith(repoPath));

    var ts = note.fileLastModified.toUtc().millisecondsSinceEpoch ~/ 1000;
    var path = note.filePath.substring(repoPath.length);
    var keyPrefix = '${path}_';
    var key = keyPrefix + ts.toString();

    storageBox ??= await Hive.openBox<T>(name);
    var box = storageBox!;

    T? val = box.get(key, defaultValue: null);
    if (val == null) {
      val = await computeFn(note);
      box.put(key, val);

      // Remove old keys
      var keys = box.keys.where((k) => k.startsWith(keyPrefix) && k != key);
      box.deleteAll(keys);
    }

    return val!;
  }
}
