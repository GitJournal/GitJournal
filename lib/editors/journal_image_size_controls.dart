/*
 * SPDX-FileCopyrightText: 2026 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:gitjournal/core/processors/image_extractor.dart';

class JournalImageSizeControls extends StatelessWidget {
  static const sizeOptions = [25, 50, 75, 100];

  final TextEditingController textController;
  final VoidCallback onChanged;

  const JournalImageSizeControls({
    super.key,
    required this.textController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: textController,
      builder: (context, value, _) {
        final imageMatches = ImageExtractor().extractMatches(value.text);
        if (imageMatches.isEmpty) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final codeStyle = theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final imageMatch in imageMatches)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      imageMatch.rawText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: codeStyle,
                    ),
                    const SizedBox(height: 6.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        for (final size in sizeOptions)
                          ChoiceChip(
                            label: Text('$size%'),
                            selected: imageMatch.sizePercent == size,
                            onSelected: (_) =>
                                _updateImageSize(value, imageMatch, size),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  void _updateImageSize(
    TextEditingValue value,
    NoteImageMatch imageMatch,
    int sizePercent,
  ) {
    final replacement = ImageExtractor.buildMarkup(
      imageMatch.alt,
      imageMatch.url,
      sizePercent,
    );

    var selectionOffset = value.selection.baseOffset;
    if (selectionOffset == -1) {
      selectionOffset = imageMatch.startOffset;
    }

    final delta =
        replacement.length - (imageMatch.endOffset - imageMatch.startOffset);
    if (selectionOffset > imageMatch.endOffset) {
      selectionOffset += delta;
    } else if (selectionOffset >= imageMatch.startOffset) {
      selectionOffset = imageMatch.startOffset + replacement.length;
    }

    textController.value = value.copyWith(
      text: value.text.replaceRange(
        imageMatch.startOffset,
        imageMatch.endOffset,
        replacement,
      ),
      selection: TextSelection.collapsed(offset: selectionOffset),
      composing: TextRange.empty,
    );
    onChanged();
  }
}
