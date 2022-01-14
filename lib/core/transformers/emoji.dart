/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter_emoji/flutter_emoji.dart';

import 'base.dart';

class EmojiTransformer implements NoteReadTransformer, NoteWriteTransformer {
  static final _emojiParser = EmojiParser();

  @override
  Future<Note> onRead(Note note) async {
    var title = note.title;

    note.apply(
      body: _emojiParser.emojify(note.body),
      title: title != null ? _emojiParser.emojify(title) : null,
    );
    return note;
  }

  @override
  Future<Note> onWrite(Note note) async {
    var title = note.title;

    note.apply(
      body: _emojiParser.unemojify(note.body),
      title: title != null ? _emojiParser.unemojify(title) : null,
    );
    return note;
  }
}
