// @dart=2.9

import 'dart:io';

import 'package:device_info/device_info.dart';

// - https://support.google.com/firebase/answer/7029846?hl=en
// - https://support.google.com/firebase/answer/6317485?hl=en

class Event {
  DateTime date;
  String name;
  Map<String, dynamic> params;

  String userId;
  String psuedoId;
  Map<String, dynamic> userProperties;

  // Unique session identifier (based on the timestamp of the session_start
  // event) associated with each event that occurs within a session
  String sessionID;

  String platform;
  DateTime userFirstTouchTimestamp;
}

class Device {
  String category; // mobile
  String mobileBrandName;
  String mobileModelName;
  String mobileOsHardwareModel;
  String operatingSystem;
  String operatingSystemVersion;
  String vendorId;
  String language;
  bool isLimitedAdTracking;
  int timeZoneOffsetSeconds;

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

// https://github.com/oschwald/geoip2-golang
// -> Host it on the server, client side makes no sense
// TODO:
// 1. Create a postgres table for the geo
// 2. Write a migrator from the old event to the new format (what lang? dart?)
// 3. Create a simple endpoint which converts the IP
//    into a location and gives that location an ID and returns it
//    (Saves it in the DB)
class Geo {
  String continent;
  String country;
  String region;
  String city;
  String subContinent;
  String metro;
}

class AppInfo {
  String id;
  String version;
  String firebaseAppId;
  String installSource;
}

//
// * Create a postgres table with all this data
//   -> Maybe use clickhouse instead?
// * Convert all of this to the json representation we want
// * Write a converter for the firebase data to this data format
// * Insert all of this data into our clickhouse

// * Create the dashboard - huge task
// For the dashboard - maybe you could hire someone?
// - Or I could just use Grafana
// - Either way - it doesn't make sense to invest time in it

// TODO -
// - Create gj versions of the other events
// - Store the events in a local db - use hive
// - Populate the other data
// - Post them to an endpoint which collects them
// -

// Convert the device into an ID (deterministically) -> some hash
// call an /registerDevice

// Optimization: Figure out a better way to serialize the info
//               start with json, and later move to protobufs
