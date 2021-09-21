/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:test/test.dart';

import 'package:gitjournal/core/processors/image_extractor.dart';

void main() {
  test('Should parse simple tags', () {
    var body = """#hello Hi
![alt](../final.img)
![alt2](../final2.img)
""";

    var p = ImageExtractor();
    var images = p.extract(body);

    expect(images, {
      const NoteImage(alt: 'alt', url: '../final.img'),
      const NoteImage(alt: 'alt2', url: '../final2.img'),
    });
  });
}
