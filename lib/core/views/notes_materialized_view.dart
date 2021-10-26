/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:hive/hive.dart';
import 'package:mutex/mutex.dart';
import 'package:path/path.dart' as p;

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/logger/logger.dart';

typedef NotesViewComputer<T> = Future<T> Function(Note note);

class NotesMaterializedView<T> {
  Box? storageBox;
  final String name;

  final NotesViewComputer<T> computeFn;
  final String repoPath;

  final _readMutex = ReadWriteMutex();
  final _writeMutex = Mutex();

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
    assert(!note.filePath.startsWith(p.separator));
    assert(!note.filePath.endsWith(p.separator));

    var ts = note.fileLastModified.toUtc().millisecondsSinceEpoch ~/ 1000;
    var keyPrefix = '${note.filePath}_';
    var key = keyPrefix + ts.toString();

    // Open the Box
    await _readMutex.protectRead(() async {
      if (storageBox != null) return;

      await _writeMutex.protect(() async {
        if (storageBox != null) return;

        var startTime = DateTime.now();
        try {
          storageBox = await Hive.openBox<T>(name);
        } on HiveError catch (ex, st) {
          Log.e("HiveError $name", ex: ex, stacktrace: st);

          // Get the file Path
          await Hive.deleteBoxFromDisk(name);
          storageBox = await Hive.openBox<T>(name);
        }
        var endTime = DateTime.now().difference(startTime);

        Log.i("Loading View $name: $endTime");
      });
    });

    var box = storageBox!;

    T? val = box.get(key, defaultValue: null);
    if (val == null) {
      val = await computeFn(note);

      if (ts != 0) {
        box.put(key, val);

        // Remove old keys
        var keys = box.keys.where((k) => k.startsWith(keyPrefix) && k != key);
        box.deleteAll(keys);
      }
    }

    return val!;
  }
}
