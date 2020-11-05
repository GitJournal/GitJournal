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
}

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
