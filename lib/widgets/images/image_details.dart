/*
Copyright 2020-2021 Roland Fredenhagen <important@van-fredenhagen.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import 'package:flutter/material.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/widgets/images/markdown_image.dart';
import 'package:gitjournal/widgets/images/themable_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class ImageDetails extends StatefulWidget {
  final ThemableImage image;
  final String caption;
  ImageDetails(this.image, this.caption);

  @override
  _ImageDetailsState createState() => _ImageDetailsState();
}

class _ImageDetailsState extends State<ImageDetails> {
  int rotation = 0;
  bool showUI = true;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = Provider.of<Settings>(context);
    final bg =
        theme.brightness == Brightness.dark ? Colors.black : Colors.white;
    final overlayColor = getOverlayBackgroundColor(context,
        light: Colors.white, dark: Colors.black);
    return Stack(
      children: [
        PhotoView.customChild(
          backgroundDecoration: BoxDecoration(color: bg),
          child: RotatedBox(
              quarterTurns: rotation,
              child: ThemableImage.from(widget.image, bg: bg)),
          minScale: 1.0,
          maxScale: settings.maxImageZoom,
          heroAttributes: PhotoViewHeroAttributes(tag: widget.image),
          onTapUp: (context, details, controllerValue) =>
              setState(() => showUI = !showUI),
          enableRotation: settings.rotateImageGestures,
        ),
        if (showUI)
          Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              height: 60,
              child: Material(
                  color: overlayColor,
                  child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                      child: Row(
                        children: [
                          IconButton(
                              splashRadius: 20,
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.pop(context)),
                          const Spacer(),
                          IconButton(
                              splashRadius: 20,
                              icon: const Icon(Icons.rotate_90_degrees_ccw),
                              onPressed: () => setState(() => rotation--))
                        ],
                      )))),
        // TODO use a DraggableScrollableSheet, when they can be dynamically
        // height restricted https://github.com/flutter/flutter/issues/41599
        if (showUI && widget.caption.isNotEmpty)
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Hero(
                  tag: "caption",
                  child: Container(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: SingleChildScrollView(
                          child: Text(
                        widget.caption,
                        style: theme.primaryTextTheme.bodyText1,
                      )),
                    ),
                    color: overlayColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  )))
      ],
    );
  }
}
