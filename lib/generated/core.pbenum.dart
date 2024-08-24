//
//  Generated code. Do not modify.
//  source: core.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class NoteFileFormat extends $pb.ProtobufEnum {
  static const NoteFileFormat Markdown =
      NoteFileFormat._(0, _omitEnumNames ? '' : 'Markdown');
  static const NoteFileFormat OrgMode =
      NoteFileFormat._(1, _omitEnumNames ? '' : 'OrgMode');
  static const NoteFileFormat Txt =
      NoteFileFormat._(2, _omitEnumNames ? '' : 'Txt');

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
  static const NoteType Unknown =
      NoteType._(0, _omitEnumNames ? '' : 'Unknown');
  static const NoteType Checklist =
      NoteType._(1, _omitEnumNames ? '' : 'Checklist');
  static const NoteType Journal =
      NoteType._(2, _omitEnumNames ? '' : 'Journal');
  static const NoteType Org = NoteType._(3, _omitEnumNames ? '' : 'Org');

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

class UnixTimestampMagnitude extends $pb.ProtobufEnum {
  static const UnixTimestampMagnitude Seconds =
      UnixTimestampMagnitude._(0, _omitEnumNames ? '' : 'Seconds');
  static const UnixTimestampMagnitude Milliseconds =
      UnixTimestampMagnitude._(1, _omitEnumNames ? '' : 'Milliseconds');

  static const $core.List<UnixTimestampMagnitude> values =
      <UnixTimestampMagnitude>[
    Seconds,
    Milliseconds,
  ];

  static final $core.Map<$core.int, UnixTimestampMagnitude> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static UnixTimestampMagnitude? valueOf($core.int value) => _byValue[value];

  const UnixTimestampMagnitude._($core.int v, $core.String n) : super(v, n);
}

class DateFormat extends $pb.ProtobufEnum {
  static const DateFormat Iso8601 =
      DateFormat._(0, _omitEnumNames ? '' : 'Iso8601');
  static const DateFormat UnixTimeStamp =
      DateFormat._(1, _omitEnumNames ? '' : 'UnixTimeStamp');
  static const DateFormat None = DateFormat._(2, _omitEnumNames ? '' : 'None');
  static const DateFormat YearMonthDay =
      DateFormat._(3, _omitEnumNames ? '' : 'YearMonthDay');

  static const $core.List<DateFormat> values = <DateFormat>[
    Iso8601,
    UnixTimeStamp,
    None,
    YearMonthDay,
  ];

  static final $core.Map<$core.int, DateFormat> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static DateFormat? valueOf($core.int value) => _byValue[value];

  const DateFormat._($core.int v, $core.String n) : super(v, n);
}

const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
