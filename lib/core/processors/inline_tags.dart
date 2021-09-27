/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

class InlineTagsProcessor {
  final Set<String> tagPrefixes;

  InlineTagsProcessor({required this.tagPrefixes});

  Set<String> extractTags(String text) {
    var tags = <String>{};

    for (var prefix in tagPrefixes) {
      var p = RegExp.escape(prefix);
      var regexp = RegExp(r'(^|\s)' + p + r'([\S]+)');
      var matches = regexp.allMatches(text);
      for (var match in matches) {
        var tag = match.group(2)!;

        if (tag.endsWith('.') || tag.endsWith('!') || tag.endsWith('?')) {
          tag = tag.substring(0, tag.length - 1);
        }

        var all = tag.split(prefix);
        for (var t in all) {
          t = sanitize(t);
          if (t.isNotEmpty) {
            var _ = tags.add(t);
          }
        }
      }
    }

    return tags;
  }

  static String sanitize(String input) {
    input = input.trim();
    input = input.replaceAll(',', '');
    input = input.replaceAll('.', '');
    input = input.replaceAll(':', '');
    input = input.replaceAll(';', '');

    return input.trim();
  }
}
