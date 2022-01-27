/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import 'package:gitjournal/core/markdown/md_yaml_doc.dart';
import 'package:gitjournal/core/markdown/md_yaml_doc_codec.dart';
import 'package:gitjournal/utils/datetime.dart';

DateTime nowWithoutMicro() {
  var dt = DateTime.now();
  return DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
}

void main() {
  group('Serializers', () {
    test('Markdown Serializer', () {
      var created = toIso8601WithTimezone(nowWithoutMicro());
      var doc = MdYamlDoc(
        body: "This is the body",
        props: ListMap.of({"created": created}),
      );

      var serializer = MarkdownYAMLCodec();
      var str = serializer.encode(doc);
      var doc2 = serializer.decode(str);

      expect(doc2, doc);
    });

    test('Markdown Serializer with invalid YAML', () {
      var inputNoteStr = """---
type
---

Alright.""";

      var serializer = MarkdownYAMLCodec();
      var doc = serializer.decode(inputNoteStr);
      var actualStr = "Alright.";

      expect(actualStr, doc.body);
    });

    test('Markdown Serializer with empty YAML', () {
      var inputNoteStr = """---
---

Alright.""";

      var serializer = MarkdownYAMLCodec();
      var doc = serializer.decode(inputNoteStr);
      var actualStr = "Alright.";

      expect(actualStr, doc.body);
    });

    test('Markdown Serializer with empty YAML and no \\n after body', () {
      var inputNoteStr = """---
---
Alright.""";

      var serializer = MarkdownYAMLCodec();
      var doc = serializer.decode(inputNoteStr);
      var actualStr = "Alright.";

      expect(actualStr, doc.body);
    });

    test('Markdown Serializer with empty YAML and doesn"t end with \\n', () {
      var inputNoteStr = """---
---""";

      var serializer = MarkdownYAMLCodec();
      var doc = serializer.decode(inputNoteStr);

      expect("", doc.body);
      expect(0, doc.props.length);
    });

    test('Markdown Serializer YAML Order', () {
      var str = """---
type: Journal
created: 2017-02-15T22:41:19+01:00
foo: bar
---

Alright.""";

      var serializer = MarkdownYAMLCodec();
      var doc = serializer.decode(str);
      var actualStr = serializer.encode(doc);

      expect(actualStr, str);
    });

    test('Markdown Serializer YAML Lists', () {
      var str = """---
foo: [bar, gar]
---

Alright.""";

      var serializer = MarkdownYAMLCodec();
      var doc = serializer.decode(str);
      var actualStr = serializer.encode(doc);

      expect(actualStr, str);
    });

    test('Note Starting with ---', () {
      var str = """---

Alright.""";

      var serializer = MarkdownYAMLCodec();
      var doc = serializer.decode(str);
      var actualStr = serializer.encode(doc);

      expect(actualStr, str);
    });

    test('Plain Markdown', () {
      var str = """Alright.""";

      var serializer = MarkdownYAMLCodec();
      var doc = serializer.decode(str);
      var actualStr = serializer.encode(doc);

      expect(actualStr, str);
    });

    test('Markdown with --- in body', () {
      var str = """---
foo: [bar, gar]
---

Alright. ---\n Good boy --- Howdy""";

      var serializer = MarkdownYAMLCodec();
      var doc = serializer.decode(str);
      var actualStr = serializer.encode(doc);

      expect(actualStr, str);
    });

    test('Markdown without \\n after yaml header', () {
      var str = """---
foo: [bar, gar]
---
Alright.""";

      var serializer = MarkdownYAMLCodec();
      var doc = serializer.decode(str);
      var actualStr = "Alright.";

      expect(actualStr, doc.body);
    });

    test('Only YAML Header without \\n at end', () {
      var str = """---
foo: bar
---""";

      var serializer = MarkdownYAMLCodec();
      var doc = serializer.decode(str);

      expect("", doc.body);
      expect({"foo": "bar"}, doc.props);

      var actualStr = serializer.encode(doc);
      expect(actualStr, str + '\n\n');
    });

    test('Only YAML Header with \\n at end', () {
      var str = """---
foo: bar
---
""";

      var serializer = MarkdownYAMLCodec();
      var doc = serializer.decode(str);

      expect("", doc.body);
      expect({"foo": "bar"}, doc.props);

      var actualStr = serializer.encode(doc);
      expect(actualStr, str + '\n');
    });

    test('Should not have any YamlMaps', () {
      // YamlMaps cannot be sent over an isolate

      var str = """---
thumbnail: {
  name: "adrian_sommeling.jpg",
  alt: "Padre e hijo se cubren con un paraguas de una tormenta que hace volar al niño",
  style: top
}
tags: ["opinión", "autores"]
---
""";

      var serializer = MarkdownYAMLCodec();
      var doc = serializer.decode(str);

      expect(doc.props['thumbnail'].runtimeType, isNot(YamlMap));
    });
  });
}
