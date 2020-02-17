import 'dart:convert';
import 'dart:core';

String stripMarkdownFormatting(String markdown) {
  var output = StringBuffer();
  var regExp = RegExp('[a-zA-Z0-9]');

  var lines = LineSplitter.split(markdown);
  for (var line in lines) {
    if (!line.contains(regExp)) {
      continue;
    }
    line = line.trim();
    if (line.startsWith('#')) {
      line = line.replaceAll('#', '');
    }
    if (line.isEmpty) {
      continue;
    }
    line = line.replaceFirst('[ ]', '☐');
    line = line.replaceFirst('[x]', '☑');
    line = line.replaceFirst('[X]', '☑');

    output.write(line.trim());
    output.write(' ');
  }

  return output.toString();
}
