import 'package:flutter_emoji/flutter_emoji.dart';

import 'base.dart';

class EmojiTransformer implements NoteReadTransformer, NoteWriteTransformer {
  static final _emojiParser = EmojiParser();

  @override
  Future<Note> onRead(Note note) async {
    note.title = _emojiParser.emojify(note.title);
    note.body = _emojiParser.emojify(note.body);
    return note;
  }

  @override
  Future<Note> onWrite(Note note) async {
    note.body = _emojiParser.unemojify(note.body);
    note.title = _emojiParser.unemojify(note.title);
    return note;
  }
}
