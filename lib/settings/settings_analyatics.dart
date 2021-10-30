/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/settings/app_config.dart';

class SettingsAnalytics extends StatelessWidget {
  static const routePath = '/settings/analytics';

  const SettingsAnalytics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appConfig = context.watch<AppConfig>();
    var list = ListView(
      children: [
        const Center(
          child: FaIcon(FontAwesomeIcons.chartArea, size: 64.0 * 2),
        ),
        const Divider(),
        const _AnalyticsSwitchListTile(),
        SwitchListTile(
          title: Text(tr(LocaleKeys.settings_crashReports)),
          value: appConfig.collectCrashReports,
          onChanged: (bool val) {
            appConfig.collectCrashReports = val;
            appConfig.save();

            logEvent(
              Event.CrashReportingLevelChanged,
              parameters: {"state": val.toString()},
            );
          },
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.settings_list_analytics_title.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: list,
    );
  }
}

class _AnalyticsSwitchListTile extends StatefulWidget {
  const _AnalyticsSwitchListTile({
    Key? key,
  }) : super(key: key);

  @override
  State<_AnalyticsSwitchListTile> createState() =>
      _AnalyticsSwitchListTileState();
}

class _AnalyticsSwitchListTileState extends State<_AnalyticsSwitchListTile> {
  @override
  Widget build(BuildContext context) {
    if (Analytics.instance == null) {
      return const SizedBox();
    }
    var analytics = Analytics.instance!;

    return SwitchListTile(
      title: Text(tr(LocaleKeys.settings_usageStats)),
      value: analytics.enabled,
      onChanged: (bool val) {
        analytics.enabled = val;
        setState(() {}); // Remove this once Analytics.instace is not used
      },
    );
  }
}
