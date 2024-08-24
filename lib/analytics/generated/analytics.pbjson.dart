//
//  Generated code. Do not modify.
//  source: analytics.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use platformDescriptor instead')
const Platform$json = {
  '1': 'Platform',
  '2': [
    {'1': 'android', '2': 0},
    {'1': 'ios', '2': 1},
    {'1': 'linux', '2': 2},
    {'1': 'macos', '2': 3},
    {'1': 'windows', '2': 4},
    {'1': 'web', '2': 5},
  ],
};

/// Descriptor for `Platform`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List platformDescriptor = $convert.base64Decode(
    'CghQbGF0Zm9ybRILCgdhbmRyb2lkEAASBwoDaW9zEAESCQoFbGludXgQAhIJCgVtYWNvcxADEg'
    'sKB3dpbmRvd3MQBBIHCgN3ZWIQBQ==');

@$core.Deprecated('Use browserNameDescriptor instead')
const BrowserName$json = {
  '1': 'BrowserName',
  '2': [
    {'1': 'unknown', '2': 0},
    {'1': 'firefox', '2': 1},
    {'1': 'samsungInternet', '2': 2},
    {'1': 'opera', '2': 3},
    {'1': 'msie', '2': 4},
    {'1': 'edge', '2': 5},
    {'1': 'chrome', '2': 6},
    {'1': 'safari', '2': 7},
  ],
};

/// Descriptor for `BrowserName`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List browserNameDescriptor = $convert.base64Decode(
    'CgtCcm93c2VyTmFtZRILCgd1bmtub3duEAASCwoHZmlyZWZveBABEhMKD3NhbXN1bmdJbnRlcm'
    '5ldBACEgkKBW9wZXJhEAMSCAoEbXNpZRAEEggKBGVkZ2UQBRIKCgZjaHJvbWUQBhIKCgZzYWZh'
    'cmkQBw==');

@$core.Deprecated('Use analyticsReplyDescriptor instead')
const AnalyticsReply$json = {
  '1': 'AnalyticsReply',
};

/// Descriptor for `AnalyticsReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List analyticsReplyDescriptor =
    $convert.base64Decode('Cg5BbmFseXRpY3NSZXBseQ==');

@$core.Deprecated('Use analyticsMessageDescriptor instead')
const AnalyticsMessage$json = {
  '1': 'AnalyticsMessage',
  '2': [
    {'1': 'appId', '3': 1, '4': 1, '5': 9, '10': 'appId'},
    {
      '1': 'events',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.gitjournal.Event',
      '10': 'events'
    },
    {
      '1': 'deviceInfo',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.DeviceInfo',
      '10': 'deviceInfo'
    },
    {
      '1': 'packageInfo',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.PackageInfo',
      '10': 'packageInfo'
    },
  ],
};

/// Descriptor for `AnalyticsMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List analyticsMessageDescriptor = $convert.base64Decode(
    'ChBBbmFseXRpY3NNZXNzYWdlEhQKBWFwcElkGAEgASgJUgVhcHBJZBIpCgZldmVudHMYAiADKA'
    'syES5naXRqb3VybmFsLkV2ZW50UgZldmVudHMSNgoKZGV2aWNlSW5mbxgDIAEoCzIWLmdpdGpv'
    'dXJuYWwuRGV2aWNlSW5mb1IKZGV2aWNlSW5mbxI5CgtwYWNrYWdlSW5mbxgEIAEoCzIXLmdpdG'
    'pvdXJuYWwuUGFja2FnZUluZm9SC3BhY2thZ2VJbmZv');

