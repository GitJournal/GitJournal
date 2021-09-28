// SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

///
//  Generated code. Do not modify.
//  source: analytics.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use platformDescriptor instead')
const Platform$json = const {
  '1': 'Platform',
  '2': const [
    const {'1': 'android', '2': 0},
    const {'1': 'ios', '2': 1},
    const {'1': 'linux', '2': 2},
    const {'1': 'macos', '2': 3},
    const {'1': 'windows', '2': 4},
    const {'1': 'web', '2': 5},
  ],
};

/// Descriptor for `Platform`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List platformDescriptor = $convert.base64Decode(
    'CghQbGF0Zm9ybRILCgdhbmRyb2lkEAASBwoDaW9zEAESCQoFbGludXgQAhIJCgVtYWNvcxADEgsKB3dpbmRvd3MQBBIHCgN3ZWIQBQ==');
@$core.Deprecated('Use browserNameDescriptor instead')
const BrowserName$json = const {
  '1': 'BrowserName',
  '2': const [
    const {'1': 'unknown', '2': 0},
    const {'1': 'firefox', '2': 1},
    const {'1': 'samsungInternet', '2': 2},
    const {'1': 'opera', '2': 3},
    const {'1': 'msie', '2': 4},
    const {'1': 'edge', '2': 5},
    const {'1': 'chrome', '2': 6},
    const {'1': 'safari', '2': 7},
  ],
};

/// Descriptor for `BrowserName`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List browserNameDescriptor = $convert.base64Decode(
    'CgtCcm93c2VyTmFtZRILCgd1bmtub3duEAASCwoHZmlyZWZveBABEhMKD3NhbXN1bmdJbnRlcm5ldBACEgkKBW9wZXJhEAMSCAoEbXNpZRAEEggKBGVkZ2UQBRIKCgZjaHJvbWUQBhIKCgZzYWZhcmkQBw==');
@$core.Deprecated('Use analyticsReplyDescriptor instead')
const AnalyticsReply$json = const {
  '1': 'AnalyticsReply',
};

/// Descriptor for `AnalyticsReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List analyticsReplyDescriptor =
    $convert.base64Decode('Cg5BbmFseXRpY3NSZXBseQ==');
