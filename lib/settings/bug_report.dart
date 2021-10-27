/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/cupertino.dart';

import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:universal_io/io.dart';

import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/app_config.dart';
import 'package:gitjournal/utils/utils.dart';

Future<void> createBugReport(BuildContext context) async {
  var platform = Platform.operatingSystem;
  var versionText = await getVersionString();
  var isPro = AppConfig.instance.proMode;

  var body = "Hey!\n\nI found a bug in GitJournal - \n \n\n";
  body += "Version: $versionText\n";
  body += "Platform: $platform\n";
  body += "isPro: $isPro\n";

  var exp = AppConfig.instance.proExpirationDate;
  if (exp.isNotEmpty) {
    body += "expiryDate: $exp";
  }

  final Email email = Email(
    body: body,
    subject: 'GitJournal Bug',
    recipients: ['bugs@gitjournal.io'],
    attachmentPaths: Log.filePathsForDates(2),
  );

  try {
    await FlutterEmailSender.send(email);
  } catch (ex, st) {
    logException(ex, st);
    showSnackbar(context, ex.toString());
  }

  logEvent(Event.DrawerBugReport);
}

Future<void> createFeedback(BuildContext context) async {
  var platform = Platform.operatingSystem;
  var versionText = await getVersionString();
  var isPro = AppConfig.instance.proMode;

  var body = "Hey!\n\nHere are some ways to improve GitJournal - \n \n\n";
  body += "Version: $versionText\n";
  body += "Platform: $platform\n";
  body += "isPro: $isPro\n";

  var exp = AppConfig.instance.proExpirationDate;
  if (exp.isNotEmpty) {
    body += "expiryDate: $exp";
  }

  final Email email = Email(
    body: body,
    subject: 'GitJournal Feedback',
    recipients: ['feedback@gitjournal.io'],
  );

  try {
    await FlutterEmailSender.send(email);
  } catch (ex, st) {
    logException(ex, st);
    showSnackbar(context, ex.toString());
  }

  logEvent(Event.DrawerFeedback);
}
