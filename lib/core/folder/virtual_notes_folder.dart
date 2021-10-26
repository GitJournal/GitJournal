/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import '../note.dart';
import 'notes_folder.dart';
import 'notes_folder_notifier.dart';

class VirtualNotesFolder with NotesFolderNotifier implements NotesFolder {
  final List<Note> _notes;
  final NotesFolderConfig _config;

  VirtualNotesFolder(this._notes, this._config);

  @override
  List<Note> get notes => _notes;

  @override
  List<NotesFolder> get subFolders => [];

  @override
  bool get isEmpty => _notes.isEmpty;

  @override
  bool get hasNotes => _notes.isNotEmpty;

  @override
  NotesFolder? get parent => null;

  @override
  String get name => "";

  @override
  String get publicName => "";

  @override
  NotesFolder? get fsFolder {
    return null;
  }

  @override
  NotesFolderConfig get config => _config;
}
