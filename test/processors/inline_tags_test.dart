import 'package:test/test.dart';

import 'package:gitjournal/core/processors/inline_tags.dart';

void main() {
  test('Should parse simple tags', () {
    var body = "#hello Hi\nthere how#are you #doing now? #dog";

    var p = InlineTagsProcessor();
    var tags = p.extractTags(body);

    expect(tags, {'hello', 'doing', 'dog'});
  });

  test('Ignore . at the end of a tag', () {
    var body = "Hi there #tag.";

    var p = InlineTagsProcessor();
    var tags = p.extractTags(body);

    expect(tags, {'tag'});
  });

  // #a#b should be counted as two tags
  // + should work as a prefix
  // @ should work as a prefix
  // test for tags with non-ascii words
}
