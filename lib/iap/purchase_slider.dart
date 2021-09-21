/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:math';

import 'package:flutter/material.dart';

import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PaymentInfo extends Equatable {
  final double value;
  final String text;
  final String id;

  const PaymentInfo(
      {required this.id, required this.value, required this.text});

  @override
  List<Object> get props => [value, text, id];

  static PaymentInfo fromProductDetail(ProductDetails pd) {
    double value = -1;
    if (pd.skProduct != null) {
      value = double.parse(pd.skProduct!.price);
    } else if (pd.skuDetail != null) {
      value = pd.skuDetail!.originalPriceAmountMicros.toDouble() / 100000;
    }

    return PaymentInfo(
      id: pd.id,
      text: pd.price,
      value: value,
    );
  }
}

typedef PaymentSliderChanged = void Function(PaymentInfo);

class PurchaseSlider extends StatelessWidget {
  final List<PaymentInfo> values;
  final PaymentInfo selectedValue;
  final PaymentSliderChanged onChanged;

  PurchaseSlider({
    required this.values,
    required this.selectedValue,
    required this.onChanged,
  }) {
    values.sort((a, b) => a.value.compareTo(b.value));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: CustomPaint(
        painter: ShapePainter(
          values: values,
          selectedValue: selectedValue,
          color: Theme.of(context).primaryColor,
        ),
        child: Container(),
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final List<PaymentInfo> values;
  final PaymentInfo selectedValue;
  final Color color;

  ShapePainter({
    required this.values,
    required this.selectedValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) {
      return;
    }

    var paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    var filledPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    var diff = (values.last.value - values.first.value);
    var w = (size.width / diff) * (selectedValue.value - values.first.value);

    var angle = atan(size.height / size.width);
    var h = w * tan(angle);

    var filledPath = Path();
    filledPath.moveTo(0, size.height);
    filledPath.lineTo(w, size.height);
    filledPath.lineTo(w, size.height - h);
    filledPath.lineTo(0, size.height);
    filledPath.close();

    canvas.drawPath(filledPath, filledPaint);

    var emptyPath = Path();
    emptyPath.moveTo(0, size.height);
    emptyPath.lineTo(size.width, size.height);
    emptyPath.lineTo(size.width, 0);
    emptyPath.lineTo(0, size.height);
    emptyPath.close();

    canvas.drawPath(emptyPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
