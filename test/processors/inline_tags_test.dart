import 'package:test/test.dart';

import 'package:gitjournal/core/processors/inline_tags.dart';

void main() {
  test('Should parse simple tags', () {
    var body = "#hello Hi\nthere how#are you #doing now? #dog";

    var p = InlineTagsProcessor(tagPrefixes: {'#'});
    var tags = p.extractTags(body);

    expect(tags, {'hello', 'doing', 'dog'});
  });

  test('Ignore . at the end of a tag', () {
    var body = "Hi there #tag.";

    var p = InlineTagsProcessor(tagPrefixes: {'#'});
    var tags = p.extractTags(body);

    expect(tags, {'tag'});
  });

  test('#a#b should be counted as two tags', () {
    var body = "Hi there #a#b";

    var p = InlineTagsProcessor(tagPrefixes: {'#'});
    var tags = p.extractTags(body);

    expect(tags, {'a', 'b'});
  });

  test('Non Ascii tags', () {
    var body = "Hi #fíre gone";

    var p = InlineTagsProcessor(tagPrefixes: {'#'});
    var tags = p.extractTags(body);

    expect(tags, {'fíre'});
  });

  test('Tags with a -', () {
    var body = "Hi #future-me. How are you?";

    var p = InlineTagsProcessor(tagPrefixes: {'#'});
    var tags = p.extractTags(body);

    expect(tags, {'future-me'});
  });

  test('Multiple Prefixes', () {
    var body = "Hi +one+two @foo #doo";

    var p = InlineTagsProcessor(tagPrefixes: {'#', '+', '@'});
    var tags = p.extractTags(body);

    expect(tags, {'one', 'two', 'foo', 'doo'});
  });
}