@$core.Deprecated('Use analyticsMessageDescriptor instead')
const AnalyticsMessage$json = const {
  '1': 'AnalyticsMessage',
  '2': const [
    const {'1': 'appId', '3': 1, '4': 1, '5': 9, '10': 'appId'},
    const {
      '1': 'events',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.gitjournal.Event',
      '10': 'events'
    },
    const {
      '1': 'deviceInfo',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.DeviceInfo',
      '10': 'deviceInfo'
    },
    const {
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
    'ChBBbmFseXRpY3NNZXNzYWdlEhQKBWFwcElkGAEgASgJUgVhcHBJZBIpCgZldmVudHMYAiADKAsyES5naXRqb3VybmFsLkV2ZW50UgZldmVudHMSNgoKZGV2aWNlSW5mbxgDIAEoCzIWLmdpdGpvdXJuYWwuRGV2aWNlSW5mb1IKZGV2aWNlSW5mbxI5CgtwYWNrYWdlSW5mbxgEIAEoCzIXLmdpdGpvdXJuYWwuUGFja2FnZUluZm9SC3BhY2thZ2VJbmZv');
@$core.Deprecated('Use eventDescriptor instead')
const Event$json = const {
  '1': 'Event',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'date', '3': 2, '4': 1, '5': 4, '10': 'date'},
    const {
      '1': 'params',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.gitjournal.Event.ParamsEntry',
      '10': 'params'
    },
    const {'1': 'userId', '3': 4, '4': 1, '5': 9, '10': 'userId'},
    const {'1': 'pseudoId', '3': 5, '4': 1, '5': 9, '10': 'pseudoId'},
    const {
      '1': 'userProperties',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.gitjournal.Event.UserPropertiesEntry',
      '10': 'userProperties'
    },
    const {'1': 'sessionID', '3': 7, '4': 1, '5': 13, '10': 'sessionID'},
  ],
  '3': const [Event_ParamsEntry$json, Event_UserPropertiesEntry$json],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_ParamsEntry$json = const {
  '1': 'ParamsEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_UserPropertiesEntry$json = const {
  '1': 'UserPropertiesEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

/// Descriptor for `Event`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List eventDescriptor = $convert.base64Decode(
    'CgVFdmVudBISCgRuYW1lGAEgASgJUgRuYW1lEhIKBGRhdGUYAiABKARSBGRhdGUSNQoGcGFyYW1zGAMgAygLMh0uZ2l0am91cm5hbC5FdmVudC5QYXJhbXNFbnRyeVIGcGFyYW1zEhYKBnVzZXJJZBgEIAEoCVIGdXNlcklkEhoKCHBzZXVkb0lkGAUgASgJUghwc2V1ZG9JZBJNCg51c2VyUHJvcGVydGllcxgGIAMoCzIlLmdpdGpvdXJuYWwuRXZlbnQuVXNlclByb3BlcnRpZXNFbnRyeVIOdXNlclByb3BlcnRpZXMSHAoJc2Vzc2lvbklEGAcgASgNUglzZXNzaW9uSUQaOQoLUGFyYW1zRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4ARpBChNVc2VyUHJvcGVydGllc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');
@$core.Deprecated('Use deviceInfoDescriptor instead')
const DeviceInfo$json = const {
  '1': 'DeviceInfo',
  '2': const [
    const {
      '1': 'platform',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.gitjournal.Platform',
      '10': 'platform'
    },
    const {
      '1': 'androidDeviceInfo',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.AndroidDeviceInfo',
      '9': 0,
      '10': 'androidDeviceInfo'
    },
    const {
      '1': 'iosDeviceInfo',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.IosDeviceInfo',
      '9': 0,
      '10': 'iosDeviceInfo'
    },
    const {
      '1': 'linuxDeviceInfo',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.LinuxDeviceInfo',
      '9': 0,
      '10': 'linuxDeviceInfo'
    },
    const {
      '1': 'macOSDeviceInfo',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.MacOSDeviceInfo',
      '9': 0,
      '10': 'macOSDeviceInfo'
    },
    const {
      '1': 'windowsDeviceInfo',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.WindowsDeviceInfo',
      '9': 0,
      '10': 'windowsDeviceInfo'
    },
    const {
      '1': 'webBrowserInfo',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.WebBrowserInfo',
      '9': 0,
      '10': 'webBrowserInfo'
    },
  ],
  '8': const [
    const {'1': 'deviceInfo'},
  ],
};

/// Descriptor for `DeviceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceInfoDescriptor = $convert.base64Decode(
    'CgpEZXZpY2VJbmZvEjAKCHBsYXRmb3JtGAEgASgOMhQuZ2l0am91cm5hbC5QbGF0Zm9ybVIIcGxhdGZvcm0STQoRYW5kcm9pZERldmljZUluZm8YCyABKAsyHS5naXRqb3VybmFsLkFuZHJvaWREZXZpY2VJbmZvSABSEWFuZHJvaWREZXZpY2VJbmZvEkEKDWlvc0RldmljZUluZm8YDCABKAsyGS5naXRqb3VybmFsLklvc0RldmljZUluZm9IAFINaW9zRGV2aWNlSW5mbxJHCg9saW51eERldmljZUluZm8YDSABKAsyGy5naXRqb3VybmFsLkxpbnV4RGV2aWNlSW5mb0gAUg9saW51eERldmljZUluZm8SRwoPbWFjT1NEZXZpY2VJbmZvGA4gASgLMhsuZ2l0am91cm5hbC5NYWNPU0RldmljZUluZm9IAFIPbWFjT1NEZXZpY2VJbmZvEk0KEXdpbmRvd3NEZXZpY2VJbmZvGA8gASgLMh0uZ2l0am91cm5hbC5XaW5kb3dzRGV2aWNlSW5mb0gAUhF3aW5kb3dzRGV2aWNlSW5mbxJECg53ZWJCcm93c2VySW5mbxgQIAEoCzIaLmdpdGpvdXJuYWwuV2ViQnJvd3NlckluZm9IAFIOd2ViQnJvd3NlckluZm9CDAoKZGV2aWNlSW5mbw==');
