//
//  Generated code. Do not modify.
//  source: core.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use noteFileFormatDescriptor instead')
const NoteFileFormat$json = {
  '1': 'NoteFileFormat',
  '2': [
    {'1': 'Markdown', '2': 0},
    {'1': 'OrgMode', '2': 1},
    {'1': 'Txt', '2': 2},
  ],
};

/// Descriptor for `NoteFileFormat`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List noteFileFormatDescriptor = $convert.base64Decode(
    'Cg5Ob3RlRmlsZUZvcm1hdBIMCghNYXJrZG93bhAAEgsKB09yZ01vZGUQARIHCgNUeHQQAg==');

@$core.Deprecated('Use noteTypeDescriptor instead')
const NoteType$json = {
  '1': 'NoteType',
  '2': [
    {'1': 'Unknown', '2': 0},
    {'1': 'Checklist', '2': 1},
    {'1': 'Journal', '2': 2},
    {'1': 'Org', '2': 3},
  ],
};

/// Descriptor for `NoteType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List noteTypeDescriptor = $convert.base64Decode(
    'CghOb3RlVHlwZRILCgdVbmtub3duEAASDQoJQ2hlY2tsaXN0EAESCwoHSm91cm5hbBACEgcKA0'
    '9yZxAD');

@$core.Deprecated('Use unixTimestampMagnitudeDescriptor instead')
const UnixTimestampMagnitude$json = {
  '1': 'UnixTimestampMagnitude',
  '2': [
    {'1': 'Seconds', '2': 0},
    {'1': 'Milliseconds', '2': 1},
  ],
};

/// Descriptor for `UnixTimestampMagnitude`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List unixTimestampMagnitudeDescriptor =
    $convert.base64Decode(
        'ChZVbml4VGltZXN0YW1wTWFnbml0dWRlEgsKB1NlY29uZHMQABIQCgxNaWxsaXNlY29uZHMQAQ'
        '==');

@$core.Deprecated('Use dateFormatDescriptor instead')
const DateFormat$json = {
  '1': 'DateFormat',
  '2': [
    {'1': 'Iso8601', '2': 0},
    {'1': 'UnixTimeStamp', '2': 1},
    {'1': 'None', '2': 2},
    {'1': 'YearMonthDay', '2': 3},
  ],
};

/// Descriptor for `DateFormat`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List dateFormatDescriptor = $convert.base64Decode(
    'CgpEYXRlRm9ybWF0EgsKB0lzbzg2MDEQABIRCg1Vbml4VGltZVN0YW1wEAESCAoETm9uZRACEh'
    'AKDFllYXJNb250aERheRAD');

@$core.Deprecated('Use fileDescriptor instead')
const File$json = {
  '1': 'File',
  '2': [
    {'1': 'repoPath', '3': 1, '4': 1, '5': 9, '10': 'repoPath'},
    {'1': 'hash', '3': 2, '4': 1, '5': 12, '10': 'hash'},
    {'1': 'filePath', '3': 3, '4': 1, '5': 9, '10': 'filePath'},
    {
      '1': 'modified',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.DateTimeAnyTz',
      '10': 'modified'
    },
    {
      '1': 'created',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.DateTimeAnyTz',
      '10': 'created'
    },
    {
      '1': 'fileLastModified',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.DateTimeAnyTz',
      '10': 'fileLastModified'
    },
  ],
};

/// Descriptor for `File`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileDescriptor = $convert.base64Decode(
    'CgRGaWxlEhoKCHJlcG9QYXRoGAEgASgJUghyZXBvUGF0aBISCgRoYXNoGAIgASgMUgRoYXNoEh'
    'oKCGZpbGVQYXRoGAMgASgJUghmaWxlUGF0aBI1Cghtb2RpZmllZBgEIAEoCzIZLmdpdGpvdXJu'
    'YWwuRGF0ZVRpbWVBbnlUelIIbW9kaWZpZWQSMwoHY3JlYXRlZBgFIAEoCzIZLmdpdGpvdXJuYW'
    'wuRGF0ZVRpbWVBbnlUelIHY3JlYXRlZBJFChBmaWxlTGFzdE1vZGlmaWVkGAYgASgLMhkuZ2l0'
    'am91cm5hbC5EYXRlVGltZUFueVR6UhBmaWxlTGFzdE1vZGlmaWVk');

