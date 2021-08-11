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
  );
}