@$core.Deprecated('Use packageInfoDescriptor instead')
const PackageInfo$json = const {
  '1': 'PackageInfo',
  '2': const [
    const {'1': 'appName', '3': 1, '4': 1, '5': 9, '10': 'appName'},
    const {'1': 'packageName', '3': 2, '4': 1, '5': 9, '10': 'packageName'},
    const {'1': 'version', '3': 3, '4': 1, '5': 9, '10': 'version'},
    const {'1': 'buildNumber', '3': 4, '4': 1, '5': 9, '10': 'buildNumber'},
    const {
      '1': 'buildSignature',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'buildSignature'
    },
    const {'1': 'installSource', '3': 6, '4': 1, '5': 9, '10': 'installSource'},
  ],
};

/// Descriptor for `PackageInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List packageInfoDescriptor = $convert.base64Decode(
    'CgtQYWNrYWdlSW5mbxIYCgdhcHBOYW1lGAEgASgJUgdhcHBOYW1lEiAKC3BhY2thZ2VOYW1lGAIgASgJUgtwYWNrYWdlTmFtZRIYCgd2ZXJzaW9uGAMgASgJUgd2ZXJzaW9uEiAKC2J1aWxkTnVtYmVyGAQgASgJUgtidWlsZE51bWJlchImCg5idWlsZFNpZ25hdHVyZRgFIAEoCVIOYnVpbGRTaWduYXR1cmUSJAoNaW5zdGFsbFNvdXJjZRgGIAEoCVINaW5zdGFsbFNvdXJjZQ==');
@$core.Deprecated('Use androidBuildVersionDescriptor instead')
const AndroidBuildVersion$json = const {
  '1': 'AndroidBuildVersion',
  '2': const [
    const {'1': 'baseOS', '3': 1, '4': 1, '5': 9, '10': 'baseOS'},
    const {'1': 'codename', '3': 2, '4': 1, '5': 9, '10': 'codename'},
    const {'1': 'incremental', '3': 3, '4': 1, '5': 9, '10': 'incremental'},
    const {
      '1': 'previewSdkInt',
      '3': 4,
      '4': 1,
      '5': 13,
      '10': 'previewSdkInt'
    },
    const {'1': 'release', '3': 5, '4': 1, '5': 9, '10': 'release'},
    const {'1': 'sdkInt', '3': 6, '4': 1, '5': 13, '10': 'sdkInt'},
    const {'1': 'securityPatch', '3': 7, '4': 1, '5': 9, '10': 'securityPatch'},
  ],
};

/// Descriptor for `AndroidBuildVersion`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List androidBuildVersionDescriptor = $convert.base64Decode(
    'ChNBbmRyb2lkQnVpbGRWZXJzaW9uEhYKBmJhc2VPUxgBIAEoCVIGYmFzZU9TEhoKCGNvZGVuYW1lGAIgASgJUghjb2RlbmFtZRIgCgtpbmNyZW1lbnRhbBgDIAEoCVILaW5jcmVtZW50YWwSJAoNcHJldmlld1Nka0ludBgEIAEoDVINcHJldmlld1Nka0ludBIYCgdyZWxlYXNlGAUgASgJUgdyZWxlYXNlEhYKBnNka0ludBgGIAEoDVIGc2RrSW50EiQKDXNlY3VyaXR5UGF0Y2gYByABKAlSDXNlY3VyaXR5UGF0Y2g=');
