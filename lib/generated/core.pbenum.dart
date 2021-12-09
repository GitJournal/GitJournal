// SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

///
//  Generated code. Do not modify.
//  source: core.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

// ignore_for_file: UNDEFINED_SHOWN_NAME

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class NoteFileFormat extends $pb.ProtobufEnum {
  static const NoteFileFormat Markdown = NoteFileFormat._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'Markdown');
  static const NoteFileFormat OrgMode = NoteFileFormat._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'OrgMode');
  static const NoteFileFormat Txt = NoteFileFormat._(
      2,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'Txt');

  static const $core.List<NoteFileFormat> values = <NoteFileFormat>[
    Markdown,
    OrgMode,
    Txt,
  ];

  static final $core.Map<$core.int, NoteFileFormat> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static NoteFileFormat? valueOf($core.int value) => _byValue[value];

  const NoteFileFormat._($core.int v, $core.String n) : super(v, n);
}

class NoteType extends $pb.ProtobufEnum {
  static const NoteType Unknown = NoteType._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'Unknown');
  static const NoteType Checklist = NoteType._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'Checklist');
  static const NoteType Journal = NoteType._(
      2,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'Journal');
  static const NoteType Org = NoteType._(
      3,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'Org');

  static const $core.List<NoteType> values = <NoteType>[
    Unknown,
    Checklist,
    Journal,
    Org,
  ];

  static final $core.Map<$core.int, NoteType> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static NoteType? valueOf($core.int value) => _byValue[value];

  const NoteType._($core.int v, $core.String n) : super(v, n);
}

class DateFormat extends $pb.ProtobufEnum {
  static const DateFormat Iso8601 = DateFormat._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'Iso8601');
  static const DateFormat UnixTimeStamp = DateFormat._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'UnixTimeStamp');
  static const DateFormat None = DateFormat._(
      2,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'None');

  static const $core.List<DateFormat> values = <DateFormat>[
    Iso8601,
    UnixTimeStamp,
    None,
  ];

  static final $core.Map<$core.int, DateFormat> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static DateFormat? valueOf($core.int value) => _byValue[value];

  const DateFormat._($core.int v, $core.String n) : super(v, n);
}
