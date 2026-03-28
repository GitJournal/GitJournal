/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:test/test.dart';

import 'package:gitjournal/core/processors/image_extractor.dart';
import '../lib.dart';

void main() {
  setUpAll(gjSetupAllTests);

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

  test('Should ignore image size fragment in extracted url', () {
    var body = '![alt](../final.img#50)';

    var p = ImageExtractor();
    var images = p.extract(body);
    var matches = p.extractMatches(body);

    expect(images, {
      const NoteImage(alt: 'alt', url: '../final.img'),
    });
    expect(matches.single.sizePercent, 50);
    expect(matches.single.rawText, '![alt](../final.img#50)');
  });

  test('Should parse title based image size markup', () {
    var body = '![alt](../final.img "75%")';

    var p = ImageExtractor();
    var images = p.extract(body);
    var matches = p.extractMatches(body);

    expect(images, {
      const NoteImage(alt: 'alt', url: '../final.img'),
    });
    expect(matches.single.sizePercent, 75);
    expect(matches.single.title, '75%');
  });

  test('Should normalize legacy image fragment markup', () {
    var body = '![alt](../final.img#50)';
    var p = ImageExtractor();

    expect(
      p.normalizeImageSizes(body),
      '![alt](../final.img "50%")',
    );
  });

  test('Should move inline image onto its own line when normalizing', () {
    var body = 'Hello ![alt](../final.img "50%") world';
    var p = ImageExtractor();

    expect(
      p.normalizeImageSizes(body),
      'Hello\n\n![alt](../final.img "50%")\n\nworld',
    );
  });
}
