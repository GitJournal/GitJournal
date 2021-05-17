

import 'dart:io';

import 'package:device_info/device_info.dart';

// - https://support.google.com/firebase/answer/7029846?hl=en
// - https://support.google.com/firebase/answer/6317485?hl=en

class Event {
  DateTime? date;
  String? name;
  Map<String, dynamic>? params;

  String? userId;
  String? psuedoId;
  Map<String, dynamic>? userProperties;

  // Unique session identifier (based on the timestamp of the session_start
  // event) associated with each event that occurs within a session
  String? sessionID;

  String? platform;
  DateTime? userFirstTouchTimestamp;
}

class Device {
  String? category; // mobile
  String? mobileBrandName;
  String? mobileModelName;
  String? mobileOsHardwareModel;
  String? operatingSystem;
  String? operatingSystemVersion;
  String? vendorId;
  String? language;
  bool? isLimitedAdTracking;
  int? timeZoneOffsetSeconds;

  static Future<Device> build() async {
    var device = Device();
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      var d = await deviceInfo.androidInfo;
      device.category = "mobile";
      device.mobileBrandName = d.brand;
      device.mobileModelName = d.model;
      device.mobileOsHardwareModel = "";
      device.operatingSystem = "android";
      device.operatingSystemVersion = "";
      device.vendorId = "";
      device.language = "";
      device.isLimitedAdTracking = true;
    } else if (Platform.isIOS) {
      var d = await deviceInfo.iosInfo;
      device.category = "mobile";
      device.mobileBrandName = d.name;
      device.mobileModelName = d.model;
      device.mobileOsHardwareModel = "";
      device.operatingSystem = d.systemName;
      device.operatingSystemVersion = d.systemVersion;
      device.vendorId = d.identifierForVendor;
      device.language = "";
      device.isLimitedAdTracking = true;
    }

    device.timeZoneOffsetSeconds = DateTime.now().timeZoneOffset.inSeconds;
    return device;
  }
}

class AppInfo {
  String? id;
  String? version;
  String? firebaseAppId;
  String? installSource;
}

//
// * Write a converter for the firebase data to this data format
//
// Local tasks -
// - Create gj versions of the other events
// - Store the events in a local db - use hive
// - Populate the other data
//
