import 'package:gitjournal/core/links_loader.dart';
import 'package:test/test.dart';

void main() {
  group('LinksLoader', () {
    var contents = """[[GitJournal]]

[GitJournal](./gitjournal.md)
[GitJournal](gitjournal.md)
[GitJournal](gitjournal)

[Google](https://google.com)

    """;

    test('Should load links', () async {
      var loader = LinksLoader();
      var links = await loader.parseLinks(contents, "/tmp/foo");

      expect(links[0].filePath, null);
      expect(links[0].term, "GitJournal");

      expect(links[1].filePath, "/tmp/foo/gitjournal.md");
      expect(links[1].term, "GitJournal");

      expect(links[2].filePath, "/tmp/foo/gitjournal.md");
      expect(links[2].term, "GitJournal");

      expect(links[3].filePath, "/tmp/foo/gitjournal");
      expect(links[3].term, "GitJournal");

      expect(links.length, 4);
    });
  });
}
