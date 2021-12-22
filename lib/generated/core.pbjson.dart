// SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

///
//  Generated code. Do not modify.
//  source: core.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use noteFileFormatDescriptor instead')
const NoteFileFormat$json = const {
  '1': 'NoteFileFormat',
  '2': const [
    const {'1': 'Markdown', '2': 0},
    const {'1': 'OrgMode', '2': 1},
    const {'1': 'Txt', '2': 2},
  ],
};

/// Descriptor for `NoteFileFormat`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List noteFileFormatDescriptor = $convert.base64Decode(
    'Cg5Ob3RlRmlsZUZvcm1hdBIMCghNYXJrZG93bhAAEgsKB09yZ01vZGUQARIHCgNUeHQQAg==');
@$core.Deprecated('Use noteTypeDescriptor instead')
const NoteType$json = const {
  '1': 'NoteType',
  '2': const [
    const {'1': 'Unknown', '2': 0},
    const {'1': 'Checklist', '2': 1},
    const {'1': 'Journal', '2': 2},
    const {'1': 'Org', '2': 3},
  ],
};

/// Descriptor for `NoteType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List noteTypeDescriptor = $convert.base64Decode(
    'CghOb3RlVHlwZRILCgdVbmtub3duEAASDQoJQ2hlY2tsaXN0EAESCwoHSm91cm5hbBACEgcKA09yZxAD');
@$core.Deprecated('Use dateFormatDescriptor instead')
const DateFormat$json = const {
  '1': 'DateFormat',
  '2': const [
    const {'1': 'Iso8601', '2': 0},
    const {'1': 'UnixTimeStamp', '2': 1},
    const {'1': 'None', '2': 2},
  ],
};

/// Descriptor for `DateFormat`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List dateFormatDescriptor = $convert.base64Decode(
    'CgpEYXRlRm9ybWF0EgsKB0lzbzg2MDEQABIRCg1Vbml4VGltZVN0YW1wEAESCAoETm9uZRAC');
@$core.Deprecated('Use fileDescriptor instead')
const File$json = const {
  '1': 'File',
  '2': const [
    const {'1': 'repoPath', '3': 1, '4': 1, '5': 9, '10': 'repoPath'},
    const {'1': 'hash', '3': 2, '4': 1, '5': 12, '10': 'hash'},
    const {'1': 'filePath', '3': 3, '4': 1, '5': 9, '10': 'filePath'},
    const {
      '1': 'modified',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.DateTimeAnyTz',
      '10': 'modified'
    },
    const {
      '1': 'created',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.DateTimeAnyTz',
      '10': 'created'
    },
    const {
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
    'CgRGaWxlEhoKCHJlcG9QYXRoGAEgASgJUghyZXBvUGF0aBISCgRoYXNoGAIgASgMUgRoYXNoEhoKCGZpbGVQYXRoGAMgASgJUghmaWxlUGF0aBI1Cghtb2RpZmllZBgEIAEoCzIZLmdpdGpvdXJuYWwuRGF0ZVRpbWVBbnlUelIIbW9kaWZpZWQSMwoHY3JlYXRlZBgFIAEoCzIZLmdpdGpvdXJuYWwuRGF0ZVRpbWVBbnlUelIHY3JlYXRlZBJFChBmaWxlTGFzdE1vZGlmaWVkGAYgASgLMhkuZ2l0am91cm5hbC5EYXRlVGltZUFueVR6UhBmaWxlTGFzdE1vZGlmaWVk');
@$core.Deprecated('Use noteDescriptor instead')
const Note$json = const {
  '1': 'Note',
  '2': const [
    const {
      '1': 'file',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.File',
      '10': 'file'
    },
    const {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    const {'1': 'body', '3': 3, '4': 1, '5': 9, '10': 'body'},
    const {
      '1': 'type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.gitjournal.NoteType',
      '10': 'type'
    },
    const {'1': 'tags', '3': 5, '4': 3, '5': 9, '10': 'tags'},
    const {
      '1': 'extraProps',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.gitjournal.Note.ExtraPropsEntry',
      '10': 'extraProps'
    },
    const {
      '1': 'fileFormat',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.gitjournal.NoteFileFormat',
      '10': 'fileFormat'
    },
    const {
      '1': 'doc',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.MdYamlDoc',
      '10': 'doc'
    },
    const {
      '1': 'modified',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.DateTimeAnyTz',
      '10': 'modified'
    },
    const {
      '1': 'created',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.DateTimeAnyTz',
      '10': 'created'
    },
    const {
      '1': 'serializerSettings',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.NoteSerializationSettings',
      '10': 'serializerSettings'
    },
  ],
  '3': const [Note_ExtraPropsEntry$json],
};

@$core.Deprecated('Use noteDescriptor instead')
const Note_ExtraPropsEntry$json = const {
  '1': 'ExtraPropsEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.Union',
      '10': 'value'
    },
  ],
  '7': const {'7': true},
};

/// Descriptor for `Note`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List noteDescriptor = $convert.base64Decode(
    'CgROb3RlEiQKBGZpbGUYASABKAsyEC5naXRqb3VybmFsLkZpbGVSBGZpbGUSFAoFdGl0bGUYAiABKAlSBXRpdGxlEhIKBGJvZHkYAyABKAlSBGJvZHkSKAoEdHlwZRgEIAEoDjIULmdpdGpvdXJuYWwuTm90ZVR5cGVSBHR5cGUSEgoEdGFncxgFIAMoCVIEdGFncxJACgpleHRyYVByb3BzGAYgAygLMiAuZ2l0am91cm5hbC5Ob3RlLkV4dHJhUHJvcHNFbnRyeVIKZXh0cmFQcm9wcxI6CgpmaWxlRm9ybWF0GAcgASgOMhouZ2l0am91cm5hbC5Ob3RlRmlsZUZvcm1hdFIKZmlsZUZvcm1hdBInCgNkb2MYCCABKAsyFS5naXRqb3VybmFsLk1kWWFtbERvY1IDZG9jEjUKCG1vZGlmaWVkGAogASgLMhkuZ2l0am91cm5hbC5EYXRlVGltZUFueVR6Ughtb2RpZmllZBIzCgdjcmVhdGVkGAsgASgLMhkuZ2l0am91cm5hbC5EYXRlVGltZUFueVR6UgdjcmVhdGVkElUKEnNlcmlhbGl6ZXJTZXR0aW5ncxgMIAEoCzIlLmdpdGpvdXJuYWwuTm90ZVNlcmlhbGl6YXRpb25TZXR0aW5nc1ISc2VyaWFsaXplclNldHRpbmdzGlAKD0V4dHJhUHJvcHNFbnRyeRIQCgNrZXkYASABKAlSA2tleRInCgV2YWx1ZRgCIAEoCzIRLmdpdGpvdXJuYWwuVW5pb25SBXZhbHVlOgI4AQ==');
