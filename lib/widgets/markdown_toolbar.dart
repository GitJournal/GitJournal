import 'package:flutter/material.dart';

class MarkdownToolBar extends StatelessWidget {
  final Function onHeader1;
  final Function onItallics;
  final Function onBold;

  MarkdownToolBar({
    @required this.onHeader1,
    @required this.onItallics,
    @required this.onBold,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Text('H1'),
          onPressed: onHeader1,
        ),
        IconButton(
          icon: const Text('I'),
          onPressed: onItallics,
        ),
        IconButton(
          icon: const Text('B'),
          onPressed: onBold,
        ),
      ],
    );
  }
}
