/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:device_info_plus_platform_interface/model/web_browser_info.dart';
import 'package:fixnum/fixnum.dart';
import 'package:universal_io/io.dart' show Platform;

import 'generated/analytics.pb.dart' as pb;

Future<pb.DeviceInfo> buildDeviceInfo() async {
  var infoPlugin = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    var androidInfo = await infoPlugin.androidInfo;

    /*
      {
        "id": "QKQ1.191014.012",
        "host": "rd-build-104",
        "tags": "release-keys",
        "type": "user",
        "board": "msm8998",
        "brand": "OnePlus",
        "model": "ONEPLUS A5000",
        "device": "OnePlus5",
        "display": "ONEPLUS A5000_23_201029",
        "product": "OnePlus5",
        "version": {
          "sdkInt": 29,
          "release": "10",
          "codename": "REL",
          "incremental": "2010292059",
          "securityPatch": "2020-09-01"
        },
        "hardware": "qcom",
        "androidId": "a8e022b01be3284f",
        "bootloader": "unknown",
        "fingerprint": "OnePlus/OnePlus5/OnePlus5:10/QKQ1.191014.012/2010292059:user/release-keys",
        "manufacturer": "OnePlus",
        "supportedAbis": [
          "arm64-v8a",
          "armeabi-v7a",
          "armeabi"
        ],
        "systemFeatures": [
          ...
        ],
        "isPhysicalDevice": true,
        "supported32BitAbis": [
          "armeabi-v7a",
          "armeabi"
        ],
        "supported64BitAbis": [
          "arm64-v8a"
        ]
      }
    */
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
      // fingerprint: androidInfo.fingerprint,
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
      // androidId: androidInfo.androidId,
      systemFeatures: androidInfo.systemFeatures.whereType(),
    );
    return pb.DeviceInfo(platform: _currentPlatform(), androidDeviceInfo: info);
  }

  /*
  Eg -
  {
    "name": "Vishesh’s iPhone",
    "model": "iPhone",
    "utsname": {
      "machine": "iPhone8,2",
      "release": "20.6.0",
      "sysname": "Darwin",
      "version": "Darwin Kernel Version 20.6.0: Mon Jun 21 21:23:35 PDT 2021; root:xnu-7195.140.42~10/RELEASE_ARM64_S8000",
      "nodename": "Visheshs-iPhone"
    },
    "systemName": "iOS",
    "systemVersion": "14.7.1",
    "localizedModel": "iPhone",
    "isPhysicalDevice": true,
    "identifierForVendor": "E309F4D8-7A1E-46FC-9971-61833862EFA7"
  }

  */
  // Not sending info which can be uniquely identifying

  if (Platform.isIOS) {
    var iosInfo = await infoPlugin.iosInfo;
    var utsName = pb.IosUtsname(
      sysname: iosInfo.utsname.sysname,
      // nodename: iosInfo.utsname.nodename,
      release: iosInfo.utsname.release,
      version: iosInfo.utsname.version,
      machine: iosInfo.utsname.machine,
    );

    var info = pb.IosDeviceInfo(
      // name: iosInfo.name,
      systemName: iosInfo.systemName,
      systemVersion: iosInfo.systemVersion,
      model: iosInfo.model,
      localizedModel: iosInfo.localizedModel,
      // identifierForVendor: iosInfo.identifierForVendor,
      isPhysicalDevice: iosInfo.isPhysicalDevice,
      utsname: utsName,
    );
    return pb.DeviceInfo(platform: _currentPlatform(), iosDeviceInfo: info);
  }

  /*
  {
    "id": "ubuntu",
    "name": "Ubuntu",
    "idLike": [
      "debian"
    ],
    "version": "20.04.3 LTS (Focal Fossa)",
    "machineId": "d7517d7136a9441cb3716f49d1c293f1",
    "versionId": "20.04.3 LTS (Focal Fossa)",
    "prettyName": "Ubuntu 20.04.3 LTS",
    "versionCodename": "focal"
  }
  */
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
      // machineId: linuxInfo.machineId,
    );

    return pb.DeviceInfo(platform: _currentPlatform(), linuxDeviceInfo: info);
  }

  /*
  {
    "arch": "x86_64",
    "model": "MacBookPro11,1",
    "hostName": "Darwin",
    "osRelease": "20.3.0",
    "activeCPUs": 4,
    "memorySize": 17179869184,
    "computerName": "Visheshs-MacBook-Pro.local",
    "kernelVersion": "Darwin Kernel Version 20.3.0: Thu Jan 21 00:07:06 PST 2021; root:xnu-7195.81.3~1/RELEASE_X86_64"
  }
  */
  if (Platform.isMacOS) {
    var macOsInfo = await infoPlugin.macOsInfo;
    var info = pb.MacOSDeviceInfo(
      // computerName: macOsInfo.computerName,
      hostName: macOsInfo.hostName,
      arch: macOsInfo.arch,
      model: macOsInfo.model,
      kernelVersion: macOsInfo.kernelVersion,
      osRelease: macOsInfo.osRelease,
      activeCPUs: macOsInfo.activeCPUs,
      memorySize: Int64(macOsInfo.memorySize),
      // cpuFrequency: Int64(macOsInfo.cpuFrequency),
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
      deviceMemory:
          webInfo.deviceMemory != null ? Int64(webInfo.deviceMemory!) : null,
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
