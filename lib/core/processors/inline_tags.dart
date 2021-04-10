// @dart=2.9

/*
  (c) Copyright 2020 Vishesh Handa

  Licensed under the MIT license:

      http://www.opensource.org/licenses/mit-license.php

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
*/

import 'package:meta/meta.dart';

class InlineTagsProcessor {
  final Set<String> tagPrefixes;

  InlineTagsProcessor({@required this.tagPrefixes});

  Set<String> extractTags(String text) {
    var tags = <String>{};

    for (var prefix in tagPrefixes) {
      // FIXME: Do not hardcode this
      var p = prefix;
      if (p == '+') {
        p = '\\+';
      }

      var regexp = RegExp(r'(^|\s)' + p + r'([^\s]+)(\s|$)');
      var matches = regexp.allMatches(text);
      for (var match in matches) {
        var tag = match.group(2);

        if (tag.endsWith('.') || tag.endsWith('!') || tag.endsWith('?')) {
          tag = tag.substring(0, tag.length - 1);
        }

        var all = tag.split(prefix);
        for (var t in all) {
          t = t.trim();
          if (t.isNotEmpty) {
            tags.add(t);
          }
        }
      }
    }

    return tags;
  }
}
