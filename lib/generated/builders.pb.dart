// SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

///
//  Generated code. Do not modify.
//  source: builders.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class BlobCTimeBuilderData extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'BlobCTimeBuilderData',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..p<$core.List<$core.int>>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'commitHashes',
        $pb.PbFieldType.PY,
        protoName: 'commitHashes')
    ..p<$core.List<$core.int>>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'treeHashes',
        $pb.PbFieldType.PY,
        protoName: 'treeHashes')
    ..m<$core.String, TzDateTime>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'map',
        entryClassName: 'BlobCTimeBuilderData.MapEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: TzDateTime.create,
        packageName: const $pb.PackageName('gitjournal'))
    ..hasRequiredFields = false;

  BlobCTimeBuilderData._() : super();
  factory BlobCTimeBuilderData({
    $core.Iterable<$core.List<$core.int>>? commitHashes,
    $core.Iterable<$core.List<$core.int>>? treeHashes,
    $core.Map<$core.String, TzDateTime>? map,
  }) {
    final _result = create();
    if (commitHashes != null) {
      _result.commitHashes.addAll(commitHashes);
    }
    if (treeHashes != null) {
      _result.treeHashes.addAll(treeHashes);
    }
    if (map != null) {
      _result.map.addAll(map);
    }
    return _result;
  }
  factory BlobCTimeBuilderData.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory BlobCTimeBuilderData.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  BlobCTimeBuilderData clone() =>
      BlobCTimeBuilderData()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  BlobCTimeBuilderData copyWith(void Function(BlobCTimeBuilderData) updates) =>
      super.copyWith((message) => updates(message as BlobCTimeBuilderData))
          as BlobCTimeBuilderData; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static BlobCTimeBuilderData create() => BlobCTimeBuilderData._();
  BlobCTimeBuilderData createEmptyInstance() => create();
  static $pb.PbList<BlobCTimeBuilderData> createRepeated() =>
      $pb.PbList<BlobCTimeBuilderData>();
  @$core.pragma('dart2js:noInline')
  static BlobCTimeBuilderData getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlobCTimeBuilderData>(create);
  static BlobCTimeBuilderData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.List<$core.int>> get commitHashes => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<$core.List<$core.int>> get treeHashes => $_getList(1);

  @$pb.TagNumber(3)
  $core.Map<$core.String, TzDateTime> get map => $_getMap(2);
}

class FileMTimeBuilderData extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'FileMTimeBuilderData',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..p<$core.List<$core.int>>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'commitHashes',
        $pb.PbFieldType.PY,
        protoName: 'commitHashes')
    ..p<$core.List<$core.int>>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'treeHashes',
        $pb.PbFieldType.PY,
        protoName: 'treeHashes')
    ..m<$core.String, FileMTimeInfo>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'map',
        entryClassName: 'FileMTimeBuilderData.MapEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: FileMTimeInfo.create,
        packageName: const $pb.PackageName('gitjournal'))
    ..hasRequiredFields = false;

  FileMTimeBuilderData._() : super();
  factory FileMTimeBuilderData({
    $core.Iterable<$core.List<$core.int>>? commitHashes,
    $core.Iterable<$core.List<$core.int>>? treeHashes,
    $core.Map<$core.String, FileMTimeInfo>? map,
  }) {
    final _result = create();
    if (commitHashes != null) {
      _result.commitHashes.addAll(commitHashes);
    }
    if (treeHashes != null) {
      _result.treeHashes.addAll(treeHashes);
    }
    if (map != null) {
      _result.map.addAll(map);
    }
    return _result;
  }
  factory FileMTimeBuilderData.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory FileMTimeBuilderData.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  FileMTimeBuilderData clone() =>
      FileMTimeBuilderData()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  FileMTimeBuilderData copyWith(void Function(FileMTimeBuilderData) updates) =>
      super.copyWith((message) => updates(message as FileMTimeBuilderData))
          as FileMTimeBuilderData; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static FileMTimeBuilderData create() => FileMTimeBuilderData._();
  FileMTimeBuilderData createEmptyInstance() => create();
  static $pb.PbList<FileMTimeBuilderData> createRepeated() =>
      $pb.PbList<FileMTimeBuilderData>();
  @$core.pragma('dart2js:noInline')
  static FileMTimeBuilderData getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FileMTimeBuilderData>(create);
  static FileMTimeBuilderData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.List<$core.int>> get commitHashes => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<$core.List<$core.int>> get treeHashes => $_getList(1);

  @$pb.TagNumber(3)
  $core.Map<$core.String, FileMTimeInfo> get map => $_getMap(2);
}

class TzDateTime extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'TzDateTime',
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

  TzDateTime._() : super();
  factory TzDateTime({
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
  factory TzDateTime.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory TzDateTime.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  TzDateTime clone() => TzDateTime()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  TzDateTime copyWith(void Function(TzDateTime) updates) =>
      super.copyWith((message) => updates(message as TzDateTime))
          as TzDateTime; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TzDateTime create() => TzDateTime._();
  TzDateTime createEmptyInstance() => create();
  static $pb.PbList<TzDateTime> createRepeated() => $pb.PbList<TzDateTime>();
  @$core.pragma('dart2js:noInline')
  static TzDateTime getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TzDateTime>(create);
  static TzDateTime? _defaultInstance;

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

class FileMTimeInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'FileMTimeInfo',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'filePath',
        protoName: 'filePath')
    ..a<$core.List<$core.int>>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'hash',
        $pb.PbFieldType.OY)
    ..aOM<TzDateTime>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'dt',
        subBuilder: TzDateTime.create)
    ..hasRequiredFields = false;

  FileMTimeInfo._() : super();
  factory FileMTimeInfo({
    $core.String? filePath,
    $core.List<$core.int>? hash,
    TzDateTime? dt,
  }) {
    final _result = create();
    if (filePath != null) {
      _result.filePath = filePath;
    }
    if (hash != null) {
      _result.hash = hash;
    }
    if (dt != null) {
      _result.dt = dt;
    }
    return _result;
  }
  factory FileMTimeInfo.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory FileMTimeInfo.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  FileMTimeInfo clone() => FileMTimeInfo()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  FileMTimeInfo copyWith(void Function(FileMTimeInfo) updates) =>
      super.copyWith((message) => updates(message as FileMTimeInfo))
          as FileMTimeInfo; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static FileMTimeInfo create() => FileMTimeInfo._();
  FileMTimeInfo createEmptyInstance() => create();
  static $pb.PbList<FileMTimeInfo> createRepeated() =>
      $pb.PbList<FileMTimeInfo>();
  @$core.pragma('dart2js:noInline')
  static FileMTimeInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FileMTimeInfo>(create);
  static FileMTimeInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filePath => $_getSZ(0);
  @$pb.TagNumber(1)
  set filePath($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasFilePath() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilePath() => clearField(1);

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
  TzDateTime get dt => $_getN(2);
  @$pb.TagNumber(3)
  set dt(TzDateTime v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasDt() => $_has(2);
  @$pb.TagNumber(3)
  void clearDt() => clearField(3);
  @$pb.TagNumber(3)
  TzDateTime ensureDt() => $_ensure(2);
}