@$core.Deprecated('Use eventDescriptor instead')
const Event$json = {
  '1': 'Event',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'date', '3': 2, '4': 1, '5': 4, '10': 'date'},
    {
      '1': 'params',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.gitjournal.Event.ParamsEntry',
      '10': 'params'
    },
    {'1': 'userId', '3': 4, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'pseudoId', '3': 5, '4': 1, '5': 9, '10': 'pseudoId'},
    {
      '1': 'userProperties',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.gitjournal.Event.UserPropertiesEntry',
      '10': 'userProperties'
    },
    {'1': 'sessionID', '3': 7, '4': 1, '5': 13, '10': 'sessionID'},
  ],
  '3': [Event_ParamsEntry$json, Event_UserPropertiesEntry$json],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_ParamsEntry$json = {
  '1': 'ParamsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_UserPropertiesEntry$json = {
  '1': 'UserPropertiesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Event`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List eventDescriptor = $convert.base64Decode(
    'CgVFdmVudBISCgRuYW1lGAEgASgJUgRuYW1lEhIKBGRhdGUYAiABKARSBGRhdGUSNQoGcGFyYW'
    '1zGAMgAygLMh0uZ2l0am91cm5hbC5FdmVudC5QYXJhbXNFbnRyeVIGcGFyYW1zEhYKBnVzZXJJ'
    'ZBgEIAEoCVIGdXNlcklkEhoKCHBzZXVkb0lkGAUgASgJUghwc2V1ZG9JZBJNCg51c2VyUHJvcG'
    'VydGllcxgGIAMoCzIlLmdpdGpvdXJuYWwuRXZlbnQuVXNlclByb3BlcnRpZXNFbnRyeVIOdXNl'
    'clByb3BlcnRpZXMSHAoJc2Vzc2lvbklEGAcgASgNUglzZXNzaW9uSUQaOQoLUGFyYW1zRW50cn'
    'kSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4ARpBChNVc2VyUHJv'
    'cGVydGllc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOA'
    'E=');

@$core.Deprecated('Use deviceInfoDescriptor instead')
const DeviceInfo$json = {
  '1': 'DeviceInfo',
  '2': [
    {
      '1': 'platform',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.gitjournal.Platform',
      '10': 'platform'
    },
    {
      '1': 'androidDeviceInfo',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.AndroidDeviceInfo',
      '9': 0,
      '10': 'androidDeviceInfo'
    },
    {
      '1': 'iosDeviceInfo',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.IosDeviceInfo',
      '9': 0,
      '10': 'iosDeviceInfo'
    },
    {
      '1': 'linuxDeviceInfo',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.LinuxDeviceInfo',
      '9': 0,
      '10': 'linuxDeviceInfo'
    },
    {
      '1': 'macOSDeviceInfo',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.MacOSDeviceInfo',
      '9': 0,
      '10': 'macOSDeviceInfo'
    },
    {
      '1': 'windowsDeviceInfo',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.WindowsDeviceInfo',
      '9': 0,
      '10': 'windowsDeviceInfo'
    },
    {
      '1': 'webBrowserInfo',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.WebBrowserInfo',
      '9': 0,
      '10': 'webBrowserInfo'
    },
  ],
  '8': [
    {'1': 'deviceInfo'},
  ],
};

/// Descriptor for `DeviceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceInfoDescriptor = $convert.base64Decode(
    'CgpEZXZpY2VJbmZvEjAKCHBsYXRmb3JtGAEgASgOMhQuZ2l0am91cm5hbC5QbGF0Zm9ybVIIcG'
    'xhdGZvcm0STQoRYW5kcm9pZERldmljZUluZm8YCyABKAsyHS5naXRqb3VybmFsLkFuZHJvaWRE'
    'ZXZpY2VJbmZvSABSEWFuZHJvaWREZXZpY2VJbmZvEkEKDWlvc0RldmljZUluZm8YDCABKAsyGS'
    '5naXRqb3VybmFsLklvc0RldmljZUluZm9IAFINaW9zRGV2aWNlSW5mbxJHCg9saW51eERldmlj'
    'ZUluZm8YDSABKAsyGy5naXRqb3VybmFsLkxpbnV4RGV2aWNlSW5mb0gAUg9saW51eERldmljZU'
    'luZm8SRwoPbWFjT1NEZXZpY2VJbmZvGA4gASgLMhsuZ2l0am91cm5hbC5NYWNPU0RldmljZUlu'
    'Zm9IAFIPbWFjT1NEZXZpY2VJbmZvEk0KEXdpbmRvd3NEZXZpY2VJbmZvGA8gASgLMh0uZ2l0am'
    '91cm5hbC5XaW5kb3dzRGV2aWNlSW5mb0gAUhF3aW5kb3dzRGV2aWNlSW5mbxJECg53ZWJCcm93'
    'c2VySW5mbxgQIAEoCzIaLmdpdGpvdXJuYWwuV2ViQnJvd3NlckluZm9IAFIOd2ViQnJvd3Nlck'
    'luZm9CDAoKZGV2aWNlSW5mbw==');

