// SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

///
//  Generated code. Do not modify.
//  source: markdown.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use nodeDescriptor instead')
const Node$json = const {
  '1': 'Node',
  '2': const [
    const {
      '1': 'element',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.Element',
      '9': 0,
      '10': 'element'
    },
    const {'1': 'text', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'text'},
  ],
  '8': const [
    const {'1': 'value'},
  ],
};

/// Descriptor for `Node`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nodeDescriptor = $convert.base64Decode(
    'CgROb2RlEi8KB2VsZW1lbnQYASABKAsyEy5naXRqb3VybmFsLkVsZW1lbnRIAFIHZWxlbWVudBIUCgR0ZXh0GAIgASgJSABSBHRleHRCBwoFdmFsdWU=');
@$core.Deprecated('Use elementDescriptor instead')
const Element$json = const {
  '1': 'Element',
  '2': const [
    const {'1': 'tag', '3': 1, '4': 1, '5': 9, '10': 'tag'},
    const {
      '1': 'userProperties',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.gitjournal.Element.UserPropertiesEntry',
      '10': 'userProperties'
    },
    const {
      '1': 'children',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.gitjournal.Node',
      '10': 'children'
    },
  ],
  '3': const [Element_UserPropertiesEntry$json],
};

@$core.Deprecated('Use elementDescriptor instead')
const Element_UserPropertiesEntry$json = const {
  '1': 'UserPropertiesEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

/// Descriptor for `Element`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List elementDescriptor = $convert.base64Decode(
    'CgdFbGVtZW50EhAKA3RhZxgBIAEoCVIDdGFnEk8KDnVzZXJQcm9wZXJ0aWVzGAIgAygLMicuZ2l0am91cm5hbC5FbGVtZW50LlVzZXJQcm9wZXJ0aWVzRW50cnlSDnVzZXJQcm9wZXJ0aWVzEiwKCGNoaWxkcmVuGAMgAygLMhAuZ2l0am91cm5hbC5Ob2RlUghjaGlsZHJlbhpBChNVc2VyUHJvcGVydGllc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');