@$core.Deprecated('Use noteListDescriptor instead')
const NoteList$json = const {
  '1': 'NoteList',
  '2': const [
    const {
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
const MdYamlDoc$json = const {
  '1': 'MdYamlDoc',
  '2': const [
    const {'1': 'body', '3': 1, '4': 1, '5': 9, '10': 'body'},
    const {
      '1': 'map',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.gitjournal.MdYamlDoc.MapEntry',
      '10': 'map'
    },
  ],
  '3': const [MdYamlDoc_MapEntry$json],
};

@$core.Deprecated('Use mdYamlDocDescriptor instead')
const MdYamlDoc_MapEntry$json = const {
  '1': 'MapEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.Union',
      '10': 'value'
    },
  ],
  '7': const {'7': true},
};

/// Descriptor for `MdYamlDoc`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mdYamlDocDescriptor = $convert.base64Decode(
    'CglNZFlhbWxEb2MSEgoEYm9keRgBIAEoCVIEYm9keRIwCgNtYXAYAiADKAsyHi5naXRqb3VybmFsLk1kWWFtbERvYy5NYXBFbnRyeVIDbWFwGkkKCE1hcEVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EicKBXZhbHVlGAIgASgLMhEuZ2l0am91cm5hbC5VbmlvblIFdmFsdWU6AjgB');
@$core.Deprecated('Use unionDescriptor instead')
const Union$json = const {
  '1': 'Union',
  '2': const [
    const {
      '1': 'booleanValue',
      '3': 1,
      '4': 1,
      '5': 8,
      '9': 0,
      '10': 'booleanValue'
    },
    const {
      '1': 'stringValue',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'stringValue'
    },
    const {
      '1': 'dateValue',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.DateTimeAnyTz',
      '9': 0,
      '10': 'dateValue'
    },
    const {'1': 'intValue', '3': 4, '4': 1, '5': 3, '9': 0, '10': 'intValue'},
    const {
      '1': 'listValue',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.gitjournal.Union',
      '10': 'listValue'
    },
    const {
      '1': 'mapValue',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.gitjournal.Union.MapValueEntry',
      '10': 'mapValue'
    },
  ],
  '3': const [Union_MapValueEntry$json],
  '8': const [
    const {'1': 'UnionOneof'},
  ],
};

@$core.Deprecated('Use unionDescriptor instead')
const Union_MapValueEntry$json = const {
  '1': 'MapValueEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.gitjournal.Union',
      '10': 'value'
    },
  ],
  '7': const {'7': true},
};

