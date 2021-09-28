/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:package_info_plus/package_info_plus.dart';

import 'generated/analytics.pb.dart' as pb;

Future<pb.PackageInfo> buildPackageInfo() async {
  var info = await PackageInfo.fromPlatform();
  return pb.PackageInfo(
    appName: info.appName,
    packageName: info.packageName,
    version: info.version,
    buildNumber: info.buildNumber,
    buildSignature: info.buildSignature,
    installSource: const String.fromEnvironment('INSTALL_SOURCE'),
  );
}
