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

class NoteImageMatch extends Equatable {
  final String url;
  final String alt;
  final int sizePercent;
  final String? title;
  final int startOffset;
  final int endOffset;
  final String rawText;

  const NoteImageMatch({
    required this.url,
    required this.alt,
    required this.sizePercent,
    required this.title,
    required this.startOffset,
    required this.endOffset,
    required this.rawText,
  });

  @override
  List<Object> get props =>
      [url, alt, sizePercent, title ?? "", startOffset, endOffset, rawText];

  @override
  bool get stringify => true;
}

class ImageExtractor {
  static final _regexp = RegExp(r'!\[(.*?)\]\(([^)\s]+)(?:\s+"([^"]+)")?\)');

  List<NoteImageMatch> extractMatches(String body) {
    var images = <NoteImageMatch>[];
    var matches = _regexp.allMatches(body);
    for (var match in matches) {
      var alt = match.group(1) ?? "";
      var rawUrl = match.group(2) ?? "";
      var title = match.group(3);
      var uri = Uri.parse(rawUrl);
      var sizePercent =
          _parseSizePercent(title) ?? _parseSizePercent(uri.fragment);
      var imageUrl = rawUrl;
      if (_parseSizePercent(uri.fragment) != null) {
        imageUrl = rawUrl.substring(0, rawUrl.length - uri.fragment.length - 1);
      }

      images.add(NoteImageMatch(
        alt: alt,
        url: imageUrl,
        sizePercent: sizePercent ?? 100,
        title: title,
        startOffset: match.start,
        endOffset: match.end,
        rawText: match.group(0) ?? "",
      ));
    }

    return images;
  }

  Set<NoteImage> extract(String body) {
    var images = <NoteImage>{};
    for (var match in extractMatches(body)) {
      images.add(NoteImage(alt: match.alt, url: match.url));
    }

    return images;
  }

  String normalizeImageSizes(String body) {
    var normalized = body;
    var matches = extractMatches(body).reversed;
    for (var match in matches) {
      var start = match.startOffset;
      var end = match.endOffset;

      while (start > 0 &&
          (normalized[start - 1] == ' ' || normalized[start - 1] == '\t') &&
          normalized[start - 1] != '\n') {
        start -= 1;
      }
      while (end < normalized.length &&
          (normalized[end] == ' ' || normalized[end] == '\t') &&
          normalized[end] != '\n') {
        end += 1;
      }

      final prefix = _requiredParagraphBreakBefore(normalized, start);
      final suffix = _requiredParagraphBreakAfter(normalized, end);
      normalized = normalized.replaceRange(
        start,
        end,
        '$prefix${buildMarkup(match.alt, match.url, match.sizePercent)}$suffix',
      );
    }
    return normalized;
  }

  static String buildMarkup(String alt, String url, int sizePercent) {
    if (sizePercent == 100) {
      return '![$alt]($url)';
    }

    return '![$alt]($url "$sizePercent%")';
  }

  int? _parseSizePercent(String? fragment) {
    if (fragment == null || fragment.isEmpty) {
      return null;
    }

    var value = fragment.trim();
    if (value.endsWith('%')) {
      value = value.substring(0, value.length - 1);
    }

    var sizePercent = int.tryParse(value);
    switch (sizePercent) {
      case 25:
      case 50:
      case 75:
      case 100:
        return sizePercent;
    }

    return null;
  }
}

String _requiredParagraphBreakBefore(String text, int start) {
  if (start == 0) {
    return '';
  }

  var newlineCount = 0;
  for (var i = start - 1; i >= 0 && text[i] == '\n'; i--) {
    newlineCount += 1;
  }

  if (newlineCount >= 2) {
    return '';
  }
  if (newlineCount == 1) {
    return '\n';
  }
  return '\n\n';
}

String _requiredParagraphBreakAfter(String text, int end) {
  if (end >= text.length) {
    return '';
  }

  var newlineCount = 0;
  for (var i = end; i < text.length && text[i] == '\n'; i++) {
    newlineCount += 1;
  }

  if (newlineCount >= 2) {
    return '';
  }
  if (newlineCount == 1) {
    return '\n';
  }
  return '\n\n';
}
