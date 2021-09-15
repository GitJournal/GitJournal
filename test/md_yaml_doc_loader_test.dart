/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:dart_git/utils/result.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

import 'package:gitjournal/core/md_yaml_doc_loader.dart';

void main() {
  group('MdYamlDocLoader', () {
    late Directory tempDir;
    late String filePath;
    var contents = """---
type: Journal
foo: bar
---

Alright.""";

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('__doc_loader_test__');
      filePath = p.join(tempDir.path, "doc0");
      await File(filePath).writeAsString(contents);
    });

    tearDownAll(() async {
      tempDir.deleteSync(recursive: true);
    });

    test('Should load one doc', () async {
      var loader = MdYamlDocLoader();
      var doc = await loader.loadDoc(filePath).getOrThrow();

      expect(doc.body, "Alright.");
      expect(doc.props["type"], "Journal");
      expect(doc.props["foo"], "bar");
      expect(doc.props.length, 2);
    });
  });
}