@$core.Deprecated('Use noteDescriptor instead')
const Note$json = {
  '1': 'Note',
  '2': [
    {
      '1': 'file',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.File',
      '10': 'file'
    },
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {'1': 'body', '3': 3, '4': 1, '5': 9, '10': 'body'},
    {
      '1': 'type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.gitjournal.NoteType',
      '10': 'type'
    },
    {'1': 'tags', '3': 5, '4': 3, '5': 9, '10': 'tags'},
    {
      '1': 'extraProps',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.gitjournal.Note.ExtraPropsEntry',
      '10': 'extraProps'
    },
    {
      '1': 'fileFormat',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.gitjournal.NoteFileFormat',
      '10': 'fileFormat'
    },
    {'1': 'propsList', '3': 13, '4': 3, '5': 9, '10': 'propsList'},
    {
      '1': 'modified',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.DateTimeAnyTz',
      '10': 'modified'
    },
    {
      '1': 'created',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.DateTimeAnyTz',
      '10': 'created'
    },
    {
      '1': 'serializerSettings',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.NoteSerializationSettings',
      '10': 'serializerSettings'
    },
  ],
  '3': [Note_ExtraPropsEntry$json],
};

@$core.Deprecated('Use noteDescriptor instead')
const Note_ExtraPropsEntry$json = {
  '1': 'ExtraPropsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.Union',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `Note`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List noteDescriptor = $convert.base64Decode(
    'CgROb3RlEiQKBGZpbGUYASABKAsyEC5naXRqb3VybmFsLkZpbGVSBGZpbGUSFAoFdGl0bGUYAi'
    'ABKAlSBXRpdGxlEhIKBGJvZHkYAyABKAlSBGJvZHkSKAoEdHlwZRgEIAEoDjIULmdpdGpvdXJu'
    'YWwuTm90ZVR5cGVSBHR5cGUSEgoEdGFncxgFIAMoCVIEdGFncxJACgpleHRyYVByb3BzGAYgAy'
    'gLMiAuZ2l0am91cm5hbC5Ob3RlLkV4dHJhUHJvcHNFbnRyeVIKZXh0cmFQcm9wcxI6CgpmaWxl'
    'Rm9ybWF0GAcgASgOMhouZ2l0am91cm5hbC5Ob3RlRmlsZUZvcm1hdFIKZmlsZUZvcm1hdBIcCg'
    'lwcm9wc0xpc3QYDSADKAlSCXByb3BzTGlzdBI1Cghtb2RpZmllZBgKIAEoCzIZLmdpdGpvdXJu'
    'YWwuRGF0ZVRpbWVBbnlUelIIbW9kaWZpZWQSMwoHY3JlYXRlZBgLIAEoCzIZLmdpdGpvdXJuYW'
    'wuRGF0ZVRpbWVBbnlUelIHY3JlYXRlZBJVChJzZXJpYWxpemVyU2V0dGluZ3MYDCABKAsyJS5n'
    'aXRqb3VybmFsLk5vdGVTZXJpYWxpemF0aW9uU2V0dGluZ3NSEnNlcmlhbGl6ZXJTZXR0aW5ncx'
    'pQCg9FeHRyYVByb3BzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSJwoFdmFsdWUYAiABKAsyES5n'
    'aXRqb3VybmFsLlVuaW9uUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use noteListDescriptor instead')
const NoteList$json = {
  '1': 'NoteList',
  '2': [
    {
      '1': 'notes',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.gitjournal.Note',
      '10': 'notes'
    },
  ],
};

/// Descriptor for `NoteList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List noteListDescriptor = $convert.base64Decode(
    'CghOb3RlTGlzdBImCgVub3RlcxgBIAMoCzIQLmdpdGpvdXJuYWwuTm90ZVIFbm90ZXM=');

