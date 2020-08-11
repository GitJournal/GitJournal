import 'package:gitjournal/core/note.dart';

class InlineTagsProcessor {
  // FIXME: Make me configurable
  final List<String> tagPrefixes = ['#'];

  void process(Note note) {}

  Set<String> extractTags(String text) {
    var tags = <String>{};

    for (var prefix in tagPrefixes) {
      var regexp = RegExp(r'(^|\s)' + prefix + r'([^ ]+)(\s|$)');
      var matches = regexp.allMatches(text);
      for (var match in matches) {
        var tag = match.group(2);

        if (tag.endsWith('.') || tag.endsWith('!') || tag.endsWith('?')) {
          tag = tag.substring(0, tag.length - 1);
        }

        tags.add(tag);
      }
    }

    return tags;
  }
}
