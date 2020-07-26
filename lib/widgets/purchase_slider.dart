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

typedef PaymentSliderChanged = Function(PaymentInfo);

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
    return Slider(
      min: values.first.value,
      max: values.last.value + 0.50,
      value: selectedValue.value,
      onChanged: (double val) {
        int i = -1;
        for (i = 1; i < values.length; i++) {
          var prev = values[i - 1].value;
          var cur = values[i].value;

          if (prev < val && val <= cur) {
            i--;
            break;
          }
        }
        if (val == values.first.value) {
          i = 0;
        } else if (val >= values.last.value) {
          i = values.length - 1;
        }

        if (i != -1) {
          onChanged(values[i]);
        }
      },
      label: selectedValue.text,
      divisions: values.length,
    );
  }
}
