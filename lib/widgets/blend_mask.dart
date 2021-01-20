/*
 * This File is licensed under the MIT License:
 * 
 * https://github.com/gskinnerTeam/flutter_vignettes/
 * 
 * The MIT License (MIT)
 * 
 * Copyright (c) 2019 gskinner.com, inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy 
 * of this software and associated documentation files (the "Software"), to deal 
 * in the Software without restriction, including without limitation the rights 
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
 * copies of the Software, and to permit persons to whom the Software is 
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in 
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
 * SOFTWARE.
 */

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// Applies a BlendMode to its child.
class BlendMask extends SingleChildRenderObjectWidget {
  final BlendMode _blendMode;
  final double _opacity;

  BlendMask(
      {@required BlendMode blendMode,
      double opacity = 1.0,
      Key key,
      Widget child})
      : _blendMode = blendMode,
        _opacity = opacity,
        super(key: key, child: child);

  @override
  RenderObject createRenderObject(context) {
    return RenderBlendMask(_blendMode, _opacity);
  }

  @override
  void updateRenderObject(BuildContext context, RenderBlendMask renderObject) {
    renderObject._blendMode = _blendMode;
    renderObject._opacity = _opacity;
  }
}

class RenderBlendMask extends RenderProxyBox {
  BlendMode _blendMode;
  double _opacity;

  RenderBlendMask(BlendMode blendMode, double opacity)
      : _blendMode = blendMode,
        _opacity = opacity;

  @override
  void paint(context, offset) {
    // Create a new layer and specify the blend mode and opacity to composite it with:
    context.canvas.saveLayer(
        offset & size,
        Paint()
          ..blendMode = _blendMode
          ..color = Color.fromARGB((_opacity * 255).round(), 255, 255, 255));

    super.paint(context, offset);

    // Composite the layer back into the canvas using the blendmode:
    context.canvas.restore();
  }
}