/// Descriptor for `Union`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unionDescriptor = $convert.base64Decode(
    'CgVVbmlvbhIkCgxib29sZWFuVmFsdWUYASABKAhIAFIMYm9vbGVhblZhbHVlEiIKC3N0cmluZ1ZhbHVlGAIgASgJSABSC3N0cmluZ1ZhbHVlEjkKCWRhdGVWYWx1ZRgDIAEoCzIZLmdpdGpvdXJuYWwuRGF0ZVRpbWVBbnlUekgAUglkYXRlVmFsdWUSHAoIaW50VmFsdWUYBCABKANIAFIIaW50VmFsdWUSLwoJbGlzdFZhbHVlGAUgAygLMhEuZ2l0am91cm5hbC5VbmlvblIJbGlzdFZhbHVlEjsKCG1hcFZhbHVlGAYgAygLMh8uZ2l0am91cm5hbC5Vbmlvbi5NYXBWYWx1ZUVudHJ5UghtYXBWYWx1ZRpOCg1NYXBWYWx1ZUVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EicKBXZhbHVlGAIgASgLMhEuZ2l0am91cm5hbC5VbmlvblIFdmFsdWU6AjgBQgwKClVuaW9uT25lb2Y=');
@$core.Deprecated('Use dateTimeAnyTzDescriptor instead')
const DateTimeAnyTz$json = const {
  '1': 'DateTimeAnyTz',
  '2': const [
    const {'1': 'timestamp', '3': 1, '4': 1, '5': 4, '10': 'timestamp'},
    const {'1': 'offset', '3': 2, '4': 1, '5': 5, '10': 'offset'},
  ],
};

/// Descriptor for `DateTimeAnyTz`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dateTimeAnyTzDescriptor = $convert.base64Decode(
    'Cg1EYXRlVGltZUFueVR6EhwKCXRpbWVzdGFtcBgBIAEoBFIJdGltZXN0YW1wEhYKBm9mZnNldBgCIAEoBVIGb2Zmc2V0');
@$core.Deprecated('Use noteSerializationSettingsDescriptor instead')
const NoteSerializationSettings$json = const {
  '1': 'NoteSerializationSettings',
  '2': const [
    const {'1': 'modifiedKey', '3': 1, '4': 1, '5': 9, '10': 'modifiedKey'},
    const {'1': 'createdKey', '3': 2, '4': 1, '5': 9, '10': 'createdKey'},
    const {'1': 'titleKey', '3': 3, '4': 1, '5': 9, '10': 'titleKey'},
    const {'1': 'typeKey', '3': 4, '4': 1, '5': 9, '10': 'typeKey'},
    const {'1': 'tagsKey', '3': 5, '4': 1, '5': 9, '10': 'tagsKey'},
    const {'1': 'tagsInString', '3': 6, '4': 1, '5': 8, '10': 'tagsInString'},
    const {'1': 'tagsHaveHash', '3': 7, '4': 1, '5': 8, '10': 'tagsHaveHash'},
    const {'1': 'emojify', '3': 8, '4': 1, '5': 8, '10': 'emojify'},
    const {
      '1': 'modifiedFormat',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.gitjournal.DateFormat',
      '10': 'modifiedFormat'
    },
    const {
      '1': 'createdFormat',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.gitjournal.DateFormat',
      '10': 'createdFormat'
    },
    const {
      '1': 'titleSettings',
      '3': 11,
      '4': 1,
      '5': 9,
      '10': 'titleSettings'
    },
  ],
};

/// Descriptor for `NoteSerializationSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List noteSerializationSettingsDescriptor =
    $convert.base64Decode(
        'ChlOb3RlU2VyaWFsaXphdGlvblNldHRpbmdzEiAKC21vZGlmaWVkS2V5GAEgASgJUgttb2RpZmllZEtleRIeCgpjcmVhdGVkS2V5GAIgASgJUgpjcmVhdGVkS2V5EhoKCHRpdGxlS2V5GAMgASgJUgh0aXRsZUtleRIYCgd0eXBlS2V5GAQgASgJUgd0eXBlS2V5EhgKB3RhZ3NLZXkYBSABKAlSB3RhZ3NLZXkSIgoMdGFnc0luU3RyaW5nGAYgASgIUgx0YWdzSW5TdHJpbmcSIgoMdGFnc0hhdmVIYXNoGAcgASgIUgx0YWdzSGF2ZUhhc2gSGAoHZW1vamlmeRgIIAEoCFIHZW1vamlmeRI+Cg5tb2RpZmllZEZvcm1hdBgJIAEoDjIWLmdpdGpvdXJuYWwuRGF0ZUZvcm1hdFIObW9kaWZpZWRGb3JtYXQSPAoNY3JlYXRlZEZvcm1hdBgKIAEoDjIWLmdpdGpvdXJuYWwuRGF0ZUZvcm1hdFINY3JlYXRlZEZvcm1hdBIkCg10aXRsZVNldHRpbmdzGAsgASgJUg10aXRsZVNldHRpbmdz');