@$core.Deprecated('Use androidDeviceInfoDescriptor instead')
const AndroidDeviceInfo$json = const {
  '1': 'AndroidDeviceInfo',
  '2': const [
    const {
      '1': 'version',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.AndroidBuildVersion',
      '10': 'version'
    },
    const {'1': 'board', '3': 2, '4': 1, '5': 9, '10': 'board'},
    const {'1': 'bootloader', '3': 3, '4': 1, '5': 9, '10': 'bootloader'},
    const {'1': 'brand', '3': 4, '4': 1, '5': 9, '10': 'brand'},
    const {'1': 'device', '3': 5, '4': 1, '5': 9, '10': 'device'},
    const {'1': 'display', '3': 6, '4': 1, '5': 9, '10': 'display'},
    const {'1': 'fingerprint', '3': 7, '4': 1, '5': 9, '10': 'fingerprint'},
    const {'1': 'hardware', '3': 8, '4': 1, '5': 9, '10': 'hardware'},
    const {'1': 'host', '3': 9, '4': 1, '5': 9, '10': 'host'},
    const {'1': 'id', '3': 10, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'manufacturer', '3': 11, '4': 1, '5': 9, '10': 'manufacturer'},
    const {'1': 'model', '3': 12, '4': 1, '5': 9, '10': 'model'},
    const {'1': 'product', '3': 13, '4': 1, '5': 9, '10': 'product'},
    const {
      '1': 'supported32BitAbis',
      '3': 14,
      '4': 3,
      '5': 9,
      '10': 'supported32BitAbis'
    },
    const {
      '1': 'supported64BitAbis',
      '3': 15,
      '4': 3,
      '5': 9,
      '10': 'supported64BitAbis'
    },
    const {
      '1': 'supportedAbis',
      '3': 16,
      '4': 3,
      '5': 9,
      '10': 'supportedAbis'
    },
    const {'1': 'tags', '3': 17, '4': 1, '5': 9, '10': 'tags'},
    const {'1': 'type', '3': 18, '4': 1, '5': 9, '10': 'type'},
    const {
      '1': 'isPhysicalDevice',
      '3': 19,
      '4': 1,
      '5': 8,
      '10': 'isPhysicalDevice'
    },
    const {'1': 'androidId', '3': 20, '4': 1, '5': 9, '10': 'androidId'},
    const {
      '1': 'systemFeatures',
      '3': 21,
      '4': 3,
      '5': 9,
      '10': 'systemFeatures'
    },
  ],
};

/// Descriptor for `AndroidDeviceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List androidDeviceInfoDescriptor = $convert.base64Decode(
    'ChFBbmRyb2lkRGV2aWNlSW5mbxI5Cgd2ZXJzaW9uGAEgASgLMh8uZ2l0am91cm5hbC5BbmRyb2lkQnVpbGRWZXJzaW9uUgd2ZXJzaW9uEhQKBWJvYXJkGAIgASgJUgVib2FyZBIeCgpib290bG9hZGVyGAMgASgJUgpib290bG9hZGVyEhQKBWJyYW5kGAQgASgJUgVicmFuZBIWCgZkZXZpY2UYBSABKAlSBmRldmljZRIYCgdkaXNwbGF5GAYgASgJUgdkaXNwbGF5EiAKC2ZpbmdlcnByaW50GAcgASgJUgtmaW5nZXJwcmludBIaCghoYXJkd2FyZRgIIAEoCVIIaGFyZHdhcmUSEgoEaG9zdBgJIAEoCVIEaG9zdBIOCgJpZBgKIAEoCVICaWQSIgoMbWFudWZhY3R1cmVyGAsgASgJUgxtYW51ZmFjdHVyZXISFAoFbW9kZWwYDCABKAlSBW1vZGVsEhgKB3Byb2R1Y3QYDSABKAlSB3Byb2R1Y3QSLgoSc3VwcG9ydGVkMzJCaXRBYmlzGA4gAygJUhJzdXBwb3J0ZWQzMkJpdEFiaXMSLgoSc3VwcG9ydGVkNjRCaXRBYmlzGA8gAygJUhJzdXBwb3J0ZWQ2NEJpdEFiaXMSJAoNc3VwcG9ydGVkQWJpcxgQIAMoCVINc3VwcG9ydGVkQWJpcxISCgR0YWdzGBEgASgJUgR0YWdzEhIKBHR5cGUYEiABKAlSBHR5cGUSKgoQaXNQaHlzaWNhbERldmljZRgTIAEoCFIQaXNQaHlzaWNhbERldmljZRIcCglhbmRyb2lkSWQYFCABKAlSCWFuZHJvaWRJZBImCg5zeXN0ZW1GZWF0dXJlcxgVIAMoCVIOc3lzdGVtRmVhdHVyZXM=');
