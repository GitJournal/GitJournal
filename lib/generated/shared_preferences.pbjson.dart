// SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

///
//  Generated code. Do not modify.
//  source: shared_preferences.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use emptyMessageDescriptor instead')
const EmptyMessage$json = const {
  '1': 'EmptyMessage',
};

/// Descriptor for `EmptyMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyMessageDescriptor =
    $convert.base64Decode('CgxFbXB0eU1lc3NhZ2U=');
@$core.Deprecated('Use stringMessageDescriptor instead')
const StringMessage$json = const {
  '1': 'StringMessage',
  '2': const [
    const {'1': 'value', '3': 1, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `StringMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stringMessageDescriptor = $convert
    .base64Decode('Cg1TdHJpbmdNZXNzYWdlEhQKBXZhbHVlGAEgASgJUgV2YWx1ZQ==');
@$core.Deprecated('Use boolMessageDescriptor instead')
const BoolMessage$json = const {
  '1': 'BoolMessage',
  '2': const [
    const {'1': 'value', '3': 1, '4': 1, '5': 8, '10': 'value'},
  ],
};

/// Descriptor for `BoolMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List boolMessageDescriptor =
    $convert.base64Decode('CgtCb29sTWVzc2FnZRIUCgV2YWx1ZRgBIAEoCFIFdmFsdWU=');
@$core.Deprecated('Use optionalBoolDescriptor instead')
const OptionalBool$json = const {
  '1': 'OptionalBool',
  '2': const [
    const {'1': 'value', '3': 1, '4': 1, '5': 8, '10': 'value'},
  ],
};

/// Descriptor for `OptionalBool`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List optionalBoolDescriptor =
    $convert.base64Decode('CgxPcHRpb25hbEJvb2wSFAoFdmFsdWUYASABKAhSBXZhbHVl');
@$core.Deprecated('Use optionalIntDescriptor instead')
const OptionalInt$json = const {
  '1': 'OptionalInt',
  '2': const [
    const {'1': 'value', '3': 1, '4': 1, '5': 3, '10': 'value'},
  ],
};

/// Descriptor for `OptionalInt`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List optionalIntDescriptor =
    $convert.base64Decode('CgtPcHRpb25hbEludBIUCgV2YWx1ZRgBIAEoA1IFdmFsdWU=');
@$core.Deprecated('Use optionalDoubleDescriptor instead')
const OptionalDouble$json = const {
  '1': 'OptionalDouble',
  '2': const [
    const {'1': 'value', '3': 1, '4': 1, '5': 1, '10': 'value'},
  ],
};

/// Descriptor for `OptionalDouble`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List optionalDoubleDescriptor = $convert
    .base64Decode('Cg5PcHRpb25hbERvdWJsZRIUCgV2YWx1ZRgBIAEoAVIFdmFsdWU=');
@$core.Deprecated('Use optionalStringDescriptor instead')
const OptionalString$json = const {
  '1': 'OptionalString',
  '2': const [
    const {'1': 'value', '3': 1, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `OptionalString`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List optionalStringDescriptor = $convert
    .base64Decode('Cg5PcHRpb25hbFN0cmluZxIUCgV2YWx1ZRgBIAEoCVIFdmFsdWU=');
@$core.Deprecated('Use stringListMessageDescriptor instead')
const StringListMessage$json = const {
  '1': 'StringListMessage',
  '2': const [
    const {'1': 'value', '3': 1, '4': 3, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `StringListMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stringListMessageDescriptor = $convert
    .base64Decode('ChFTdHJpbmdMaXN0TWVzc2FnZRIUCgV2YWx1ZRgBIAMoCVIFdmFsdWU=');
@$core.Deprecated('Use setBoolRequestDescriptor instead')
const SetBoolRequest$json = const {
  '1': 'SetBoolRequest',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 8, '10': 'value'},
  ],
};

/// Descriptor for `SetBoolRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setBoolRequestDescriptor = $convert.base64Decode(
    'Cg5TZXRCb29sUmVxdWVzdBIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCFIFdmFsdWU=');
@$core.Deprecated('Use setIntRequestDescriptor instead')
const SetIntRequest$json = const {
  '1': 'SetIntRequest',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 3, '10': 'value'},
  ],
};

/// Descriptor for `SetIntRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setIntRequestDescriptor = $convert.base64Decode(
    'Cg1TZXRJbnRSZXF1ZXN0EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgDUgV2YWx1ZQ==');
@$core.Deprecated('Use setDoubleRequestDescriptor instead')
const SetDoubleRequest$json = const {
  '1': 'SetDoubleRequest',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
  ],
};

/// Descriptor for `SetDoubleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setDoubleRequestDescriptor = $convert.base64Decode(
    'ChBTZXREb3VibGVSZXF1ZXN0EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgBUgV2YWx1ZQ==');
@$core.Deprecated('Use setStringRequestDescriptor instead')
const SetStringRequest$json = const {
  '1': 'SetStringRequest',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `SetStringRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setStringRequestDescriptor = $convert.base64Decode(
    'ChBTZXRTdHJpbmdSZXF1ZXN0EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZQ==');
@$core.Deprecated('Use setStringListRequestDescriptor instead')
const SetStringListRequest$json = const {
  '1': 'SetStringListRequest',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 3, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `SetStringListRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setStringListRequestDescriptor = $convert.base64Decode(
    'ChRTZXRTdHJpbmdMaXN0UmVxdWVzdBIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAMoCVIFdmFsdWU=');
