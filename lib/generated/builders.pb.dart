//
//  Generated code. Do not modify.
//  source: builders.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class BlobCTimeBuilderData extends $pb.GeneratedMessage {
  factory BlobCTimeBuilderData({
    $core.Iterable<$core.List<$core.int>>? commitHashes,
    $core.Iterable<$core.List<$core.int>>? treeHashes,
    $core.Map<$core.String, TzDateTime>? map,
    $core.List<$core.int>? headHash,
  }) {
    final $result = create();
    if (commitHashes != null) {
      $result.commitHashes.addAll(commitHashes);
    }
    if (treeHashes != null) {
      $result.treeHashes.addAll(treeHashes);
    }
    if (map != null) {
      $result.map.addAll(map);
    }
    if (headHash != null) {
      $result.headHash = headHash;
    }
    return $result;
  }
  BlobCTimeBuilderData._() : super();
  factory BlobCTimeBuilderData.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory BlobCTimeBuilderData.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlobCTimeBuilderData',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gitjournal'),
      createEmptyInstance: create)
    ..p<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'commitHashes', $pb.PbFieldType.PY,
        protoName: 'commitHashes')
    ..p<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'treeHashes', $pb.PbFieldType.PY,
        protoName: 'treeHashes')
    ..m<$core.String, TzDateTime>(3, _omitFieldNames ? '' : 'map',
        entryClassName: 'BlobCTimeBuilderData.MapEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: TzDateTime.create,
        // valueDefaultOrMaker: TzDateTime.getDefault,
        packageName: const $pb.PackageName('gitjournal'))
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'headHash', $pb.PbFieldType.OY,
        protoName: 'headHash')
    ..hasRequiredFields = false;

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
          as BlobCTimeBuilderData;

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

  @$pb.TagNumber(4)
  $core.List<$core.int> get headHash => $_getN(3);
  @$pb.TagNumber(4)
  set headHash($core.List<$core.int> v) {
    $_setBytes(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasHeadHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeadHash() => clearField(4);
}

class FileMTimeBuilderData extends $pb.GeneratedMessage {
  factory FileMTimeBuilderData({
    $core.Iterable<$core.List<$core.int>>? commitHashes,
    $core.Map<$core.String, FileMTimeInfo>? map,
    $core.List<$core.int>? headHash,
  }) {
    final $result = create();
    if (commitHashes != null) {
      $result.commitHashes.addAll(commitHashes);
    }
    if (map != null) {
      $result.map.addAll(map);
    }
    if (headHash != null) {
      $result.headHash = headHash;
    }
    return $result;
  }
  FileMTimeBuilderData._() : super();
  factory FileMTimeBuilderData.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory FileMTimeBuilderData.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileMTimeBuilderData',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gitjournal'),
      createEmptyInstance: create)
    ..p<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'commitHashes', $pb.PbFieldType.PY,
        protoName: 'commitHashes')
    ..m<$core.String, FileMTimeInfo>(3, _omitFieldNames ? '' : 'map',
        entryClassName: 'FileMTimeBuilderData.MapEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: FileMTimeInfo.create,
        // valueDefaultOrMaker: FileMTimeInfo.getDefault,
        packageName: const $pb.PackageName('gitjournal'))
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'headHash', $pb.PbFieldType.OY,
        protoName: 'headHash')
    ..hasRequiredFields = false;

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
          as FileMTimeBuilderData;

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

  @$pb.TagNumber(3)
  $core.Map<$core.String, FileMTimeInfo> get map => $_getMap(1);

  @$pb.TagNumber(4)
  $core.List<$core.int> get headHash => $_getN(2);
  @$pb.TagNumber(4)
  set headHash($core.List<$core.int> v) {
    $_setBytes(2, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasHeadHash() => $_has(2);
  @$pb.TagNumber(4)
  void clearHeadHash() => clearField(4);
}

class TzDateTime extends $pb.GeneratedMessage {
  factory TzDateTime({
    $fixnum.Int64? timestamp,
    $core.int? offset,
  }) {
    final $result = create();
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (offset != null) {
      $result.offset = offset;
    }
    return $result;
  }
  TzDateTime._() : super();
  factory TzDateTime.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory TzDateTime.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TzDateTime',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gitjournal'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'timestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'offset', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  TzDateTime clone() => TzDateTime()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  TzDateTime copyWith(void Function(TzDateTime) updates) =>
      super.copyWith((message) => updates(message as TzDateTime)) as TzDateTime;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TzDateTime create() => TzDateTime._();
  TzDateTime createEmptyInstance() => create();
  static $pb.PbList<TzDateTime> createRepeated() => $pb.PbList<TzDateTime>();
  @$core.pragma('dart2js:noInline')
  static TzDateTime getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TzDateTime>(create);
  static TzDateTime? _defaultInstance;

  /// / in seconds
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

  /// / offset in seconds east of GMT
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
  factory FileMTimeInfo({
    $core.String? filePath,
    $core.List<$core.int>? hash,
    TzDateTime? dt,
  }) {
    final $result = create();
    if (filePath != null) {
      $result.filePath = filePath;
    }
    if (hash != null) {
      $result.hash = hash;
    }
    if (dt != null) {
      $result.dt = dt;
    }
    return $result;
  }
  FileMTimeInfo._() : super();
  factory FileMTimeInfo.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory FileMTimeInfo.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileMTimeInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'filePath', protoName: 'filePath')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'hash', $pb.PbFieldType.OY)
    ..aOM<TzDateTime>(3, _omitFieldNames ? '' : 'dt',
        subBuilder: TzDateTime.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  FileMTimeInfo clone() => FileMTimeInfo()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  FileMTimeInfo copyWith(void Function(FileMTimeInfo) updates) =>
      super.copyWith((message) => updates(message as FileMTimeInfo))
          as FileMTimeInfo;

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

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
