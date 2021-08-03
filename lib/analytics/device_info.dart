import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_info_plus_platform_interface/model/web_browser_info.dart';
import 'package:universal_io/io.dart' show Platform;

import 'generated/analytics.pb.dart' as pb;

Future<pb.DeviceInfo> buildDeviceInfo() async {
  var infoPlugin = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    var androidInfo = await infoPlugin.androidInfo;

    var version = pb.AndroidBuildVersion(
      baseOS: androidInfo.version.baseOS,
      codename: androidInfo.version.codename,
      incremental: androidInfo.version.incremental,
      previewSdkInt: androidInfo.version.previewSdkInt,
      release: androidInfo.version.release,
      sdkInt: androidInfo.version.sdkInt,
      securityPatch: androidInfo.version.securityPatch,
    );
    var info = pb.AndroidDeviceInfo(
      version: version,
      board: androidInfo.board,
      bootloader: androidInfo.bootloader,
      brand: androidInfo.brand,
      device: androidInfo.device,
      display: androidInfo.display,
      fingerprint: androidInfo.fingerprint,
      hardware: androidInfo.hardware,
      host: androidInfo.host,
      id: androidInfo.id,
      manufacturer: androidInfo.manufacturer,
      model: androidInfo.model,
      product: androidInfo.product,
      supported32BitAbis: androidInfo.supported32BitAbis.whereType(),
      supported64BitAbis: androidInfo.supported64BitAbis.whereType(),
      supportedAbis: androidInfo.supportedAbis.whereType(),
      tags: androidInfo.tags,
      type: androidInfo.type,
      isPhysicalDevice: androidInfo.isPhysicalDevice,
      androidId: androidInfo.androidId,
      systemFeatures: androidInfo.systemFeatures.whereType(),
    );
    return pb.DeviceInfo(platform: _currentPlatform(), androidDeviceInfo: info);
  }

  if (Platform.isIOS) {
    var iosInfo = await infoPlugin.iosInfo;
    var utsName = pb.IosUtsname(
      sysname: iosInfo.utsname.sysname,
      nodename: iosInfo.utsname.nodename,
      release: iosInfo.utsname.release,
      version: iosInfo.utsname.version,
      machine: iosInfo.utsname.machine,
    );

    var info = pb.IosDeviceInfo(
      name: iosInfo.name,
      systemName: iosInfo.systemName,
      systemVersion: iosInfo.systemVersion,
      model: iosInfo.model,
      localizedModel: iosInfo.localizedModel,
      identifierForVendor: iosInfo.identifierForVendor,
      isPhysicalDevice: iosInfo.isPhysicalDevice,
      utsname: utsName,
    );
    return pb.DeviceInfo(platform: _currentPlatform(), iosDeviceInfo: info);
  }

  if (Platform.isLinux) {
    var linuxInfo = await infoPlugin.linuxInfo;
    var info = pb.LinuxDeviceInfo(
      name: linuxInfo.name,
      version: linuxInfo.version,
      id: linuxInfo.id,
      idLike: linuxInfo.idLike,
      versionCodename: linuxInfo.versionCodename,
      versionId: linuxInfo.version,
      prettyName: linuxInfo.prettyName,
      buildId: linuxInfo.buildId,
      variant: linuxInfo.variant,
      variantId: linuxInfo.variantId,
      machineId: linuxInfo.machineId,
    );

    return pb.DeviceInfo(platform: _currentPlatform(), linuxDeviceInfo: info);
  }

  if (Platform.isMacOS) {
    var macOsInfo = await infoPlugin.macOsInfo;
    var info = pb.MacOSDeviceInfo(
      computerName: macOsInfo.computerName,
      hostName: macOsInfo.hostName,
      arch: macOsInfo.arch,
      model: macOsInfo.model,
      kernelVersion: macOsInfo.kernelVersion,
      osRelease: macOsInfo.osRelease,
      activeCPUs: macOsInfo.activeCPUs,
      memorySize: macOsInfo.memorySize,
      cpuFrequency: macOsInfo.cpuFrequency,
    );

    return pb.DeviceInfo(platform: _currentPlatform(), macOSDeviceInfo: info);
  }

  if (Platform.isWindows) {
    var windowsInfo = await infoPlugin.windowsInfo;
    var info = pb.WindowsDeviceInfo(
      computerName: windowsInfo.computerName,
      numberOfCores: windowsInfo.numberOfCores,
      systemMemoryInMegabytes: windowsInfo.systemMemoryInMegabytes,
    );

    return pb.DeviceInfo(platform: _currentPlatform(), windowsDeviceInfo: info);
  }

  if (kIsWeb) {
    var webInfo = await infoPlugin.webBrowserInfo;

    late pb.BrowserName name;
    switch (webInfo.browserName) {
      case BrowserName.firefox:
        name = pb.BrowserName.firefox;
        break;
      case BrowserName.chrome:
        name = pb.BrowserName.firefox;
        break;
      case BrowserName.edge:
        name = pb.BrowserName.firefox;
        break;
      case BrowserName.safari:
        name = pb.BrowserName.firefox;
        break;
      case BrowserName.unknown:
        name = pb.BrowserName.unknown;
        break;
      case BrowserName.opera:
        name = pb.BrowserName.opera;
        break;
      case BrowserName.samsungInternet:
        name = pb.BrowserName.samsungInternet;
        break;
      case BrowserName.msie:
        name = pb.BrowserName.msie;
        break;
    }

    var info = pb.WebBrowserInfo(
      browserName: name,
      appCodeName: webInfo.appCodeName,
      appName: webInfo.appName,
      appVersion: webInfo.appVersion,
      deviceMemory: webInfo.deviceMemory,
      language: webInfo.language,
      languages: webInfo.languages?.map((e) => e.toString()),
      platform: webInfo.platform,
      product: webInfo.product,
      productSub: webInfo.productSub,
      userAgent: webInfo.userAgent,
      vendor: webInfo.vendor,
      vendorSub: webInfo.vendorSub,
      hardwareConcurrency: webInfo.hardwareConcurrency,
      maxTouchPoints: webInfo.maxTouchPoints,
    );

    return pb.DeviceInfo(platform: _currentPlatform(), webBrowserInfo: info);
  }

  throw Exception("Unknown Platform for Analytics");
}

pb.Platform _currentPlatform() {
  if (Platform.isAndroid) {
    return pb.Platform.android;
  }
  if (Platform.isIOS) {
    return pb.Platform.ios;
  }
  if (Platform.isMacOS) {
    return pb.Platform.macos;
  }
  if (Platform.isLinux) {
    return pb.Platform.linux;
  }
  if (Platform.isWindows) {
    return pb.Platform.windows;
  }
  if (kIsWeb) {
    return pb.Platform.web;
  }

  throw UnimplementedError('Invalid Analytics Platform');
}
