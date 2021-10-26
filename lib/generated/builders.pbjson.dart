// SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

///
//  Generated code. Do not modify.
//  source: builders.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use blobCTimeBuilderDataDescriptor instead')
const BlobCTimeBuilderData$json = const {
  '1': 'BlobCTimeBuilderData',
  '2': const [
    const {'1': 'commitHashes', '3': 1, '4': 3, '5': 12, '10': 'commitHashes'},
    const {'1': 'treeHashes', '3': 2, '4': 3, '5': 12, '10': 'treeHashes'},
    const {
      '1': 'map',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.gitjournal.BlobCTimeBuilderData.MapEntry',
      '10': 'map'
    },
  ],
  '3': const [BlobCTimeBuilderData_MapEntry$json],
};

@$core.Deprecated('Use blobCTimeBuilderDataDescriptor instead')
const BlobCTimeBuilderData_MapEntry$json = const {
  '1': 'MapEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.TzDateTime',
      '10': 'value'
    },
  ],
  '7': const {'7': true},
};

/// Descriptor for `BlobCTimeBuilderData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blobCTimeBuilderDataDescriptor = $convert.base64Decode(
    'ChRCbG9iQ1RpbWVCdWlsZGVyRGF0YRIiCgxjb21taXRIYXNoZXMYASADKAxSDGNvbW1pdEhhc2hlcxIeCgp0cmVlSGFzaGVzGAIgAygMUgp0cmVlSGFzaGVzEjsKA21hcBgDIAMoCzIpLmdpdGpvdXJuYWwuQmxvYkNUaW1lQnVpbGRlckRhdGEuTWFwRW50cnlSA21hcBpOCghNYXBFbnRyeRIQCgNrZXkYASABKAlSA2tleRIsCgV2YWx1ZRgCIAEoCzIWLmdpdGpvdXJuYWwuVHpEYXRlVGltZVIFdmFsdWU6AjgB');
@$core.Deprecated('Use fileMTimeBuilderDataDescriptor instead')
const FileMTimeBuilderData$json = const {
  '1': 'FileMTimeBuilderData',
  '2': const [
    const {'1': 'commitHashes', '3': 1, '4': 3, '5': 12, '10': 'commitHashes'},
    const {'1': 'treeHashes', '3': 2, '4': 3, '5': 12, '10': 'treeHashes'},
    const {
      '1': 'map',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.gitjournal.FileMTimeBuilderData.MapEntry',
      '10': 'map'
    },
  ],
  '3': const [FileMTimeBuilderData_MapEntry$json],
};

@$core.Deprecated('Use fileMTimeBuilderDataDescriptor instead')
const FileMTimeBuilderData_MapEntry$json = const {
  '1': 'MapEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.FileMTimeInfo',
      '10': 'value'
    },
  ],
  '7': const {'7': true},
};

/// Descriptor for `FileMTimeBuilderData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileMTimeBuilderDataDescriptor = $convert.base64Decode(
    'ChRGaWxlTVRpbWVCdWlsZGVyRGF0YRIiCgxjb21taXRIYXNoZXMYASADKAxSDGNvbW1pdEhhc2hlcxIeCgp0cmVlSGFzaGVzGAIgAygMUgp0cmVlSGFzaGVzEjsKA21hcBgDIAMoCzIpLmdpdGpvdXJuYWwuRmlsZU1UaW1lQnVpbGRlckRhdGEuTWFwRW50cnlSA21hcBpRCghNYXBFbnRyeRIQCgNrZXkYASABKAlSA2tleRIvCgV2YWx1ZRgCIAEoCzIZLmdpdGpvdXJuYWwuRmlsZU1UaW1lSW5mb1IFdmFsdWU6AjgB');
@$core.Deprecated('Use tzDateTimeDescriptor instead')
const TzDateTime$json = const {
  '1': 'TzDateTime',
  '2': const [
    const {'1': 'timestamp', '3': 1, '4': 1, '5': 4, '10': 'timestamp'},
    const {'1': 'offset', '3': 2, '4': 1, '5': 5, '10': 'offset'},
  ],
};

/// Descriptor for `TzDateTime`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tzDateTimeDescriptor = $convert.base64Decode(
    'CgpUekRhdGVUaW1lEhwKCXRpbWVzdGFtcBgBIAEoBFIJdGltZXN0YW1wEhYKBm9mZnNldBgCIAEoBVIGb2Zmc2V0');
@$core.Deprecated('Use fileMTimeInfoDescriptor instead')
const FileMTimeInfo$json = const {
  '1': 'FileMTimeInfo',
  '2': const [
    const {'1': 'filePath', '3': 1, '4': 1, '5': 9, '10': 'filePath'},
    const {'1': 'hash', '3': 2, '4': 1, '5': 12, '10': 'hash'},
    const {
      '1': 'dt',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.TzDateTime',
      '10': 'dt'
    },
  ],
};

/// Descriptor for `FileMTimeInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileMTimeInfoDescriptor = $convert.base64Decode(
    'Cg1GaWxlTVRpbWVJbmZvEhoKCGZpbGVQYXRoGAEgASgJUghmaWxlUGF0aBISCgRoYXNoGAIgASgMUgRoYXNoEiYKAmR0GAMgASgLMhYuZ2l0am91cm5hbC5UekRhdGVUaW1lUgJkdA==');