@$core.Deprecated('Use iosUtsnameDescriptor instead')
const IosUtsname$json = const {
  '1': 'IosUtsname',
  '2': const [
    const {'1': 'sysname', '3': 1, '4': 1, '5': 9, '10': 'sysname'},
    const {'1': 'nodename', '3': 2, '4': 1, '5': 9, '10': 'nodename'},
    const {'1': 'release', '3': 3, '4': 1, '5': 9, '10': 'release'},
    const {'1': 'version', '3': 4, '4': 1, '5': 9, '10': 'version'},
    const {'1': 'machine', '3': 5, '4': 1, '5': 9, '10': 'machine'},
  ],
};

/// Descriptor for `IosUtsname`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List iosUtsnameDescriptor = $convert.base64Decode(
    'CgpJb3NVdHNuYW1lEhgKB3N5c25hbWUYASABKAlSB3N5c25hbWUSGgoIbm9kZW5hbWUYAiABKAlSCG5vZGVuYW1lEhgKB3JlbGVhc2UYAyABKAlSB3JlbGVhc2USGAoHdmVyc2lvbhgEIAEoCVIHdmVyc2lvbhIYCgdtYWNoaW5lGAUgASgJUgdtYWNoaW5l');
@$core.Deprecated('Use iosDeviceInfoDescriptor instead')
const IosDeviceInfo$json = const {
  '1': 'IosDeviceInfo',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'systemName', '3': 2, '4': 1, '5': 9, '10': 'systemName'},
    const {'1': 'systemVersion', '3': 3, '4': 1, '5': 9, '10': 'systemVersion'},
    const {'1': 'model', '3': 4, '4': 1, '5': 9, '10': 'model'},
    const {
      '1': 'localizedModel',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'localizedModel'
    },
    const {
      '1': 'identifierForVendor',
      '3': 6,
      '4': 1,
      '5': 9,
      '10': 'identifierForVendor'
    },
    const {
      '1': 'isPhysicalDevice',
      '3': 7,
      '4': 1,
      '5': 8,
      '10': 'isPhysicalDevice'
    },
    const {
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
    'Cg1Jb3NEZXZpY2VJbmZvEhIKBG5hbWUYASABKAlSBG5hbWUSHgoKc3lzdGVtTmFtZRgCIAEoCVIKc3lzdGVtTmFtZRIkCg1zeXN0ZW1WZXJzaW9uGAMgASgJUg1zeXN0ZW1WZXJzaW9uEhQKBW1vZGVsGAQgASgJUgVtb2RlbBImCg5sb2NhbGl6ZWRNb2RlbBgFIAEoCVIObG9jYWxpemVkTW9kZWwSMAoTaWRlbnRpZmllckZvclZlbmRvchgGIAEoCVITaWRlbnRpZmllckZvclZlbmRvchIqChBpc1BoeXNpY2FsRGV2aWNlGAcgASgIUhBpc1BoeXNpY2FsRGV2aWNlEjAKB3V0c25hbWUYCCABKAsyFi5naXRqb3VybmFsLklvc1V0c25hbWVSB3V0c25hbWU=');
@$core.Deprecated('Use linuxDeviceInfoDescriptor instead')
const LinuxDeviceInfo$json = const {
  '1': 'LinuxDeviceInfo',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'version', '3': 2, '4': 1, '5': 9, '10': 'version'},
    const {'1': 'id', '3': 3, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'idLike', '3': 4, '4': 3, '5': 9, '10': 'idLike'},
    const {
      '1': 'versionCodename',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'versionCodename'
    },
    const {'1': 'versionId', '3': 6, '4': 1, '5': 9, '10': 'versionId'},
    const {'1': 'prettyName', '3': 7, '4': 1, '5': 9, '10': 'prettyName'},
    const {'1': 'buildId', '3': 8, '4': 1, '5': 9, '10': 'buildId'},
    const {'1': 'variant', '3': 9, '4': 1, '5': 9, '10': 'variant'},
    const {'1': 'variantId', '3': 10, '4': 1, '5': 9, '10': 'variantId'},
    const {'1': 'machineId', '3': 11, '4': 1, '5': 9, '10': 'machineId'},
  ],
};