@$core.Deprecated('Use packageInfoDescriptor instead')
const PackageInfo$json = {
  '1': 'PackageInfo',
  '2': [
    {'1': 'appName', '3': 1, '4': 1, '5': 9, '10': 'appName'},
    {'1': 'packageName', '3': 2, '4': 1, '5': 9, '10': 'packageName'},
    {'1': 'version', '3': 3, '4': 1, '5': 9, '10': 'version'},
    {'1': 'buildNumber', '3': 4, '4': 1, '5': 9, '10': 'buildNumber'},
    {'1': 'buildSignature', '3': 5, '4': 1, '5': 9, '10': 'buildSignature'},
    {'1': 'installSource', '3': 6, '4': 1, '5': 9, '10': 'installSource'},
  ],
};

/// Descriptor for `PackageInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packageInfoDescriptor = $convert.base64Decode(
    'CgtQYWNrYWdlSW5mbxIYCgdhcHBOYW1lGAEgASgJUgdhcHBOYW1lEiAKC3BhY2thZ2VOYW1lGA'
    'IgASgJUgtwYWNrYWdlTmFtZRIYCgd2ZXJzaW9uGAMgASgJUgd2ZXJzaW9uEiAKC2J1aWxkTnVt'
    'YmVyGAQgASgJUgtidWlsZE51bWJlchImCg5idWlsZFNpZ25hdHVyZRgFIAEoCVIOYnVpbGRTaW'
    'duYXR1cmUSJAoNaW5zdGFsbFNvdXJjZRgGIAEoCVINaW5zdGFsbFNvdXJjZQ==');

@$core.Deprecated('Use androidBuildVersionDescriptor instead')
const AndroidBuildVersion$json = {
  '1': 'AndroidBuildVersion',
  '2': [
    {'1': 'baseOS', '3': 1, '4': 1, '5': 9, '10': 'baseOS'},
    {'1': 'codename', '3': 2, '4': 1, '5': 9, '10': 'codename'},
    {'1': 'incremental', '3': 3, '4': 1, '5': 9, '10': 'incremental'},
    {'1': 'previewSdkInt', '3': 4, '4': 1, '5': 13, '10': 'previewSdkInt'},
    {'1': 'release', '3': 5, '4': 1, '5': 9, '10': 'release'},
    {'1': 'sdkInt', '3': 6, '4': 1, '5': 13, '10': 'sdkInt'},
    {'1': 'securityPatch', '3': 7, '4': 1, '5': 9, '10': 'securityPatch'},
  ],
};

/// Descriptor for `AndroidBuildVersion`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List androidBuildVersionDescriptor = $convert.base64Decode(
    'ChNBbmRyb2lkQnVpbGRWZXJzaW9uEhYKBmJhc2VPUxgBIAEoCVIGYmFzZU9TEhoKCGNvZGVuYW'
    '1lGAIgASgJUghjb2RlbmFtZRIgCgtpbmNyZW1lbnRhbBgDIAEoCVILaW5jcmVtZW50YWwSJAoN'
    'cHJldmlld1Nka0ludBgEIAEoDVINcHJldmlld1Nka0ludBIYCgdyZWxlYXNlGAUgASgJUgdyZW'
    'xlYXNlEhYKBnNka0ludBgGIAEoDVIGc2RrSW50EiQKDXNlY3VyaXR5UGF0Y2gYByABKAlSDXNl'
    'Y3VyaXR5UGF0Y2g=');

