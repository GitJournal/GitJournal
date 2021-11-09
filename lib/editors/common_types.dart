/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:gitjournal/core/note.dart';

enum EditorType { Markdown, Raw, Checklist, Journal, Org }

bool editorSupported(NoteFileFormat format, EditorType type) {
  switch (type) {
    case EditorType.Markdown:
      return format == NoteFileFormat.Markdown;

    case EditorType.Journal:
      return true;

    case EditorType.Checklist:
      return true;

    case EditorType.Raw:
      return true;

    case EditorType.Org:
      return format == NoteFileFormat.OrgMode;
  }
}

NoteFileFormat defaultFormat(EditorType type) {
  switch (type) {
    case EditorType.Markdown:
      return NoteFileFormat.Markdown;

    case EditorType.Journal:
      return NoteFileFormat.Markdown;

    case EditorType.Checklist:
      return NoteFileFormat.Markdown;

    case EditorType.Raw:
      return NoteFileFormat.Markdown;

    case EditorType.Org:
      return NoteFileFormat.OrgMode;
  }
}
