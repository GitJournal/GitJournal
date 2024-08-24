//
//  Generated code. Do not modify.
//  source: builders.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use blobCTimeBuilderDataDescriptor instead')
const BlobCTimeBuilderData$json = {
  '1': 'BlobCTimeBuilderData',
  '2': [
    {'1': 'commitHashes', '3': 1, '4': 3, '5': 12, '10': 'commitHashes'},
    {'1': 'treeHashes', '3': 2, '4': 3, '5': 12, '10': 'treeHashes'},
    {
      '1': 'map',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.gitjournal.BlobCTimeBuilderData.MapEntry',
      '10': 'map'
    },
    {'1': 'headHash', '3': 4, '4': 1, '5': 12, '10': 'headHash'},
  ],
  '3': [BlobCTimeBuilderData_MapEntry$json],
};

@$core.Deprecated('Use blobCTimeBuilderDataDescriptor instead')
const BlobCTimeBuilderData_MapEntry$json = {
  '1': 'MapEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.TzDateTime',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `BlobCTimeBuilderData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blobCTimeBuilderDataDescriptor = $convert.base64Decode(
    'ChRCbG9iQ1RpbWVCdWlsZGVyRGF0YRIiCgxjb21taXRIYXNoZXMYASADKAxSDGNvbW1pdEhhc2'
    'hlcxIeCgp0cmVlSGFzaGVzGAIgAygMUgp0cmVlSGFzaGVzEjsKA21hcBgDIAMoCzIpLmdpdGpv'
    'dXJuYWwuQmxvYkNUaW1lQnVpbGRlckRhdGEuTWFwRW50cnlSA21hcBIaCghoZWFkSGFzaBgEIA'
    'EoDFIIaGVhZEhhc2gaTgoITWFwRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSLAoFdmFsdWUYAiAB'
    'KAsyFi5naXRqb3VybmFsLlR6RGF0ZVRpbWVSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use fileMTimeBuilderDataDescriptor instead')
const FileMTimeBuilderData$json = {
  '1': 'FileMTimeBuilderData',
  '2': [
    {'1': 'commitHashes', '3': 1, '4': 3, '5': 12, '10': 'commitHashes'},
    {
      '1': 'map',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.gitjournal.FileMTimeBuilderData.MapEntry',
      '10': 'map'
    },
    {'1': 'headHash', '3': 4, '4': 1, '5': 12, '10': 'headHash'},
  ],
  '3': [FileMTimeBuilderData_MapEntry$json],
};

@$core.Deprecated('Use fileMTimeBuilderDataDescriptor instead')
const FileMTimeBuilderData_MapEntry$json = {
  '1': 'MapEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.FileMTimeInfo',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `FileMTimeBuilderData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileMTimeBuilderDataDescriptor = $convert.base64Decode(
    'ChRGaWxlTVRpbWVCdWlsZGVyRGF0YRIiCgxjb21taXRIYXNoZXMYASADKAxSDGNvbW1pdEhhc2'
    'hlcxI7CgNtYXAYAyADKAsyKS5naXRqb3VybmFsLkZpbGVNVGltZUJ1aWxkZXJEYXRhLk1hcEVu'
    'dHJ5UgNtYXASGgoIaGVhZEhhc2gYBCABKAxSCGhlYWRIYXNoGlEKCE1hcEVudHJ5EhAKA2tleR'
    'gBIAEoCVIDa2V5Ei8KBXZhbHVlGAIgASgLMhkuZ2l0am91cm5hbC5GaWxlTVRpbWVJbmZvUgV2'
    'YWx1ZToCOAE=');

@$core.Deprecated('Use tzDateTimeDescriptor instead')
const TzDateTime$json = {
  '1': 'TzDateTime',
  '2': [
    {'1': 'timestamp', '3': 1, '4': 1, '5': 4, '10': 'timestamp'},
    {'1': 'offset', '3': 2, '4': 1, '5': 5, '10': 'offset'},
  ],
};

/// Descriptor for `TzDateTime`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tzDateTimeDescriptor = $convert.base64Decode(
    'CgpUekRhdGVUaW1lEhwKCXRpbWVzdGFtcBgBIAEoBFIJdGltZXN0YW1wEhYKBm9mZnNldBgCIA'
    'EoBVIGb2Zmc2V0');

@$core.Deprecated('Use fileMTimeInfoDescriptor instead')
const FileMTimeInfo$json = {
  '1': 'FileMTimeInfo',
  '2': [
    {'1': 'filePath', '3': 1, '4': 1, '5': 9, '10': 'filePath'},
    {'1': 'hash', '3': 2, '4': 1, '5': 12, '10': 'hash'},
    {
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
    'Cg1GaWxlTVRpbWVJbmZvEhoKCGZpbGVQYXRoGAEgASgJUghmaWxlUGF0aBISCgRoYXNoGAIgAS'
    'gMUgRoYXNoEiYKAmR0GAMgASgLMhYuZ2l0am91cm5hbC5UekRhdGVUaW1lUgJkdA==');
