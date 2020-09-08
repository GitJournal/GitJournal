import 'package:flutter_emoji/flutter_emoji.dart';

import 'package:gitjournal/core/note.dart';

class EmojiProcessor {
  static final _emojiParser = EmojiParser();

  void onSave(Note note) {
    note.title = _emojiParser.emojify(note.title);
    note.body = _emojiParser.emojify(note.body);
  }

  void onLoad(Note note) {
    note.body = _emojiParser.unemojify(note.body);
    note.title = _emojiParser.unemojify(note.title);
  }
}
