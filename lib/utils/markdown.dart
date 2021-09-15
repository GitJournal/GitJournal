/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';
import 'dart:core';

String stripMarkdownFormatting(String markdown) {
  var output = StringBuffer();

  var lines = LineSplitter.split(markdown);
  for (var line in lines) {
    line = line.trim();
    if (line.startsWith('#')) {
      line = line.replaceAll('#', '');
    }
    if (line.isEmpty) {
      continue;
    }
    line = replaceMarkdownChars(line);

    output.write(line.trim());
    output.write(' ');
  }

  return output.toString().trimRight();
}

String replaceMarkdownChars(String line) {
  line = line.replaceFirst('- [ ]', '☐');
  line = line.replaceFirst('- [x]', '☑');
  line = line.replaceFirst('- [X]', '☑');

  line = replaceListChar(line, '* ');
  line = replaceListChar(line, '- ');
  line = replaceListChar(line, '+ ');

  return line;
}

String replaceListChar(String line, String char) {
  const String bullet = '• ';

  var starPos = line.indexOf(char);
  if (starPos == 0) {
    line = line.replaceFirst(char, bullet);
  } else if (starPos != -1) {
    var beforeStar = line.substring(0, starPos);
    if (beforeStar.trim().isEmpty) {
      line = line.replaceFirst(char, bullet, starPos);
    }
  }

  return line;
}