@$core.Deprecated('Use androidDeviceInfoDescriptor instead')
const AndroidDeviceInfo$json = {
  '1': 'AndroidDeviceInfo',
  '2': [
    {
      '1': 'version',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.AndroidBuildVersion',
      '10': 'version'
    },
    {'1': 'board', '3': 2, '4': 1, '5': 9, '10': 'board'},
    {'1': 'bootloader', '3': 3, '4': 1, '5': 9, '10': 'bootloader'},
    {'1': 'brand', '3': 4, '4': 1, '5': 9, '10': 'brand'},
    {'1': 'device', '3': 5, '4': 1, '5': 9, '10': 'device'},
    {'1': 'display', '3': 6, '4': 1, '5': 9, '10': 'display'},
    {'1': 'fingerprint', '3': 7, '4': 1, '5': 9, '10': 'fingerprint'},
    {'1': 'hardware', '3': 8, '4': 1, '5': 9, '10': 'hardware'},
    {'1': 'host', '3': 9, '4': 1, '5': 9, '10': 'host'},
    {'1': 'id', '3': 10, '4': 1, '5': 9, '10': 'id'},
    {'1': 'manufacturer', '3': 11, '4': 1, '5': 9, '10': 'manufacturer'},
    {'1': 'model', '3': 12, '4': 1, '5': 9, '10': 'model'},
    {'1': 'product', '3': 13, '4': 1, '5': 9, '10': 'product'},
    {
      '1': 'supported32BitAbis',
      '3': 14,
      '4': 3,
      '5': 9,
      '10': 'supported32BitAbis'
    },
    {
      '1': 'supported64BitAbis',
      '3': 15,
      '4': 3,
      '5': 9,
      '10': 'supported64BitAbis'
    },
    {'1': 'supportedAbis', '3': 16, '4': 3, '5': 9, '10': 'supportedAbis'},
    {'1': 'tags', '3': 17, '4': 1, '5': 9, '10': 'tags'},
    {'1': 'type', '3': 18, '4': 1, '5': 9, '10': 'type'},
    {
      '1': 'isPhysicalDevice',
      '3': 19,
      '4': 1,
      '5': 8,
      '10': 'isPhysicalDevice'
    },
    {'1': 'androidId', '3': 20, '4': 1, '5': 9, '10': 'androidId'},
    {'1': 'systemFeatures', '3': 21, '4': 3, '5': 9, '10': 'systemFeatures'},
  ],
};

/// Descriptor for `AndroidDeviceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List androidDeviceInfoDescriptor = $convert.base64Decode(
    'ChFBbmRyb2lkRGV2aWNlSW5mbxI5Cgd2ZXJzaW9uGAEgASgLMh8uZ2l0am91cm5hbC5BbmRyb2'
    'lkQnVpbGRWZXJzaW9uUgd2ZXJzaW9uEhQKBWJvYXJkGAIgASgJUgVib2FyZBIeCgpib290bG9h'
    'ZGVyGAMgASgJUgpib290bG9hZGVyEhQKBWJyYW5kGAQgASgJUgVicmFuZBIWCgZkZXZpY2UYBS'
    'ABKAlSBmRldmljZRIYCgdkaXNwbGF5GAYgASgJUgdkaXNwbGF5EiAKC2ZpbmdlcnByaW50GAcg'
    'ASgJUgtmaW5nZXJwcmludBIaCghoYXJkd2FyZRgIIAEoCVIIaGFyZHdhcmUSEgoEaG9zdBgJIA'
    'EoCVIEaG9zdBIOCgJpZBgKIAEoCVICaWQSIgoMbWFudWZhY3R1cmVyGAsgASgJUgxtYW51ZmFj'
    'dHVyZXISFAoFbW9kZWwYDCABKAlSBW1vZGVsEhgKB3Byb2R1Y3QYDSABKAlSB3Byb2R1Y3QSLg'
    'oSc3VwcG9ydGVkMzJCaXRBYmlzGA4gAygJUhJzdXBwb3J0ZWQzMkJpdEFiaXMSLgoSc3VwcG9y'
    'dGVkNjRCaXRBYmlzGA8gAygJUhJzdXBwb3J0ZWQ2NEJpdEFiaXMSJAoNc3VwcG9ydGVkQWJpcx'
    'gQIAMoCVINc3VwcG9ydGVkQWJpcxISCgR0YWdzGBEgASgJUgR0YWdzEhIKBHR5cGUYEiABKAlS'
    'BHR5cGUSKgoQaXNQaHlzaWNhbERldmljZRgTIAEoCFIQaXNQaHlzaWNhbERldmljZRIcCglhbm'
    'Ryb2lkSWQYFCABKAlSCWFuZHJvaWRJZBImCg5zeXN0ZW1GZWF0dXJlcxgVIAMoCVIOc3lzdGVt'
    'RmVhdHVyZXM=');

