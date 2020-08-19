import 'dart:math';

import 'package:flutter/material.dart';

import 'package:equatable/equatable.dart';

class PaymentInfo extends Equatable {
  final double value;
  final String text;
  final String id;

  PaymentInfo({@required this.id, @required this.value, @required this.text});

  @override
  List<Object> get props => [value, text, id];
}

typedef PaymentSliderChanged = void Function(PaymentInfo);

class PurchaseSlider extends StatelessWidget {
  final List<PaymentInfo> values;
  final PaymentInfo selectedValue;
  final PaymentSliderChanged onChanged;

  PurchaseSlider({
    @required this.values,
    @required this.selectedValue,
    @required this.onChanged,
  }) {
    values.sort((a, b) => a.value.compareTo(b.value));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
    @required this.values,
    @required this.selectedValue,
    @required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
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