/// Descriptor for `LinuxDeviceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List linuxDeviceInfoDescriptor = $convert.base64Decode(
    'Cg9MaW51eERldmljZUluZm8SEgoEbmFtZRgBIAEoCVIEbmFtZRIYCgd2ZXJzaW9uGAIgASgJUgd2ZXJzaW9uEg4KAmlkGAMgASgJUgJpZBIWCgZpZExpa2UYBCADKAlSBmlkTGlrZRIoCg92ZXJzaW9uQ29kZW5hbWUYBSABKAlSD3ZlcnNpb25Db2RlbmFtZRIcCgl2ZXJzaW9uSWQYBiABKAlSCXZlcnNpb25JZBIeCgpwcmV0dHlOYW1lGAcgASgJUgpwcmV0dHlOYW1lEhgKB2J1aWxkSWQYCCABKAlSB2J1aWxkSWQSGAoHdmFyaWFudBgJIAEoCVIHdmFyaWFudBIcCgl2YXJpYW50SWQYCiABKAlSCXZhcmlhbnRJZBIcCgltYWNoaW5lSWQYCyABKAlSCW1hY2hpbmVJZA==');
@$core.Deprecated('Use macOSDeviceInfoDescriptor instead')
const MacOSDeviceInfo$json = const {
  '1': 'MacOSDeviceInfo',
  '2': const [
    const {'1': 'computerName', '3': 1, '4': 1, '5': 9, '10': 'computerName'},
    const {'1': 'hostName', '3': 2, '4': 1, '5': 9, '10': 'hostName'},
    const {'1': 'arch', '3': 3, '4': 1, '5': 9, '10': 'arch'},
    const {'1': 'model', '3': 4, '4': 1, '5': 9, '10': 'model'},
    const {'1': 'kernelVersion', '3': 5, '4': 1, '5': 9, '10': 'kernelVersion'},
    const {'1': 'osRelease', '3': 6, '4': 1, '5': 9, '10': 'osRelease'},
    const {'1': 'activeCPUs', '3': 7, '4': 1, '5': 13, '10': 'activeCPUs'},
    const {'1': 'memorySize', '3': 8, '4': 1, '5': 4, '10': 'memorySize'},
    const {'1': 'cpuFrequency', '3': 9, '4': 1, '5': 4, '10': 'cpuFrequency'},
  ],
};

/// Descriptor for `MacOSDeviceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List macOSDeviceInfoDescriptor = $convert.base64Decode(
    'Cg9NYWNPU0RldmljZUluZm8SIgoMY29tcHV0ZXJOYW1lGAEgASgJUgxjb21wdXRlck5hbWUSGgoIaG9zdE5hbWUYAiABKAlSCGhvc3ROYW1lEhIKBGFyY2gYAyABKAlSBGFyY2gSFAoFbW9kZWwYBCABKAlSBW1vZGVsEiQKDWtlcm5lbFZlcnNpb24YBSABKAlSDWtlcm5lbFZlcnNpb24SHAoJb3NSZWxlYXNlGAYgASgJUglvc1JlbGVhc2USHgoKYWN0aXZlQ1BVcxgHIAEoDVIKYWN0aXZlQ1BVcxIeCgptZW1vcnlTaXplGAggASgEUgptZW1vcnlTaXplEiIKDGNwdUZyZXF1ZW5jeRgJIAEoBFIMY3B1RnJlcXVlbmN5');