@$core.Deprecated('Use iosUtsnameDescriptor instead')
const IosUtsname$json = {
  '1': 'IosUtsname',
  '2': [
    {'1': 'sysname', '3': 1, '4': 1, '5': 9, '10': 'sysname'},
    {'1': 'nodename', '3': 2, '4': 1, '5': 9, '10': 'nodename'},
    {'1': 'release', '3': 3, '4': 1, '5': 9, '10': 'release'},
    {'1': 'version', '3': 4, '4': 1, '5': 9, '10': 'version'},
    {'1': 'machine', '3': 5, '4': 1, '5': 9, '10': 'machine'},
  ],
};

/// Descriptor for `IosUtsname`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List iosUtsnameDescriptor = $convert.base64Decode(
    'CgpJb3NVdHNuYW1lEhgKB3N5c25hbWUYASABKAlSB3N5c25hbWUSGgoIbm9kZW5hbWUYAiABKA'
    'lSCG5vZGVuYW1lEhgKB3JlbGVhc2UYAyABKAlSB3JlbGVhc2USGAoHdmVyc2lvbhgEIAEoCVIH'
    'dmVyc2lvbhIYCgdtYWNoaW5lGAUgASgJUgdtYWNoaW5l');

@$core.Deprecated('Use iosDeviceInfoDescriptor instead')
const IosDeviceInfo$json = {
  '1': 'IosDeviceInfo',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'systemName', '3': 2, '4': 1, '5': 9, '10': 'systemName'},
    {'1': 'systemVersion', '3': 3, '4': 1, '5': 9, '10': 'systemVersion'},
    {'1': 'model', '3': 4, '4': 1, '5': 9, '10': 'model'},
    {'1': 'localizedModel', '3': 5, '4': 1, '5': 9, '10': 'localizedModel'},
    {
      '1': 'identifierForVendor',
      '3': 6,
      '4': 1,
      '5': 9,
      '10': 'identifierForVendor'
    },
    {'1': 'isPhysicalDevice', '3': 7, '4': 1, '5': 8, '10': 'isPhysicalDevice'},
    {
      '1': 'utsname',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.IosUtsname',
      '10': 'utsname'
    },
  ],
};

/// Descriptor for `IosDeviceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List iosDeviceInfoDescriptor = $convert.base64Decode(
    'Cg1Jb3NEZXZpY2VJbmZvEhIKBG5hbWUYASABKAlSBG5hbWUSHgoKc3lzdGVtTmFtZRgCIAEoCV'
    'IKc3lzdGVtTmFtZRIkCg1zeXN0ZW1WZXJzaW9uGAMgASgJUg1zeXN0ZW1WZXJzaW9uEhQKBW1v'
    'ZGVsGAQgASgJUgVtb2RlbBImCg5sb2NhbGl6ZWRNb2RlbBgFIAEoCVIObG9jYWxpemVkTW9kZW'
    'wSMAoTaWRlbnRpZmllckZvclZlbmRvchgGIAEoCVITaWRlbnRpZmllckZvclZlbmRvchIqChBp'
    'c1BoeXNpY2FsRGV2aWNlGAcgASgIUhBpc1BoeXNpY2FsRGV2aWNlEjAKB3V0c25hbWUYCCABKA'
    'syFi5naXRqb3VybmFsLklvc1V0c25hbWVSB3V0c25hbWU=');

@$core.Deprecated('Use linuxDeviceInfoDescriptor instead')
const LinuxDeviceInfo$json = {
  '1': 'LinuxDeviceInfo',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'version', '3': 2, '4': 1, '5': 9, '10': 'version'},
    {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
    {'1': 'idLike', '3': 4, '4': 3, '5': 9, '10': 'idLike'},
    {'1': 'versionCodename', '3': 5, '4': 1, '5': 9, '10': 'versionCodename'},
    {'1': 'versionId', '3': 6, '4': 1, '5': 9, '10': 'versionId'},
    {'1': 'prettyName', '3': 7, '4': 1, '5': 9, '10': 'prettyName'},
    {'1': 'buildId', '3': 8, '4': 1, '5': 9, '10': 'buildId'},
    {'1': 'variant', '3': 9, '4': 1, '5': 9, '10': 'variant'},
    {'1': 'variantId', '3': 10, '4': 1, '5': 9, '10': 'variantId'},
    {'1': 'machineId', '3': 11, '4': 1, '5': 9, '10': 'machineId'},
  ],
};

