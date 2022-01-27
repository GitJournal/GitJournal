// SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

///
//  Generated code. Do not modify.
//  source: core.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'core.pbenum.dart';

export 'core.pbenum.dart';

class File extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'File',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'repoPath',
        protoName: 'repoPath')
    ..a<$core.List<$core.int>>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'hash',
        $pb.PbFieldType.OY)
    ..aOS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'filePath',
        protoName: 'filePath')
    ..aOM<DateTimeAnyTz>(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'modified',
        subBuilder: DateTimeAnyTz.create)
    ..aOM<DateTimeAnyTz>(
        5,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'created',
        subBuilder: DateTimeAnyTz.create)
    ..aOM<DateTimeAnyTz>(
        6,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'fileLastModified',
        protoName: 'fileLastModified',
        subBuilder: DateTimeAnyTz.create)
    ..hasRequiredFields = false;

  File._() : super();
  factory File({
    $core.String? repoPath,
    $core.List<$core.int>? hash,
    $core.String? filePath,
    DateTimeAnyTz? modified,
    DateTimeAnyTz? created,
    DateTimeAnyTz? fileLastModified,
  }) {
    final _result = create();
    if (repoPath != null) {
      _result.repoPath = repoPath;
    }
    if (hash != null) {
      _result.hash = hash;
    }
    if (filePath != null) {
      _result.filePath = filePath;
    }
    if (modified != null) {
      _result.modified = modified;
    }
    if (created != null) {
      _result.created = created;
    }
    if (fileLastModified != null) {
      _result.fileLastModified = fileLastModified;
    }
    return _result;
  }
  factory File.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory File.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  File clone() => File()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  File copyWith(void Function(File) updates) =>
      super.copyWith((message) => updates(message as File))
          as File; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static File create() => File._();
  File createEmptyInstance() => create();
  static $pb.PbList<File> createRepeated() => $pb.PbList<File>();
  @$core.pragma('dart2js:noInline')
  static File getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<File>(create);
  static File? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get repoPath => $_getSZ(0);
  @$pb.TagNumber(1)
  set repoPath($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasRepoPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearRepoPath() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get hash => $_getN(1);
  @$pb.TagNumber(2)
  set hash($core.List<$core.int> v) {
    $_setBytes(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get filePath => $_getSZ(2);
  @$pb.TagNumber(3)
  set filePath($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasFilePath() => $_has(2);
  @$pb.TagNumber(3)
  void clearFilePath() => clearField(3);

  @$pb.TagNumber(4)
  DateTimeAnyTz get modified => $_getN(3);
  @$pb.TagNumber(4)
  set modified(DateTimeAnyTz v) {
    setField(4, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasModified() => $_has(3);
  @$pb.TagNumber(4)
  void clearModified() => clearField(4);
  @$pb.TagNumber(4)
  DateTimeAnyTz ensureModified() => $_ensure(3);

  @$pb.TagNumber(5)
  DateTimeAnyTz get created => $_getN(4);
  @$pb.TagNumber(5)
  set created(DateTimeAnyTz v) {
    setField(5, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasCreated() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreated() => clearField(5);
  @$pb.TagNumber(5)
  DateTimeAnyTz ensureCreated() => $_ensure(4);

  @$pb.TagNumber(6)
  DateTimeAnyTz get fileLastModified => $_getN(5);
  @$pb.TagNumber(6)
  set fileLastModified(DateTimeAnyTz v) {
    setField(6, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasFileLastModified() => $_has(5);
  @$pb.TagNumber(6)
  void clearFileLastModified() => clearField(6);
  @$pb.TagNumber(6)
  DateTimeAnyTz ensureFileLastModified() => $_ensure(5);
}

class Note extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'Note',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..aOM<File>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'file',
        subBuilder: File.create)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'title')
    ..aOS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'body')
    ..e<NoteType>(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'type',
        $pb.PbFieldType.OE,
        defaultOrMaker: NoteType.Unknown,
        valueOf: NoteType.valueOf,
        enumValues: NoteType.values)
    ..pPS(
        5,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'tags')
    ..m<$core.String, Union>(
        6,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'extraProps',
        protoName: 'extraProps',
        entryClassName: 'Note.ExtraPropsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Union.create,
        packageName: const $pb.PackageName('gitjournal'))
    ..e<NoteFileFormat>(
        7,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'fileFormat',
        $pb.PbFieldType.OE,
        protoName: 'fileFormat',
        defaultOrMaker: NoteFileFormat.Markdown,
        valueOf: NoteFileFormat.valueOf,
        enumValues: NoteFileFormat.values)
    ..aOM<DateTimeAnyTz>(
        10,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'modified',
        subBuilder: DateTimeAnyTz.create)
    ..aOM<DateTimeAnyTz>(
        11,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'created',
        subBuilder: DateTimeAnyTz.create)
    ..aOM<NoteSerializationSettings>(
        12,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'serializerSettings',
        protoName: 'serializerSettings',
        subBuilder: NoteSerializationSettings.create)
    ..pPS(
        13,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'propsList',
        protoName: 'propsList')
    ..hasRequiredFields = false;

  Note._() : super();
  factory Note({
    File? file,
    $core.String? title,
    $core.String? body,
    NoteType? type,
    $core.Iterable<$core.String>? tags,
    $core.Map<$core.String, Union>? extraProps,
    NoteFileFormat? fileFormat,
    DateTimeAnyTz? modified,
    DateTimeAnyTz? created,
    NoteSerializationSettings? serializerSettings,
    $core.Iterable<$core.String>? propsList,
  }) {
    final _result = create();
    if (file != null) {
      _result.file = file;
    }
    if (title != null) {
      _result.title = title;
    }
    if (body != null) {
      _result.body = body;
    }
    if (type != null) {
      _result.type = type;
    }
    if (tags != null) {
      _result.tags.addAll(tags);
    }
    if (extraProps != null) {
      _result.extraProps.addAll(extraProps);
    }
    if (fileFormat != null) {
      _result.fileFormat = fileFormat;
    }
    if (modified != null) {
      _result.modified = modified;
    }
    if (created != null) {
      _result.created = created;
    }
    if (serializerSettings != null) {
      _result.serializerSettings = serializerSettings;
    }
    if (propsList != null) {
      _result.propsList.addAll(propsList);
    }
    return _result;
  }
  factory Note.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Note.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Note clone() => Note()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Note copyWith(void Function(Note) updates) =>
      super.copyWith((message) => updates(message as Note))
          as Note; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Note create() => Note._();
  Note createEmptyInstance() => create();
  static $pb.PbList<Note> createRepeated() => $pb.PbList<Note>();
  @$core.pragma('dart2js:noInline')
  static Note getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Note>(create);
  static Note? _defaultInstance;

  @$pb.TagNumber(1)
  File get file => $_getN(0);
  @$pb.TagNumber(1)
  set file(File v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasFile() => $_has(0);
  @$pb.TagNumber(1)
  void clearFile() => clearField(1);
  @$pb.TagNumber(1)
  File ensureFile() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get body => $_getSZ(2);
  @$pb.TagNumber(3)
  set body($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasBody() => $_has(2);
  @$pb.TagNumber(3)
  void clearBody() => clearField(3);

  @$pb.TagNumber(4)
  NoteType get type => $_getN(3);
  @$pb.TagNumber(4)
  set type(NoteType v) {
    setField(4, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasType() => $_has(3);
  @$pb.TagNumber(4)
  void clearType() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.String> get tags => $_getList(4);

  @$pb.TagNumber(6)
  $core.Map<$core.String, Union> get extraProps => $_getMap(5);

  @$pb.TagNumber(7)
  NoteFileFormat get fileFormat => $_getN(6);
  @$pb.TagNumber(7)
  set fileFormat(NoteFileFormat v) {
    setField(7, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasFileFormat() => $_has(6);
  @$pb.TagNumber(7)
  void clearFileFormat() => clearField(7);

  @$pb.TagNumber(10)
  DateTimeAnyTz get modified => $_getN(7);
  @$pb.TagNumber(10)
  set modified(DateTimeAnyTz v) {
    setField(10, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasModified() => $_has(7);
  @$pb.TagNumber(10)
  void clearModified() => clearField(10);
  @$pb.TagNumber(10)
  DateTimeAnyTz ensureModified() => $_ensure(7);

  @$pb.TagNumber(11)
  DateTimeAnyTz get created => $_getN(8);
  @$pb.TagNumber(11)
  set created(DateTimeAnyTz v) {
    setField(11, v);
  }

  @$pb.TagNumber(11)
  $core.bool hasCreated() => $_has(8);
  @$pb.TagNumber(11)
  void clearCreated() => clearField(11);
  @$pb.TagNumber(11)
  DateTimeAnyTz ensureCreated() => $_ensure(8);

  @$pb.TagNumber(12)
  NoteSerializationSettings get serializerSettings => $_getN(9);
  @$pb.TagNumber(12)
  set serializerSettings(NoteSerializationSettings v) {
    setField(12, v);
  }

  @$pb.TagNumber(12)
  $core.bool hasSerializerSettings() => $_has(9);
  @$pb.TagNumber(12)
  void clearSerializerSettings() => clearField(12);
  @$pb.TagNumber(12)
  NoteSerializationSettings ensureSerializerSettings() => $_ensure(9);

  @$pb.TagNumber(13)
  $core.List<$core.String> get propsList => $_getList(10);
}

class NoteList extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'NoteList',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..pc<Note>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'notes',
        $pb.PbFieldType.PM,
        subBuilder: Note.create)
    ..hasRequiredFields = false;

  NoteList._() : super();
  factory NoteList({
    $core.Iterable<Note>? notes,
  }) {
    final _result = create();
    if (notes != null) {
      _result.notes.addAll(notes);
    }
    return _result;
  }
  factory NoteList.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory NoteList.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  NoteList clone() => NoteList()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  NoteList copyWith(void Function(NoteList) updates) =>
      super.copyWith((message) => updates(message as NoteList))
          as NoteList; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static NoteList create() => NoteList._();
  NoteList createEmptyInstance() => create();
  static $pb.PbList<NoteList> createRepeated() => $pb.PbList<NoteList>();
  @$core.pragma('dart2js:noInline')
  static NoteList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NoteList>(create);
  static NoteList? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Note> get notes => $_getList(0);
}

class MdYamlDoc extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'MdYamlDoc',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'body')
    ..m<$core.String, Union>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'map',
        entryClassName: 'MdYamlDoc.MapEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Union.create,
        packageName: const $pb.PackageName('gitjournal'))
    ..hasRequiredFields = false;

  MdYamlDoc._() : super();
  factory MdYamlDoc({
    $core.String? body,
    $core.Map<$core.String, Union>? map,
  }) {
    final _result = create();
    if (body != null) {
      _result.body = body;
    }
    if (map != null) {
      _result.map.addAll(map);
    }
    return _result;
  }
  factory MdYamlDoc.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory MdYamlDoc.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  MdYamlDoc clone() => MdYamlDoc()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  MdYamlDoc copyWith(void Function(MdYamlDoc) updates) =>
      super.copyWith((message) => updates(message as MdYamlDoc))
          as MdYamlDoc; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MdYamlDoc create() => MdYamlDoc._();
  MdYamlDoc createEmptyInstance() => create();
  static $pb.PbList<MdYamlDoc> createRepeated() => $pb.PbList<MdYamlDoc>();
  @$core.pragma('dart2js:noInline')
  static MdYamlDoc getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MdYamlDoc>(create);
  static MdYamlDoc? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get body => $_getSZ(0);
  @$pb.TagNumber(1)
  set body($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasBody() => $_has(0);
  @$pb.TagNumber(1)
  void clearBody() => clearField(1);

  @$pb.TagNumber(2)
  $core.Map<$core.String, Union> get map => $_getMap(1);
}

enum Union_UnionOneof {
  booleanValue,
  stringValue,
  dateValue,
  intValue,
  isNull,
  notSet
}

class Union extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, Union_UnionOneof> _Union_UnionOneofByTag = {
    1: Union_UnionOneof.booleanValue,
    2: Union_UnionOneof.stringValue,
    3: Union_UnionOneof.dateValue,
    4: Union_UnionOneof.intValue,
    7: Union_UnionOneof.isNull,
    0: Union_UnionOneof.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'Union',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 7])
    ..aOB(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'booleanValue',
        protoName: 'booleanValue')
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'stringValue',
        protoName: 'stringValue')
    ..aOM<DateTimeAnyTz>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'dateValue',
        protoName: 'dateValue',
        subBuilder: DateTimeAnyTz.create)
    ..aInt64(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'intValue',
        protoName: 'intValue')
    ..pc<Union>(
        5,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'listValue',
        $pb.PbFieldType.PM,
        protoName: 'listValue',
        subBuilder: Union.create)
    ..m<$core.String, Union>(
        6,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'mapValue',
        protoName: 'mapValue',
        entryClassName: 'Union.MapValueEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Union.create,
        packageName: const $pb.PackageName('gitjournal'))
    ..aOB(
        7,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'isNull',
        protoName: 'isNull')
    ..hasRequiredFields = false;

  Union._() : super();
  factory Union({
    $core.bool? booleanValue,
    $core.String? stringValue,
    DateTimeAnyTz? dateValue,
    $fixnum.Int64? intValue,
    $core.Iterable<Union>? listValue,
    $core.Map<$core.String, Union>? mapValue,
    $core.bool? isNull,
  }) {
    final _result = create();
    if (booleanValue != null) {
      _result.booleanValue = booleanValue;
    }
    if (stringValue != null) {
      _result.stringValue = stringValue;
    }
    if (dateValue != null) {
      _result.dateValue = dateValue;
    }
    if (intValue != null) {
      _result.intValue = intValue;
    }
    if (listValue != null) {
      _result.listValue.addAll(listValue);
    }
    if (mapValue != null) {
      _result.mapValue.addAll(mapValue);
    }
    if (isNull != null) {
      _result.isNull = isNull;
    }
    return _result;
  }
  factory Union.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Union.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Union clone() => Union()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Union copyWith(void Function(Union) updates) =>
      super.copyWith((message) => updates(message as Union))
          as Union; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Union create() => Union._();
  Union createEmptyInstance() => create();
  static $pb.PbList<Union> createRepeated() => $pb.PbList<Union>();
  @$core.pragma('dart2js:noInline')
  static Union getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Union>(create);
  static Union? _defaultInstance;

  Union_UnionOneof whichUnionOneof() =>
      _Union_UnionOneofByTag[$_whichOneof(0)]!;
  void clearUnionOneof() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.bool get booleanValue => $_getBF(0);
  @$pb.TagNumber(1)
  set booleanValue($core.bool v) {
    $_setBool(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasBooleanValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearBooleanValue() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get stringValue => $_getSZ(1);
  @$pb.TagNumber(2)
  set stringValue($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasStringValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearStringValue() => clearField(2);

  @$pb.TagNumber(3)
  DateTimeAnyTz get dateValue => $_getN(2);
  @$pb.TagNumber(3)
  set dateValue(DateTimeAnyTz v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasDateValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearDateValue() => clearField(3);
  @$pb.TagNumber(3)
  DateTimeAnyTz ensureDateValue() => $_ensure(2);

  @$pb.TagNumber(4)
  $fixnum.Int64 get intValue => $_getI64(3);
  @$pb.TagNumber(4)
  set intValue($fixnum.Int64 v) {
    $_setInt64(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasIntValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearIntValue() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<Union> get listValue => $_getList(4);

  @$pb.TagNumber(6)
  $core.Map<$core.String, Union> get mapValue => $_getMap(5);

  @$pb.TagNumber(7)
  $core.bool get isNull => $_getBF(6);
  @$pb.TagNumber(7)
  set isNull($core.bool v) {
    $_setBool(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasIsNull() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsNull() => clearField(7);
}

class DateTimeAnyTz extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'DateTimeAnyTz',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'timestamp',
        $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.int>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'offset',
        $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  DateTimeAnyTz._() : super();
  factory DateTimeAnyTz({
    $fixnum.Int64? timestamp,
    $core.int? offset,
  }) {
    final _result = create();
    if (timestamp != null) {
      _result.timestamp = timestamp;
    }
    if (offset != null) {
      _result.offset = offset;
    }
    return _result;
  }
  factory DateTimeAnyTz.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory DateTimeAnyTz.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  DateTimeAnyTz clone() => DateTimeAnyTz()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  DateTimeAnyTz copyWith(void Function(DateTimeAnyTz) updates) =>
      super.copyWith((message) => updates(message as DateTimeAnyTz))
          as DateTimeAnyTz; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static DateTimeAnyTz create() => DateTimeAnyTz._();
  DateTimeAnyTz createEmptyInstance() => create();
  static $pb.PbList<DateTimeAnyTz> createRepeated() =>
      $pb.PbList<DateTimeAnyTz>();
  @$core.pragma('dart2js:noInline')
  static DateTimeAnyTz getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DateTimeAnyTz>(create);
  static DateTimeAnyTz? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get timestamp => $_getI64(0);
  @$pb.TagNumber(1)
  set timestamp($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get offset => $_getIZ(1);
  @$pb.TagNumber(2)
  set offset($core.int v) {
    $_setSignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasOffset() => $_has(1);
  @$pb.TagNumber(2)
  void clearOffset() => clearField(2);
}

class NoteSerializationSettings extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'NoteSerializationSettings',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'modifiedKey',
        protoName: 'modifiedKey')
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'createdKey',
        protoName: 'createdKey')
    ..aOS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'titleKey',
        protoName: 'titleKey')
    ..aOS(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'typeKey',
        protoName: 'typeKey')
    ..aOS(
        5,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'tagsKey',
        protoName: 'tagsKey')
    ..aOB(
        6,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'tagsInString',
        protoName: 'tagsInString')
    ..aOB(
        7,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'tagsHaveHash',
        protoName: 'tagsHaveHash')
    ..aOB(
        8,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'emojify')
    ..e<DateFormat>(
        9,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'modifiedFormat',
        $pb.PbFieldType.OE,
        protoName: 'modifiedFormat',
        defaultOrMaker: DateFormat.Iso8601,
        valueOf: DateFormat.valueOf,
        enumValues: DateFormat.values)
    ..e<DateFormat>(
        10,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'createdFormat',
        $pb.PbFieldType.OE,
        protoName: 'createdFormat',
        defaultOrMaker: DateFormat.Iso8601,
        valueOf: DateFormat.valueOf,
        enumValues: DateFormat.values)
    ..aOS(
        11,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'titleSettings',
        protoName: 'titleSettings')
    ..hasRequiredFields = false;

  NoteSerializationSettings._() : super();
  factory NoteSerializationSettings({
    $core.String? modifiedKey,
    $core.String? createdKey,
    $core.String? titleKey,
    $core.String? typeKey,
    $core.String? tagsKey,
    $core.bool? tagsInString,
    $core.bool? tagsHaveHash,
    $core.bool? emojify,
    DateFormat? modifiedFormat,
    DateFormat? createdFormat,
    $core.String? titleSettings,
  }) {
    final _result = create();
    if (modifiedKey != null) {
      _result.modifiedKey = modifiedKey;
    }
    if (createdKey != null) {
      _result.createdKey = createdKey;
    }
    if (titleKey != null) {
      _result.titleKey = titleKey;
    }
    if (typeKey != null) {
      _result.typeKey = typeKey;
    }
    if (tagsKey != null) {
      _result.tagsKey = tagsKey;
    }
    if (tagsInString != null) {
      _result.tagsInString = tagsInString;
    }
    if (tagsHaveHash != null) {
      _result.tagsHaveHash = tagsHaveHash;
    }
    if (emojify != null) {
      _result.emojify = emojify;
    }
    if (modifiedFormat != null) {
      _result.modifiedFormat = modifiedFormat;
    }
    if (createdFormat != null) {
      _result.createdFormat = createdFormat;
    }
    if (titleSettings != null) {
      _result.titleSettings = titleSettings;
    }
    return _result;
  }
  factory NoteSerializationSettings.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory NoteSerializationSettings.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  NoteSerializationSettings clone() =>
      NoteSerializationSettings()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  NoteSerializationSettings copyWith(
          void Function(NoteSerializationSettings) updates) =>
      super.copyWith((message) => updates(message as NoteSerializationSettings))
          as NoteSerializationSettings; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static NoteSerializationSettings create() => NoteSerializationSettings._();
  NoteSerializationSettings createEmptyInstance() => create();
  static $pb.PbList<NoteSerializationSettings> createRepeated() =>
      $pb.PbList<NoteSerializationSettings>();
  @$core.pragma('dart2js:noInline')
  static NoteSerializationSettings getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NoteSerializationSettings>(create);
  static NoteSerializationSettings? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get modifiedKey => $_getSZ(0);
  @$pb.TagNumber(1)
  set modifiedKey($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasModifiedKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearModifiedKey() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get createdKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set createdKey($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasCreatedKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearCreatedKey() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get titleKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set titleKey($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasTitleKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitleKey() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get typeKey => $_getSZ(3);
  @$pb.TagNumber(4)
  set typeKey($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasTypeKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearTypeKey() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get tagsKey => $_getSZ(4);
  @$pb.TagNumber(5)
  set tagsKey($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasTagsKey() => $_has(4);
  @$pb.TagNumber(5)
  void clearTagsKey() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get tagsInString => $_getBF(5);
  @$pb.TagNumber(6)
  set tagsInString($core.bool v) {
    $_setBool(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasTagsInString() => $_has(5);
  @$pb.TagNumber(6)
  void clearTagsInString() => clearField(6);

  @$pb.TagNumber(7)
  $core.bool get tagsHaveHash => $_getBF(6);
  @$pb.TagNumber(7)
  set tagsHaveHash($core.bool v) {
    $_setBool(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasTagsHaveHash() => $_has(6);
  @$pb.TagNumber(7)
  void clearTagsHaveHash() => clearField(7);

  @$pb.TagNumber(8)
  $core.bool get emojify => $_getBF(7);
  @$pb.TagNumber(8)
  set emojify($core.bool v) {
    $_setBool(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasEmojify() => $_has(7);
  @$pb.TagNumber(8)
  void clearEmojify() => clearField(8);

  @$pb.TagNumber(9)
  DateFormat get modifiedFormat => $_getN(8);
  @$pb.TagNumber(9)
  set modifiedFormat(DateFormat v) {
    setField(9, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasModifiedFormat() => $_has(8);
  @$pb.TagNumber(9)
  void clearModifiedFormat() => clearField(9);

  @$pb.TagNumber(10)
  DateFormat get createdFormat => $_getN(9);
  @$pb.TagNumber(10)
  set createdFormat(DateFormat v) {
    setField(10, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasCreatedFormat() => $_has(9);
  @$pb.TagNumber(10)
  void clearCreatedFormat() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get titleSettings => $_getSZ(10);
  @$pb.TagNumber(11)
  set titleSettings($core.String v) {
    $_setString(10, v);
  }

  @$pb.TagNumber(11)
  $core.bool hasTitleSettings() => $_has(10);
  @$pb.TagNumber(11)
  void clearTitleSettings() => clearField(11);
}