@$core.Deprecated('Use windowsDeviceInfoDescriptor instead')
const WindowsDeviceInfo$json = const {
  '1': 'WindowsDeviceInfo',
  '2': const [
    const {'1': 'computerName', '3': 1, '4': 1, '5': 9, '10': 'computerName'},
    const {
      '1': 'numberOfCores',
      '3': 2,
      '4': 1,
      '5': 13,
      '10': 'numberOfCores'
    },
    const {
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
    'ChFXaW5kb3dzRGV2aWNlSW5mbxIiCgxjb21wdXRlck5hbWUYASABKAlSDGNvbXB1dGVyTmFtZRIkCg1udW1iZXJPZkNvcmVzGAIgASgNUg1udW1iZXJPZkNvcmVzEjgKF3N5c3RlbU1lbW9yeUluTWVnYWJ5dGVzGAMgASgNUhdzeXN0ZW1NZW1vcnlJbk1lZ2FieXRlcw==');
@$core.Deprecated('Use webBrowserInfoDescriptor instead')
const WebBrowserInfo$json = const {
  '1': 'WebBrowserInfo',
  '2': const [
    const {
      '1': 'browserName',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.gitjournal.BrowserName',
      '10': 'browserName'
    },
    const {'1': 'appCodeName', '3': 2, '4': 1, '5': 9, '10': 'appCodeName'},
    const {'1': 'appName', '3': 3, '4': 1, '5': 9, '10': 'appName'},
    const {'1': 'appVersion', '3': 4, '4': 1, '5': 9, '10': 'appVersion'},
    const {'1': 'deviceMemory', '3': 5, '4': 1, '5': 4, '10': 'deviceMemory'},
    const {'1': 'language', '3': 6, '4': 1, '5': 9, '10': 'language'},
    const {'1': 'languages', '3': 7, '4': 3, '5': 9, '10': 'languages'},
    const {'1': 'platform', '3': 8, '4': 1, '5': 9, '10': 'platform'},
    const {'1': 'product', '3': 9, '4': 1, '5': 9, '10': 'product'},
    const {'1': 'productSub', '3': 10, '4': 1, '5': 9, '10': 'productSub'},
    const {'1': 'userAgent', '3': 11, '4': 1, '5': 9, '10': 'userAgent'},
    const {'1': 'vendor', '3': 12, '4': 1, '5': 9, '10': 'vendor'},
    const {'1': 'vendorSub', '3': 13, '4': 1, '5': 9, '10': 'vendorSub'},
    const {
      '1': 'hardwareConcurrency',
      '3': 14,
      '4': 1,
      '5': 13,
      '10': 'hardwareConcurrency'
    },
    const {
      '1': 'maxTouchPoints',
      '3': 15,
      '4': 1,
      '5': 13,
      '10': 'maxTouchPoints'
    },
  ],
};

/// Descriptor for `WebBrowserInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List webBrowserInfoDescriptor = $convert.base64Decode(
    'Cg5XZWJCcm93c2VySW5mbxI5Cgticm93c2VyTmFtZRgBIAEoDjIXLmdpdGpvdXJuYWwuQnJvd3Nlck5hbWVSC2Jyb3dzZXJOYW1lEiAKC2FwcENvZGVOYW1lGAIgASgJUgthcHBDb2RlTmFtZRIYCgdhcHBOYW1lGAMgASgJUgdhcHBOYW1lEh4KCmFwcFZlcnNpb24YBCABKAlSCmFwcFZlcnNpb24SIgoMZGV2aWNlTWVtb3J5GAUgASgEUgxkZXZpY2VNZW1vcnkSGgoIbGFuZ3VhZ2UYBiABKAlSCGxhbmd1YWdlEhwKCWxhbmd1YWdlcxgHIAMoCVIJbGFuZ3VhZ2VzEhoKCHBsYXRmb3JtGAggASgJUghwbGF0Zm9ybRIYCgdwcm9kdWN0GAkgASgJUgdwcm9kdWN0Eh4KCnByb2R1Y3RTdWIYCiABKAlSCnByb2R1Y3RTdWISHAoJdXNlckFnZW50GAsgASgJUgl1c2VyQWdlbnQSFgoGdmVuZG9yGAwgASgJUgZ2ZW5kb3ISHAoJdmVuZG9yU3ViGA0gASgJUgl2ZW5kb3JTdWISMAoTaGFyZHdhcmVDb25jdXJyZW5jeRgOIAEoDVITaGFyZHdhcmVDb25jdXJyZW5jeRImCg5tYXhUb3VjaFBvaW50cxgPIAEoDVIObWF4VG91Y2hQb2ludHM=');