/// Descriptor for `LinuxDeviceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List linuxDeviceInfoDescriptor = $convert.base64Decode(
    'Cg9MaW51eERldmljZUluZm8SEgoEbmFtZRgBIAEoCVIEbmFtZRIYCgd2ZXJzaW9uGAIgASgJUg'
    'd2ZXJzaW9uEg4KAmlkGAMgASgJUgJpZBIWCgZpZExpa2UYBCADKAlSBmlkTGlrZRIoCg92ZXJz'
    'aW9uQ29kZW5hbWUYBSABKAlSD3ZlcnNpb25Db2RlbmFtZRIcCgl2ZXJzaW9uSWQYBiABKAlSCX'
    'ZlcnNpb25JZBIeCgpwcmV0dHlOYW1lGAcgASgJUgpwcmV0dHlOYW1lEhgKB2J1aWxkSWQYCCAB'
    'KAlSB2J1aWxkSWQSGAoHdmFyaWFudBgJIAEoCVIHdmFyaWFudBIcCgl2YXJpYW50SWQYCiABKA'
    'lSCXZhcmlhbnRJZBIcCgltYWNoaW5lSWQYCyABKAlSCW1hY2hpbmVJZA==');

@$core.Deprecated('Use macOSDeviceInfoDescriptor instead')
const MacOSDeviceInfo$json = {
  '1': 'MacOSDeviceInfo',
  '2': [
    {'1': 'computerName', '3': 1, '4': 1, '5': 9, '10': 'computerName'},
    {'1': 'hostName', '3': 2, '4': 1, '5': 9, '10': 'hostName'},
    {'1': 'arch', '3': 3, '4': 1, '5': 9, '10': 'arch'},
    {'1': 'model', '3': 4, '4': 1, '5': 9, '10': 'model'},
    {'1': 'kernelVersion', '3': 5, '4': 1, '5': 9, '10': 'kernelVersion'},
    {'1': 'osRelease', '3': 6, '4': 1, '5': 9, '10': 'osRelease'},
    {'1': 'activeCPUs', '3': 7, '4': 1, '5': 13, '10': 'activeCPUs'},
    {'1': 'memorySize', '3': 8, '4': 1, '5': 4, '10': 'memorySize'},
    {'1': 'cpuFrequency', '3': 9, '4': 1, '5': 4, '10': 'cpuFrequency'},
  ],
};

/// Descriptor for `MacOSDeviceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List macOSDeviceInfoDescriptor = $convert.base64Decode(
    'Cg9NYWNPU0RldmljZUluZm8SIgoMY29tcHV0ZXJOYW1lGAEgASgJUgxjb21wdXRlck5hbWUSGg'
    'oIaG9zdE5hbWUYAiABKAlSCGhvc3ROYW1lEhIKBGFyY2gYAyABKAlSBGFyY2gSFAoFbW9kZWwY'
    'BCABKAlSBW1vZGVsEiQKDWtlcm5lbFZlcnNpb24YBSABKAlSDWtlcm5lbFZlcnNpb24SHAoJb3'
    'NSZWxlYXNlGAYgASgJUglvc1JlbGVhc2USHgoKYWN0aXZlQ1BVcxgHIAEoDVIKYWN0aXZlQ1BV'
    'cxIeCgptZW1vcnlTaXplGAggASgEUgptZW1vcnlTaXplEiIKDGNwdUZyZXF1ZW5jeRgJIAEoBF'
    'IMY3B1RnJlcXVlbmN5');

@$core.Deprecated('Use windowsDeviceInfoDescriptor instead')
const WindowsDeviceInfo$json = {
  '1': 'WindowsDeviceInfo',
  '2': [
    {'1': 'computerName', '3': 1, '4': 1, '5': 9, '10': 'computerName'},
    {'1': 'numberOfCores', '3': 2, '4': 1, '5': 13, '10': 'numberOfCores'},
    {
      '1': 'systemMemoryInMegabytes',
      '3': 3,
      '4': 1,
      '5': 13,
      '10': 'systemMemoryInMegabytes'
    },
  ],
};

