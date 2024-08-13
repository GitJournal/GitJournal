/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:function_types/function_types.dart';
import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/logger/logger.dart';

class GitHostSetupButton extends StatelessWidget {
  final Func0<void> onPressed;
  final String text;
  final String? iconUrl;
  final bool enabled;

  const GitHostSetupButton({
    required this.text,
    required this.onPressed,
    this.iconUrl,
    this.enabled = true,
    super.key,
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
            style: Theme.of(context).textTheme.labelLarge,
          ),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(
                enabled ? Theme.of(context).primaryColor : Colors.grey),
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
            style: Theme.of(context).textTheme.labelLarge,
          ),
          icon: Image.asset(iconUrl!, width: 32, height: 32),
          style: ButtonStyle(
            backgroundColor:
                WidgetStateProperty.all<Color>(Theme.of(context).primaryColor),
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