@$core.Deprecated('Use mdYamlDocDescriptor instead')
const MdYamlDoc$json = {
  '1': 'MdYamlDoc',
  '2': [
    {'1': 'body', '3': 1, '4': 1, '5': 9, '10': 'body'},
    {
      '1': 'map',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.gitjournal.MdYamlDoc.MapEntry',
      '10': 'map'
    },
  ],
  '3': [MdYamlDoc_MapEntry$json],
};

@$core.Deprecated('Use mdYamlDocDescriptor instead')
const MdYamlDoc_MapEntry$json = {
  '1': 'MapEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.Union',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `MdYamlDoc`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mdYamlDocDescriptor = $convert.base64Decode(
    'CglNZFlhbWxEb2MSEgoEYm9keRgBIAEoCVIEYm9keRIwCgNtYXAYAiADKAsyHi5naXRqb3Vybm'
    'FsLk1kWWFtbERvYy5NYXBFbnRyeVIDbWFwGkkKCE1hcEVudHJ5EhAKA2tleRgBIAEoCVIDa2V5'
    'EicKBXZhbHVlGAIgASgLMhEuZ2l0am91cm5hbC5VbmlvblIFdmFsdWU6AjgB');

@$core.Deprecated('Use unionDescriptor instead')
const Union$json = {
  '1': 'Union',
  '2': [
    {'1': 'booleanValue', '3': 1, '4': 1, '5': 8, '9': 0, '10': 'booleanValue'},
    {'1': 'stringValue', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'stringValue'},
    {
      '1': 'dateValue',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.DateTimeAnyTz',
      '9': 0,
      '10': 'dateValue'
    },
    {'1': 'intValue', '3': 4, '4': 1, '5': 3, '9': 0, '10': 'intValue'},
    {'1': 'isNull', '3': 7, '4': 1, '5': 8, '9': 0, '10': 'isNull'},
    {
      '1': 'listValue',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.gitjournal.Union',
      '10': 'listValue'
    },
    {
      '1': 'mapValue',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.gitjournal.Union.MapValueEntry',
      '10': 'mapValue'
    },
  ],
  '3': [Union_MapValueEntry$json],
  '8': [
    {'1': 'UnionOneof'},
  ],
};

@$core.Deprecated('Use unionDescriptor instead')
const Union_MapValueEntry$json = {
  '1': 'MapValueEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.Union',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `Union`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unionDescriptor = $convert.base64Decode(
    'CgVVbmlvbhIkCgxib29sZWFuVmFsdWUYASABKAhIAFIMYm9vbGVhblZhbHVlEiIKC3N0cmluZ1'
    'ZhbHVlGAIgASgJSABSC3N0cmluZ1ZhbHVlEjkKCWRhdGVWYWx1ZRgDIAEoCzIZLmdpdGpvdXJu'
    'YWwuRGF0ZVRpbWVBbnlUekgAUglkYXRlVmFsdWUSHAoIaW50VmFsdWUYBCABKANIAFIIaW50Vm'
    'FsdWUSGAoGaXNOdWxsGAcgASgISABSBmlzTnVsbBIvCglsaXN0VmFsdWUYBSADKAsyES5naXRq'
    'b3VybmFsLlVuaW9uUglsaXN0VmFsdWUSOwoIbWFwVmFsdWUYBiADKAsyHy5naXRqb3VybmFsLl'
    'VuaW9uLk1hcFZhbHVlRW50cnlSCG1hcFZhbHVlGk4KDU1hcFZhbHVlRW50cnkSEAoDa2V5GAEg'
    'ASgJUgNrZXkSJwoFdmFsdWUYAiABKAsyES5naXRqb3VybmFsLlVuaW9uUgV2YWx1ZToCOAFCDA'
    'oKVW5pb25PbmVvZg==');

@$core.Deprecated('Use dateTimeAnyTzDescriptor instead')
const DateTimeAnyTz$json = {
  '1': 'DateTimeAnyTz',
  '2': [
    {'1': 'timestamp', '3': 1, '4': 1, '5': 4, '10': 'timestamp'},
    {'1': 'offset', '3': 2, '4': 1, '5': 5, '10': 'offset'},
  ],
};

/// Descriptor for `DateTimeAnyTz`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dateTimeAnyTzDescriptor = $convert.base64Decode(
    'Cg1EYXRlVGltZUFueVR6EhwKCXRpbWVzdGFtcBgBIAEoBFIJdGltZXN0YW1wEhYKBm9mZnNldB'
    'gCIAEoBVIGb2Zmc2V0');

@$core.Deprecated('Use noteSerializationSettingsDescriptor instead')
const NoteSerializationSettings$json = {
  '1': 'NoteSerializationSettings',
  '2': [
    {'1': 'modifiedKey', '3': 1, '4': 1, '5': 9, '10': 'modifiedKey'},
    {'1': 'createdKey', '3': 2, '4': 1, '5': 9, '10': 'createdKey'},
    {'1': 'titleKey', '3': 3, '4': 1, '5': 9, '10': 'titleKey'},
    {'1': 'typeKey', '3': 4, '4': 1, '5': 9, '10': 'typeKey'},
    {'1': 'tagsKey', '3': 5, '4': 1, '5': 9, '10': 'tagsKey'},
    {'1': 'tagsInString', '3': 6, '4': 1, '5': 8, '10': 'tagsInString'},
    {'1': 'tagsHaveHash', '3': 7, '4': 1, '5': 8, '10': 'tagsHaveHash'},
    {'1': 'emojify', '3': 8, '4': 1, '5': 8, '10': 'emojify'},
    {
      '1': 'modifiedFormat',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.gitjournal.DateFormat',
      '10': 'modifiedFormat'
    },
    {
      '1': 'createdFormat',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.gitjournal.DateFormat',
      '10': 'createdFormat'
    },
    {'1': 'titleSettings', '3': 11, '4': 1, '5': 9, '10': 'titleSettings'},
    {
      '1': 'unixTimestampMagnitude',
      '3': 12,
      '4': 1,
      '5': 14,
      '6': '.gitjournal.UnixTimestampMagnitude',
      '10': 'unixTimestampMagnitude'
    },
  ],
};

/// Descriptor for `NoteSerializationSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List noteSerializationSettingsDescriptor = $convert.base64Decode(
    'ChlOb3RlU2VyaWFsaXphdGlvblNldHRpbmdzEiAKC21vZGlmaWVkS2V5GAEgASgJUgttb2RpZm'
    'llZEtleRIeCgpjcmVhdGVkS2V5GAIgASgJUgpjcmVhdGVkS2V5EhoKCHRpdGxlS2V5GAMgASgJ'
    'Ugh0aXRsZUtleRIYCgd0eXBlS2V5GAQgASgJUgd0eXBlS2V5EhgKB3RhZ3NLZXkYBSABKAlSB3'
    'RhZ3NLZXkSIgoMdGFnc0luU3RyaW5nGAYgASgIUgx0YWdzSW5TdHJpbmcSIgoMdGFnc0hhdmVI'
    'YXNoGAcgASgIUgx0YWdzSGF2ZUhhc2gSGAoHZW1vamlmeRgIIAEoCFIHZW1vamlmeRI+Cg5tb2'
    'RpZmllZEZvcm1hdBgJIAEoDjIWLmdpdGpvdXJuYWwuRGF0ZUZvcm1hdFIObW9kaWZpZWRGb3Jt'
    'YXQSPAoNY3JlYXRlZEZvcm1hdBgKIAEoDjIWLmdpdGpvdXJuYWwuRGF0ZUZvcm1hdFINY3JlYX'
    'RlZEZvcm1hdBIkCg10aXRsZVNldHRpbmdzGAsgASgJUg10aXRsZVNldHRpbmdzEloKFnVuaXhU'
    'aW1lc3RhbXBNYWduaXR1ZGUYDCABKA4yIi5naXRqb3VybmFsLlVuaXhUaW1lc3RhbXBNYWduaX'
    'R1ZGVSFnVuaXhUaW1lc3RhbXBNYWduaXR1ZGU=');