/// Descriptor for `WindowsDeviceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List windowsDeviceInfoDescriptor = $convert.base64Decode(
    'ChFXaW5kb3dzRGV2aWNlSW5mbxIiCgxjb21wdXRlck5hbWUYASABKAlSDGNvbXB1dGVyTmFtZR'
    'IkCg1udW1iZXJPZkNvcmVzGAIgASgNUg1udW1iZXJPZkNvcmVzEjgKF3N5c3RlbU1lbW9yeUlu'
    'TWVnYWJ5dGVzGAMgASgNUhdzeXN0ZW1NZW1vcnlJbk1lZ2FieXRlcw==');

@$core.Deprecated('Use webBrowserInfoDescriptor instead')
const WebBrowserInfo$json = {
  '1': 'WebBrowserInfo',
  '2': [
    {
      '1': 'browserName',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.gitjournal.BrowserName',
      '10': 'browserName'
    },
    {'1': 'appCodeName', '3': 2, '4': 1, '5': 9, '10': 'appCodeName'},
    {'1': 'appName', '3': 3, '4': 1, '5': 9, '10': 'appName'},
    {'1': 'appVersion', '3': 4, '4': 1, '5': 9, '10': 'appVersion'},
    {'1': 'deviceMemory', '3': 5, '4': 1, '5': 4, '10': 'deviceMemory'},
    {'1': 'language', '3': 6, '4': 1, '5': 9, '10': 'language'},
    {'1': 'languages', '3': 7, '4': 3, '5': 9, '10': 'languages'},
    {'1': 'platform', '3': 8, '4': 1, '5': 9, '10': 'platform'},
    {'1': 'product', '3': 9, '4': 1, '5': 9, '10': 'product'},
    {'1': 'productSub', '3': 10, '4': 1, '5': 9, '10': 'productSub'},
    {'1': 'userAgent', '3': 11, '4': 1, '5': 9, '10': 'userAgent'},
    {'1': 'vendor', '3': 12, '4': 1, '5': 9, '10': 'vendor'},
    {'1': 'vendorSub', '3': 13, '4': 1, '5': 9, '10': 'vendorSub'},
    {
      '1': 'hardwareConcurrency',
      '3': 14,
      '4': 1,
      '5': 13,
      '10': 'hardwareConcurrency'
    },
    {'1': 'maxTouchPoints', '3': 15, '4': 1, '5': 13, '10': 'maxTouchPoints'},
  ],
};

/// Descriptor for `WebBrowserInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List webBrowserInfoDescriptor = $convert.base64Decode(
    'Cg5XZWJCcm93c2VySW5mbxI5Cgticm93c2VyTmFtZRgBIAEoDjIXLmdpdGpvdXJuYWwuQnJvd3'
    'Nlck5hbWVSC2Jyb3dzZXJOYW1lEiAKC2FwcENvZGVOYW1lGAIgASgJUgthcHBDb2RlTmFtZRIY'
    'CgdhcHBOYW1lGAMgASgJUgdhcHBOYW1lEh4KCmFwcFZlcnNpb24YBCABKAlSCmFwcFZlcnNpb2'
    '4SIgoMZGV2aWNlTWVtb3J5GAUgASgEUgxkZXZpY2VNZW1vcnkSGgoIbGFuZ3VhZ2UYBiABKAlS'
    'CGxhbmd1YWdlEhwKCWxhbmd1YWdlcxgHIAMoCVIJbGFuZ3VhZ2VzEhoKCHBsYXRmb3JtGAggAS'
    'gJUghwbGF0Zm9ybRIYCgdwcm9kdWN0GAkgASgJUgdwcm9kdWN0Eh4KCnByb2R1Y3RTdWIYCiAB'
    'KAlSCnByb2R1Y3RTdWISHAoJdXNlckFnZW50GAsgASgJUgl1c2VyQWdlbnQSFgoGdmVuZG9yGA'
    'wgASgJUgZ2ZW5kb3ISHAoJdmVuZG9yU3ViGA0gASgJUgl2ZW5kb3JTdWISMAoTaGFyZHdhcmVD'
    'b25jdXJyZW5jeRgOIAEoDVITaGFyZHdhcmVDb25jdXJyZW5jeRImCg5tYXhUb3VjaFBvaW50cx'
    'gPIAEoDVIObWF4VG91Y2hQb2ludHM=');
