import 'package:flutter/material.dart';

import 'package:function_types/function_types.dart';

import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/utils/logger.dart';

class GitHostSetupButton extends StatelessWidget {
  final Func0<void> onPressed;
  final String text;
  final String? iconUrl;

  GitHostSetupButton({
    required this.text,
    required this.onPressed,
    this.iconUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (iconUrl == null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.button,
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                Theme.of(context).primaryColor),
          ),
          onPressed: _onPressedWithAnalytics,
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          label: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.button,
          ),
          icon: Image.asset(iconUrl!, width: 32, height: 32),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                Theme.of(context).primaryColor),
          ),
          onPressed: _onPressedWithAnalytics,
        ),
      );
    }
  }

  void _onPressedWithAnalytics() {
    Log.d("githostsetup_button_click " + text);
    logEvent(Event.GitHostSetupButtonClick, parameters: {
      'text': text,
      'icon_url': iconUrl == null ? "" : iconUrl!,
    });
    onPressed();
  }
}
