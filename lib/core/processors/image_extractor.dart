/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:equatable/equatable.dart';

class NoteImage extends Equatable {
  final String url;
  final String alt;

  const NoteImage({required this.url, required this.alt});

  @override
  List<Object> get props => [url, alt];

  @override
  bool get stringify => true;
}

class ImageExtractor {
  static final _regexp = RegExp(r"!\[(.*)\]\((.*)\)");

  Set<NoteImage> extract(String body) {
    var images = <NoteImage>{};
    var matches = _regexp.allMatches(body);
    for (var match in matches) {
      var alt = match.group(1);
      var url = match.group(2);

      var _ = images.add(NoteImage(alt: alt ?? "", url: url ?? ""));
    }

    return images;
  }
}
