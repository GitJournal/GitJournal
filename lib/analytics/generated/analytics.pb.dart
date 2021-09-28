// SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

///
//  Generated code. Do not modify.
//  source: analytics.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'analytics.pbenum.dart';

export 'analytics.pbenum.dart';

class AnalyticsReply extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'AnalyticsReply',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  AnalyticsReply._() : super();
  factory AnalyticsReply() => create();
  factory AnalyticsReply.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory AnalyticsReply.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  AnalyticsReply clone() => AnalyticsReply()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  AnalyticsReply copyWith(void Function(AnalyticsReply) updates) =>
      super.copyWith((message) => updates(message as AnalyticsReply))
          as AnalyticsReply; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AnalyticsReply create() => AnalyticsReply._();
  AnalyticsReply createEmptyInstance() => create();
  static $pb.PbList<AnalyticsReply> createRepeated() =>
      $pb.PbList<AnalyticsReply>();
  @$core.pragma('dart2js:noInline')
  static AnalyticsReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AnalyticsReply>(create);
  static AnalyticsReply? _defaultInstance;
}

class AnalyticsMessage extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'AnalyticsMessage',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'appId',
        protoName: 'appId')
    ..pc<Event>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'events',
        $pb.PbFieldType.PM,
        subBuilder: Event.create)
    ..aOM<DeviceInfo>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'deviceInfo',
        protoName: 'deviceInfo',
        subBuilder: DeviceInfo.create)
    ..aOM<PackageInfo>(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'packageInfo',
        protoName: 'packageInfo',
        subBuilder: PackageInfo.create)
    ..hasRequiredFields = false;

  AnalyticsMessage._() : super();
  factory AnalyticsMessage({
    $core.String? appId,
    $core.Iterable<Event>? events,
    DeviceInfo? deviceInfo,
    PackageInfo? packageInfo,
  }) {
    final _result = create();
    if (appId != null) {
      _result.appId = appId;
    }
    if (events != null) {
      _result.events.addAll(events);
    }
    if (deviceInfo != null) {
      _result.deviceInfo = deviceInfo;
    }
    if (packageInfo != null) {
      _result.packageInfo = packageInfo;
    }
    return _result;
  }
  factory AnalyticsMessage.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory AnalyticsMessage.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  AnalyticsMessage clone() => AnalyticsMessage()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  AnalyticsMessage copyWith(void Function(AnalyticsMessage) updates) =>
      super.copyWith((message) => updates(message as AnalyticsMessage))
          as AnalyticsMessage; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AnalyticsMessage create() => AnalyticsMessage._();
  AnalyticsMessage createEmptyInstance() => create();
  static $pb.PbList<AnalyticsMessage> createRepeated() =>
      $pb.PbList<AnalyticsMessage>();
  @$core.pragma('dart2js:noInline')
  static AnalyticsMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AnalyticsMessage>(create);
  static AnalyticsMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get appId => $_getSZ(0);
  @$pb.TagNumber(1)
  set appId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasAppId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAppId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<Event> get events => $_getList(1);

  @$pb.TagNumber(3)
  DeviceInfo get deviceInfo => $_getN(2);
  @$pb.TagNumber(3)
  set deviceInfo(DeviceInfo v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasDeviceInfo() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceInfo() => clearField(3);
  @$pb.TagNumber(3)
  DeviceInfo ensureDeviceInfo() => $_ensure(2);

  @$pb.TagNumber(4)
  PackageInfo get packageInfo => $_getN(3);
  @$pb.TagNumber(4)
  set packageInfo(PackageInfo v) {
    setField(4, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasPackageInfo() => $_has(3);
  @$pb.TagNumber(4)
  void clearPackageInfo() => clearField(4);
  @$pb.TagNumber(4)
  PackageInfo ensurePackageInfo() => $_ensure(3);
}

class Event extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'Event',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'name')
    ..a<$fixnum.Int64>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'date',
        $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..m<$core.String, $core.String>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'params',
        entryClassName: 'Event.ParamsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('gitjournal'))
    ..aOS(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'userId',
        protoName: 'userId')
    ..aOS(
        5,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'pseudoId',
        protoName: 'pseudoId')
    ..m<$core.String, $core.String>(
        6,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'userProperties',
        protoName: 'userProperties',
        entryClassName: 'Event.UserPropertiesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('gitjournal'))
    ..a<$core.int>(
        7,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'sessionID',
        $pb.PbFieldType.OU3,
        protoName: 'sessionID')
    ..hasRequiredFields = false;

  Event._() : super();
  factory Event({
    $core.String? name,
    $fixnum.Int64? date,
    $core.Map<$core.String, $core.String>? params,
    $core.String? userId,
    $core.String? pseudoId,
    $core.Map<$core.String, $core.String>? userProperties,
    $core.int? sessionID,
  }) {
    final _result = create();
    if (name != null) {
      _result.name = name;
    }
    if (date != null) {
      _result.date = date;
    }
    if (params != null) {
      _result.params.addAll(params);
    }
    if (userId != null) {
      _result.userId = userId;
    }
    if (pseudoId != null) {
      _result.pseudoId = pseudoId;
    }
    if (userProperties != null) {
      _result.userProperties.addAll(userProperties);
    }
    if (sessionID != null) {
      _result.sessionID = sessionID;
    }
    return _result;
  }
  factory Event.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Event.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Event clone() => Event()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Event copyWith(void Function(Event) updates) =>
      super.copyWith((message) => updates(message as Event))
          as Event; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Event create() => Event._();
  Event createEmptyInstance() => create();
  static $pb.PbList<Event> createRepeated() => $pb.PbList<Event>();
  @$core.pragma('dart2js:noInline')
  static Event getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Event>(create);
  static Event? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get date => $_getI64(1);
  @$pb.TagNumber(2)
  set date($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearDate() => clearField(2);

  @$pb.TagNumber(3)
  $core.Map<$core.String, $core.String> get params => $_getMap(2);

  @$pb.TagNumber(4)
  $core.String get userId => $_getSZ(3);
  @$pb.TagNumber(4)
  set userId($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasUserId() => $_has(3);
  @$pb.TagNumber(4)
  void clearUserId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get pseudoId => $_getSZ(4);
  @$pb.TagNumber(5)
  set pseudoId($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasPseudoId() => $_has(4);
  @$pb.TagNumber(5)
  void clearPseudoId() => clearField(5);

  @$pb.TagNumber(6)
  $core.Map<$core.String, $core.String> get userProperties => $_getMap(5);

  @$pb.TagNumber(7)
  $core.int get sessionID => $_getIZ(6);
  @$pb.TagNumber(7)
  set sessionID($core.int v) {
    $_setUnsignedInt32(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasSessionID() => $_has(6);
  @$pb.TagNumber(7)
  void clearSessionID() => clearField(7);
}

enum DeviceInfo_DeviceInfo {
  androidDeviceInfo,
  iosDeviceInfo,
  linuxDeviceInfo,
  macOSDeviceInfo,
  windowsDeviceInfo,
  webBrowserInfo,
  notSet
}

class DeviceInfo extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, DeviceInfo_DeviceInfo>
      _DeviceInfo_DeviceInfoByTag = {
    11: DeviceInfo_DeviceInfo.androidDeviceInfo,
    12: DeviceInfo_DeviceInfo.iosDeviceInfo,
    13: DeviceInfo_DeviceInfo.linuxDeviceInfo,
    14: DeviceInfo_DeviceInfo.macOSDeviceInfo,
    15: DeviceInfo_DeviceInfo.windowsDeviceInfo,
    16: DeviceInfo_DeviceInfo.webBrowserInfo,
    0: DeviceInfo_DeviceInfo.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'DeviceInfo',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..oo(0, [11, 12, 13, 14, 15, 16])
    ..e<Platform>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'platform',
        $pb.PbFieldType.OE,
        defaultOrMaker: Platform.android,
        valueOf: Platform.valueOf,
        enumValues: Platform.values)
    ..aOM<AndroidDeviceInfo>(
        11,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'androidDeviceInfo',
        protoName: 'androidDeviceInfo',
        subBuilder: AndroidDeviceInfo.create)
    ..aOM<IosDeviceInfo>(
        12,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'iosDeviceInfo',
        protoName: 'iosDeviceInfo',
        subBuilder: IosDeviceInfo.create)
    ..aOM<LinuxDeviceInfo>(
        13,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'linuxDeviceInfo',
        protoName: 'linuxDeviceInfo',
        subBuilder: LinuxDeviceInfo.create)
    ..aOM<MacOSDeviceInfo>(
        14,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'macOSDeviceInfo',
        protoName: 'macOSDeviceInfo',
        subBuilder: MacOSDeviceInfo.create)
    ..aOM<WindowsDeviceInfo>(
        15,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'windowsDeviceInfo',
        protoName: 'windowsDeviceInfo',
        subBuilder: WindowsDeviceInfo.create)
    ..aOM<WebBrowserInfo>(
        16,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'webBrowserInfo',
        protoName: 'webBrowserInfo',
        subBuilder: WebBrowserInfo.create)
    ..hasRequiredFields = false;

  DeviceInfo._() : super();
  factory DeviceInfo({
    Platform? platform,
    AndroidDeviceInfo? androidDeviceInfo,
    IosDeviceInfo? iosDeviceInfo,
    LinuxDeviceInfo? linuxDeviceInfo,
    MacOSDeviceInfo? macOSDeviceInfo,
    WindowsDeviceInfo? windowsDeviceInfo,
    WebBrowserInfo? webBrowserInfo,
  }) {
    final _result = create();
    if (platform != null) {
      _result.platform = platform;
    }
    if (androidDeviceInfo != null) {
      _result.androidDeviceInfo = androidDeviceInfo;
    }
    if (iosDeviceInfo != null) {
      _result.iosDeviceInfo = iosDeviceInfo;
    }
    if (linuxDeviceInfo != null) {
      _result.linuxDeviceInfo = linuxDeviceInfo;
    }
    if (macOSDeviceInfo != null) {
      _result.macOSDeviceInfo = macOSDeviceInfo;
    }
    if (windowsDeviceInfo != null) {
      _result.windowsDeviceInfo = windowsDeviceInfo;
    }
    if (webBrowserInfo != null) {
      _result.webBrowserInfo = webBrowserInfo;
    }
    return _result;
  }
  factory DeviceInfo.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory DeviceInfo.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  DeviceInfo clone() => DeviceInfo()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  DeviceInfo copyWith(void Function(DeviceInfo) updates) =>
      super.copyWith((message) => updates(message as DeviceInfo))
          as DeviceInfo; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static DeviceInfo create() => DeviceInfo._();
  DeviceInfo createEmptyInstance() => create();
  static $pb.PbList<DeviceInfo> createRepeated() => $pb.PbList<DeviceInfo>();
  @$core.pragma('dart2js:noInline')
  static DeviceInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeviceInfo>(create);
  static DeviceInfo? _defaultInstance;

  DeviceInfo_DeviceInfo whichDeviceInfo() =>
      _DeviceInfo_DeviceInfoByTag[$_whichOneof(0)]!;
  void clearDeviceInfo() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  Platform get platform => $_getN(0);
  @$pb.TagNumber(1)
  set platform(Platform v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasPlatform() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlatform() => clearField(1);

  @$pb.TagNumber(11)
  AndroidDeviceInfo get androidDeviceInfo => $_getN(1);
  @$pb.TagNumber(11)
  set androidDeviceInfo(AndroidDeviceInfo v) {
    setField(11, v);
  }

  @$pb.TagNumber(11)
  $core.bool hasAndroidDeviceInfo() => $_has(1);
  @$pb.TagNumber(11)
  void clearAndroidDeviceInfo() => clearField(11);
  @$pb.TagNumber(11)
  AndroidDeviceInfo ensureAndroidDeviceInfo() => $_ensure(1);

  @$pb.TagNumber(12)
  IosDeviceInfo get iosDeviceInfo => $_getN(2);
  @$pb.TagNumber(12)
  set iosDeviceInfo(IosDeviceInfo v) {
    setField(12, v);
  }

  @$pb.TagNumber(12)
  $core.bool hasIosDeviceInfo() => $_has(2);
  @$pb.TagNumber(12)
  void clearIosDeviceInfo() => clearField(12);
  @$pb.TagNumber(12)
  IosDeviceInfo ensureIosDeviceInfo() => $_ensure(2);

  @$pb.TagNumber(13)
  LinuxDeviceInfo get linuxDeviceInfo => $_getN(3);
  @$pb.TagNumber(13)
  set linuxDeviceInfo(LinuxDeviceInfo v) {
    setField(13, v);
  }

  @$pb.TagNumber(13)
  $core.bool hasLinuxDeviceInfo() => $_has(3);
  @$pb.TagNumber(13)
  void clearLinuxDeviceInfo() => clearField(13);
  @$pb.TagNumber(13)
  LinuxDeviceInfo ensureLinuxDeviceInfo() => $_ensure(3);

  @$pb.TagNumber(14)
  MacOSDeviceInfo get macOSDeviceInfo => $_getN(4);
  @$pb.TagNumber(14)
  set macOSDeviceInfo(MacOSDeviceInfo v) {
    setField(14, v);
  }

  @$pb.TagNumber(14)
  $core.bool hasMacOSDeviceInfo() => $_has(4);
  @$pb.TagNumber(14)
  void clearMacOSDeviceInfo() => clearField(14);
  @$pb.TagNumber(14)
  MacOSDeviceInfo ensureMacOSDeviceInfo() => $_ensure(4);

  @$pb.TagNumber(15)
  WindowsDeviceInfo get windowsDeviceInfo => $_getN(5);
  @$pb.TagNumber(15)
  set windowsDeviceInfo(WindowsDeviceInfo v) {
    setField(15, v);
  }

  @$pb.TagNumber(15)
  $core.bool hasWindowsDeviceInfo() => $_has(5);
  @$pb.TagNumber(15)
  void clearWindowsDeviceInfo() => clearField(15);
  @$pb.TagNumber(15)
  WindowsDeviceInfo ensureWindowsDeviceInfo() => $_ensure(5);

  @$pb.TagNumber(16)
  WebBrowserInfo get webBrowserInfo => $_getN(6);
  @$pb.TagNumber(16)
  set webBrowserInfo(WebBrowserInfo v) {
    setField(16, v);
  }

  @$pb.TagNumber(16)
  $core.bool hasWebBrowserInfo() => $_has(6);
  @$pb.TagNumber(16)
  void clearWebBrowserInfo() => clearField(16);
  @$pb.TagNumber(16)
  WebBrowserInfo ensureWebBrowserInfo() => $_ensure(6);
}

class PackageInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'PackageInfo',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'appName',
        protoName: 'appName')
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'packageName',
        protoName: 'packageName')
    ..aOS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'version')
    ..aOS(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'buildNumber',
        protoName: 'buildNumber')
    ..aOS(
        5,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'buildSignature',
        protoName: 'buildSignature')
    ..aOS(
        6,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'installSource',
        protoName: 'installSource')
    ..hasRequiredFields = false;

  PackageInfo._() : super();
  factory PackageInfo({
    $core.String? appName,
    $core.String? packageName,
    $core.String? version,
    $core.String? buildNumber,
    $core.String? buildSignature,
    $core.String? installSource,
  }) {
    final _result = create();
    if (appName != null) {
      _result.appName = appName;
    }
    if (packageName != null) {
      _result.packageName = packageName;
    }
    if (version != null) {
      _result.version = version;
    }
    if (buildNumber != null) {
      _result.buildNumber = buildNumber;
    }
    if (buildSignature != null) {
      _result.buildSignature = buildSignature;
    }
    if (installSource != null) {
      _result.installSource = installSource;
    }
    return _result;
  }
  factory PackageInfo.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory PackageInfo.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  PackageInfo clone() => PackageInfo()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  PackageInfo copyWith(void Function(PackageInfo) updates) =>
      super.copyWith((message) => updates(message as PackageInfo))
          as PackageInfo; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PackageInfo create() => PackageInfo._();
  PackageInfo createEmptyInstance() => create();
  static $pb.PbList<PackageInfo> createRepeated() => $pb.PbList<PackageInfo>();
  @$core.pragma('dart2js:noInline')
  static PackageInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PackageInfo>(create);
  static PackageInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get appName => $_getSZ(0);
  @$pb.TagNumber(1)
  set appName($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasAppName() => $_has(0);
  @$pb.TagNumber(1)
  void clearAppName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get packageName => $_getSZ(1);
  @$pb.TagNumber(2)
  set packageName($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasPackageName() => $_has(1);
  @$pb.TagNumber(2)
  void clearPackageName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get version => $_getSZ(2);
  @$pb.TagNumber(3)
  set version($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearVersion() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get buildNumber => $_getSZ(3);
  @$pb.TagNumber(4)
  set buildNumber($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasBuildNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearBuildNumber() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get buildSignature => $_getSZ(4);
  @$pb.TagNumber(5)
  set buildSignature($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasBuildSignature() => $_has(4);
  @$pb.TagNumber(5)
  void clearBuildSignature() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get installSource => $_getSZ(5);
  @$pb.TagNumber(6)
  set installSource($core.String v) {
    $_setString(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasInstallSource() => $_has(5);
  @$pb.TagNumber(6)
  void clearInstallSource() => clearField(6);
}

class AndroidBuildVersion extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'AndroidBuildVersion',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'baseOS',
        protoName: 'baseOS')
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'codename')
    ..aOS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'incremental')
    ..a<$core.int>(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'previewSdkInt',
        $pb.PbFieldType.OU3,
        protoName: 'previewSdkInt')
    ..aOS(
        5,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'release')
    ..a<$core.int>(
        6,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'sdkInt',
        $pb.PbFieldType.OU3,
        protoName: 'sdkInt')
    ..aOS(
        7,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'securityPatch',
        protoName: 'securityPatch')
    ..hasRequiredFields = false;

  AndroidBuildVersion._() : super();
  factory AndroidBuildVersion({
    $core.String? baseOS,
    $core.String? codename,
    $core.String? incremental,
    $core.int? previewSdkInt,
    $core.String? release,
    $core.int? sdkInt,
    $core.String? securityPatch,
  }) {
    final _result = create();
    if (baseOS != null) {
      _result.baseOS = baseOS;
    }
    if (codename != null) {
      _result.codename = codename;
    }
    if (incremental != null) {
      _result.incremental = incremental;
    }
    if (previewSdkInt != null) {
      _result.previewSdkInt = previewSdkInt;
    }
    if (release != null) {
      _result.release = release;
    }
    if (sdkInt != null) {
      _result.sdkInt = sdkInt;
    }
    if (securityPatch != null) {
      _result.securityPatch = securityPatch;
    }
    return _result;
  }
  factory AndroidBuildVersion.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory AndroidBuildVersion.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  AndroidBuildVersion clone() => AndroidBuildVersion()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  AndroidBuildVersion copyWith(void Function(AndroidBuildVersion) updates) =>
      super.copyWith((message) => updates(message as AndroidBuildVersion))
          as AndroidBuildVersion; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AndroidBuildVersion create() => AndroidBuildVersion._();
  AndroidBuildVersion createEmptyInstance() => create();
  static $pb.PbList<AndroidBuildVersion> createRepeated() =>
      $pb.PbList<AndroidBuildVersion>();
  @$core.pragma('dart2js:noInline')
  static AndroidBuildVersion getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AndroidBuildVersion>(create);
  static AndroidBuildVersion? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get baseOS => $_getSZ(0);
  @$pb.TagNumber(1)
  set baseOS($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasBaseOS() => $_has(0);
  @$pb.TagNumber(1)
  void clearBaseOS() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get codename => $_getSZ(1);
  @$pb.TagNumber(2)
  set codename($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasCodename() => $_has(1);
  @$pb.TagNumber(2)
  void clearCodename() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get incremental => $_getSZ(2);
  @$pb.TagNumber(3)
  set incremental($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasIncremental() => $_has(2);
  @$pb.TagNumber(3)
  void clearIncremental() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get previewSdkInt => $_getIZ(3);
  @$pb.TagNumber(4)
  set previewSdkInt($core.int v) {
    $_setUnsignedInt32(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasPreviewSdkInt() => $_has(3);
  @$pb.TagNumber(4)
  void clearPreviewSdkInt() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get release => $_getSZ(4);
  @$pb.TagNumber(5)
  set release($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasRelease() => $_has(4);
  @$pb.TagNumber(5)
  void clearRelease() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get sdkInt => $_getIZ(5);
  @$pb.TagNumber(6)
  set sdkInt($core.int v) {
    $_setUnsignedInt32(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasSdkInt() => $_has(5);
  @$pb.TagNumber(6)
  void clearSdkInt() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get securityPatch => $_getSZ(6);
  @$pb.TagNumber(7)
  set securityPatch($core.String v) {
    $_setString(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasSecurityPatch() => $_has(6);
  @$pb.TagNumber(7)
  void clearSecurityPatch() => clearField(7);
}

class AndroidDeviceInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'AndroidDeviceInfo',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..aOM<AndroidBuildVersion>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'version',
        subBuilder: AndroidBuildVersion.create)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'board')
    ..aOS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'bootloader')
    ..aOS(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'brand')
    ..aOS(
        5,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'device')
    ..aOS(
        6,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'display')
    ..aOS(
        7,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'fingerprint')
    ..aOS(
        8,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'hardware')
    ..aOS(
        9,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'host')
    ..aOS(
        10,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'id')
    ..aOS(
        11,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'manufacturer')
    ..aOS(
        12,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'model')
    ..aOS(
        13,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'product')
    ..pPS(
        14,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'supported32BitAbis',
        protoName: 'supported32BitAbis')
    ..pPS(
        15,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'supported64BitAbis',
        protoName: 'supported64BitAbis')
    ..pPS(
        16,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'supportedAbis',
        protoName: 'supportedAbis')
    ..aOS(
        17,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'tags')
    ..aOS(
        18,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'type')
    ..aOB(
        19,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'isPhysicalDevice',
        protoName: 'isPhysicalDevice')
    ..aOS(
        20,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'androidId',
        protoName: 'androidId')
    ..pPS(
        21,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'systemFeatures',
        protoName: 'systemFeatures')
    ..hasRequiredFields = false;

  AndroidDeviceInfo._() : super();
  factory AndroidDeviceInfo({
    AndroidBuildVersion? version,
    $core.String? board,
    $core.String? bootloader,
    $core.String? brand,
    $core.String? device,
    $core.String? display,
    $core.String? fingerprint,
    $core.String? hardware,
    $core.String? host,
    $core.String? id,
    $core.String? manufacturer,
    $core.String? model,
    $core.String? product,
    $core.Iterable<$core.String>? supported32BitAbis,
    $core.Iterable<$core.String>? supported64BitAbis,
    $core.Iterable<$core.String>? supportedAbis,
    $core.String? tags,
    $core.String? type,
    $core.bool? isPhysicalDevice,
    $core.String? androidId,
    $core.Iterable<$core.String>? systemFeatures,
  }) {
    final _result = create();
    if (version != null) {
      _result.version = version;
    }
    if (board != null) {
      _result.board = board;
    }
    if (bootloader != null) {
      _result.bootloader = bootloader;
    }
    if (brand != null) {
      _result.brand = brand;
    }
    if (device != null) {
      _result.device = device;
    }
    if (display != null) {
      _result.display = display;
    }
    if (fingerprint != null) {
      _result.fingerprint = fingerprint;
    }
    if (hardware != null) {
      _result.hardware = hardware;
    }
    if (host != null) {
      _result.host = host;
    }
    if (id != null) {
      _result.id = id;
    }
    if (manufacturer != null) {
      _result.manufacturer = manufacturer;
    }
    if (model != null) {
      _result.model = model;
    }
    if (product != null) {
      _result.product = product;
    }
    if (supported32BitAbis != null) {
      _result.supported32BitAbis.addAll(supported32BitAbis);
    }
    if (supported64BitAbis != null) {
      _result.supported64BitAbis.addAll(supported64BitAbis);
    }
    if (supportedAbis != null) {
      _result.supportedAbis.addAll(supportedAbis);
    }
    if (tags != null) {
      _result.tags = tags;
    }
    if (type != null) {
      _result.type = type;
    }
    if (isPhysicalDevice != null) {
      _result.isPhysicalDevice = isPhysicalDevice;
    }
    if (androidId != null) {
      _result.androidId = androidId;
    }
    if (systemFeatures != null) {
      _result.systemFeatures.addAll(systemFeatures);
    }
    return _result;
  }
  factory AndroidDeviceInfo.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory AndroidDeviceInfo.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  AndroidDeviceInfo clone() => AndroidDeviceInfo()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  AndroidDeviceInfo copyWith(void Function(AndroidDeviceInfo) updates) =>
      super.copyWith((message) => updates(message as AndroidDeviceInfo))
          as AndroidDeviceInfo; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AndroidDeviceInfo create() => AndroidDeviceInfo._();
  AndroidDeviceInfo createEmptyInstance() => create();
  static $pb.PbList<AndroidDeviceInfo> createRepeated() =>
      $pb.PbList<AndroidDeviceInfo>();
  @$core.pragma('dart2js:noInline')
  static AndroidDeviceInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AndroidDeviceInfo>(create);
  static AndroidDeviceInfo? _defaultInstance;

  @$pb.TagNumber(1)
  AndroidBuildVersion get version => $_getN(0);
  @$pb.TagNumber(1)
  set version(AndroidBuildVersion v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => clearField(1);
  @$pb.TagNumber(1)
  AndroidBuildVersion ensureVersion() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get board => $_getSZ(1);
  @$pb.TagNumber(2)
  set board($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasBoard() => $_has(1);
  @$pb.TagNumber(2)
  void clearBoard() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get bootloader => $_getSZ(2);
  @$pb.TagNumber(3)
  set bootloader($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasBootloader() => $_has(2);
  @$pb.TagNumber(3)
  void clearBootloader() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get brand => $_getSZ(3);
  @$pb.TagNumber(4)
  set brand($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasBrand() => $_has(3);
  @$pb.TagNumber(4)
  void clearBrand() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get device => $_getSZ(4);
  @$pb.TagNumber(5)
  set device($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasDevice() => $_has(4);
  @$pb.TagNumber(5)
  void clearDevice() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get display => $_getSZ(5);
  @$pb.TagNumber(6)
  set display($core.String v) {
    $_setString(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasDisplay() => $_has(5);
  @$pb.TagNumber(6)
  void clearDisplay() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get fingerprint => $_getSZ(6);
  @$pb.TagNumber(7)
  set fingerprint($core.String v) {
    $_setString(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasFingerprint() => $_has(6);
  @$pb.TagNumber(7)
  void clearFingerprint() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get hardware => $_getSZ(7);
  @$pb.TagNumber(8)
  set hardware($core.String v) {
    $_setString(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasHardware() => $_has(7);
  @$pb.TagNumber(8)
  void clearHardware() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get host => $_getSZ(8);
  @$pb.TagNumber(9)
  set host($core.String v) {
    $_setString(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasHost() => $_has(8);
  @$pb.TagNumber(9)
  void clearHost() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get id => $_getSZ(9);
  @$pb.TagNumber(10)
  set id($core.String v) {
    $_setString(9, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasId() => $_has(9);
  @$pb.TagNumber(10)
  void clearId() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get manufacturer => $_getSZ(10);
  @$pb.TagNumber(11)
  set manufacturer($core.String v) {
    $_setString(10, v);
  }

  @$pb.TagNumber(11)
  $core.bool hasManufacturer() => $_has(10);
  @$pb.TagNumber(11)
  void clearManufacturer() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get model => $_getSZ(11);
  @$pb.TagNumber(12)
  set model($core.String v) {
    $_setString(11, v);
  }

  @$pb.TagNumber(12)
  $core.bool hasModel() => $_has(11);
  @$pb.TagNumber(12)
  void clearModel() => clearField(12);

  @$pb.TagNumber(13)
  $core.String get product => $_getSZ(12);
  @$pb.TagNumber(13)
  set product($core.String v) {
    $_setString(12, v);
  }

  @$pb.TagNumber(13)
  $core.bool hasProduct() => $_has(12);
  @$pb.TagNumber(13)
  void clearProduct() => clearField(13);

  @$pb.TagNumber(14)
  $core.List<$core.String> get supported32BitAbis => $_getList(13);

  @$pb.TagNumber(15)
  $core.List<$core.String> get supported64BitAbis => $_getList(14);

  @$pb.TagNumber(16)
  $core.List<$core.String> get supportedAbis => $_getList(15);

  @$pb.TagNumber(17)
  $core.String get tags => $_getSZ(16);
  @$pb.TagNumber(17)
  set tags($core.String v) {
    $_setString(16, v);
  }

  @$pb.TagNumber(17)
  $core.bool hasTags() => $_has(16);
  @$pb.TagNumber(17)
  void clearTags() => clearField(17);

  @$pb.TagNumber(18)
  $core.String get type => $_getSZ(17);
  @$pb.TagNumber(18)
  set type($core.String v) {
    $_setString(17, v);
  }

  @$pb.TagNumber(18)
  $core.bool hasType() => $_has(17);
  @$pb.TagNumber(18)
  void clearType() => clearField(18);

  @$pb.TagNumber(19)
  $core.bool get isPhysicalDevice => $_getBF(18);
  @$pb.TagNumber(19)
  set isPhysicalDevice($core.bool v) {
    $_setBool(18, v);
  }

  @$pb.TagNumber(19)
  $core.bool hasIsPhysicalDevice() => $_has(18);
  @$pb.TagNumber(19)
  void clearIsPhysicalDevice() => clearField(19);

  @$pb.TagNumber(20)
  $core.String get androidId => $_getSZ(19);
  @$pb.TagNumber(20)
  set androidId($core.String v) {
    $_setString(19, v);
  }

  @$pb.TagNumber(20)
  $core.bool hasAndroidId() => $_has(19);
  @$pb.TagNumber(20)
  void clearAndroidId() => clearField(20);

  @$pb.TagNumber(21)
  $core.List<$core.String> get systemFeatures => $_getList(20);
}

class IosUtsname extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'IosUtsname',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'sysname')
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'nodename')
    ..aOS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'release')
    ..aOS(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'version')
    ..aOS(
        5,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'machine')
    ..hasRequiredFields = false;

  IosUtsname._() : super();
  factory IosUtsname({
    $core.String? sysname,
    $core.String? nodename,
    $core.String? release,
    $core.String? version,
    $core.String? machine,
  }) {
    final _result = create();
    if (sysname != null) {
      _result.sysname = sysname;
    }
    if (nodename != null) {
      _result.nodename = nodename;
    }
    if (release != null) {
      _result.release = release;
    }
    if (version != null) {
      _result.version = version;
    }
    if (machine != null) {
      _result.machine = machine;
    }
    return _result;
  }
  factory IosUtsname.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory IosUtsname.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  IosUtsname clone() => IosUtsname()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  IosUtsname copyWith(void Function(IosUtsname) updates) =>
      super.copyWith((message) => updates(message as IosUtsname))
          as IosUtsname; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static IosUtsname create() => IosUtsname._();
  IosUtsname createEmptyInstance() => create();
  static $pb.PbList<IosUtsname> createRepeated() => $pb.PbList<IosUtsname>();
  @$core.pragma('dart2js:noInline')
  static IosUtsname getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IosUtsname>(create);
  static IosUtsname? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sysname => $_getSZ(0);
  @$pb.TagNumber(1)
  set sysname($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasSysname() => $_has(0);
  @$pb.TagNumber(1)
  void clearSysname() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get nodename => $_getSZ(1);
  @$pb.TagNumber(2)
  set nodename($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasNodename() => $_has(1);
  @$pb.TagNumber(2)
  void clearNodename() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get release => $_getSZ(2);
  @$pb.TagNumber(3)
  set release($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasRelease() => $_has(2);
  @$pb.TagNumber(3)
  void clearRelease() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get version => $_getSZ(3);
  @$pb.TagNumber(4)
  set version($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearVersion() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get machine => $_getSZ(4);
  @$pb.TagNumber(5)
  set machine($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasMachine() => $_has(4);
  @$pb.TagNumber(5)
  void clearMachine() => clearField(5);
}

class IosDeviceInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'IosDeviceInfo',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'name')
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'systemName',
        protoName: 'systemName')
    ..aOS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'systemVersion',
        protoName: 'systemVersion')
    ..aOS(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'model')
    ..aOS(
        5,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'localizedModel',
        protoName: 'localizedModel')
    ..aOS(
        6,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'identifierForVendor',
        protoName: 'identifierForVendor')
    ..aOB(
        7,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'isPhysicalDevice',
        protoName: 'isPhysicalDevice')
    ..aOM<IosUtsname>(
        8,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'utsname',
        subBuilder: IosUtsname.create)
    ..hasRequiredFields = false;

  IosDeviceInfo._() : super();
  factory IosDeviceInfo({
    $core.String? name,
    $core.String? systemName,
    $core.String? systemVersion,
    $core.String? model,
    $core.String? localizedModel,
    $core.String? identifierForVendor,
    $core.bool? isPhysicalDevice,
    IosUtsname? utsname,
  }) {
    final _result = create();
    if (name != null) {
      _result.name = name;
    }
    if (systemName != null) {
      _result.systemName = systemName;
    }
    if (systemVersion != null) {
      _result.systemVersion = systemVersion;
    }
    if (model != null) {
      _result.model = model;
    }
    if (localizedModel != null) {
      _result.localizedModel = localizedModel;
    }
    if (identifierForVendor != null) {
      _result.identifierForVendor = identifierForVendor;
    }
    if (isPhysicalDevice != null) {
      _result.isPhysicalDevice = isPhysicalDevice;
    }
    if (utsname != null) {
      _result.utsname = utsname;
    }
    return _result;
  }
  factory IosDeviceInfo.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory IosDeviceInfo.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  IosDeviceInfo clone() => IosDeviceInfo()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  IosDeviceInfo copyWith(void Function(IosDeviceInfo) updates) =>
      super.copyWith((message) => updates(message as IosDeviceInfo))
          as IosDeviceInfo; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static IosDeviceInfo create() => IosDeviceInfo._();
  IosDeviceInfo createEmptyInstance() => create();
  static $pb.PbList<IosDeviceInfo> createRepeated() =>
      $pb.PbList<IosDeviceInfo>();
  @$core.pragma('dart2js:noInline')
  static IosDeviceInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IosDeviceInfo>(create);
  static IosDeviceInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get systemName => $_getSZ(1);
  @$pb.TagNumber(2)
  set systemName($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasSystemName() => $_has(1);
  @$pb.TagNumber(2)
  void clearSystemName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get systemVersion => $_getSZ(2);
  @$pb.TagNumber(3)
  set systemVersion($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasSystemVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearSystemVersion() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get model => $_getSZ(3);
  @$pb.TagNumber(4)
  set model($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasModel() => $_has(3);
  @$pb.TagNumber(4)
  void clearModel() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get localizedModel => $_getSZ(4);
  @$pb.TagNumber(5)
  set localizedModel($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasLocalizedModel() => $_has(4);
  @$pb.TagNumber(5)
  void clearLocalizedModel() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get identifierForVendor => $_getSZ(5);
  @$pb.TagNumber(6)
  set identifierForVendor($core.String v) {
    $_setString(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasIdentifierForVendor() => $_has(5);
  @$pb.TagNumber(6)
  void clearIdentifierForVendor() => clearField(6);

  @$pb.TagNumber(7)
  $core.bool get isPhysicalDevice => $_getBF(6);
  @$pb.TagNumber(7)
  set isPhysicalDevice($core.bool v) {
    $_setBool(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasIsPhysicalDevice() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsPhysicalDevice() => clearField(7);

  @$pb.TagNumber(8)
  IosUtsname get utsname => $_getN(7);
  @$pb.TagNumber(8)
  set utsname(IosUtsname v) {
    setField(8, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasUtsname() => $_has(7);
  @$pb.TagNumber(8)
  void clearUtsname() => clearField(8);
  @$pb.TagNumber(8)
  IosUtsname ensureUtsname() => $_ensure(7);
}

class LinuxDeviceInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'LinuxDeviceInfo',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'name')
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'version')
    ..aOS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'id')
    ..pPS(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'idLike',
        protoName: 'idLike')
    ..aOS(
        5,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'versionCodename',
        protoName: 'versionCodename')
    ..aOS(
        6,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'versionId',
        protoName: 'versionId')
    ..aOS(
        7,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'prettyName',
        protoName: 'prettyName')
    ..aOS(
        8,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'buildId',
        protoName: 'buildId')
    ..aOS(
        9,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'variant')
    ..aOS(
        10,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'variantId',
        protoName: 'variantId')
    ..aOS(
        11,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'machineId',
        protoName: 'machineId')
    ..hasRequiredFields = false;

  LinuxDeviceInfo._() : super();
  factory LinuxDeviceInfo({
    $core.String? name,
    $core.String? version,
    $core.String? id,
    $core.Iterable<$core.String>? idLike,
    $core.String? versionCodename,
    $core.String? versionId,
    $core.String? prettyName,
    $core.String? buildId,
    $core.String? variant,
    $core.String? variantId,
    $core.String? machineId,
  }) {
    final _result = create();
    if (name != null) {
      _result.name = name;
    }
    if (version != null) {
      _result.version = version;
    }
    if (id != null) {
      _result.id = id;
    }
    if (idLike != null) {
      _result.idLike.addAll(idLike);
    }
    if (versionCodename != null) {
      _result.versionCodename = versionCodename;
    }
    if (versionId != null) {
      _result.versionId = versionId;
    }
    if (prettyName != null) {
      _result.prettyName = prettyName;
    }
    if (buildId != null) {
      _result.buildId = buildId;
    }
    if (variant != null) {
      _result.variant = variant;
    }
    if (variantId != null) {
      _result.variantId = variantId;
    }
    if (machineId != null) {
      _result.machineId = machineId;
    }
    return _result;
  }
  factory LinuxDeviceInfo.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory LinuxDeviceInfo.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  LinuxDeviceInfo clone() => LinuxDeviceInfo()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  LinuxDeviceInfo copyWith(void Function(LinuxDeviceInfo) updates) =>
      super.copyWith((message) => updates(message as LinuxDeviceInfo))
          as LinuxDeviceInfo; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static LinuxDeviceInfo create() => LinuxDeviceInfo._();
  LinuxDeviceInfo createEmptyInstance() => create();
  static $pb.PbList<LinuxDeviceInfo> createRepeated() =>
      $pb.PbList<LinuxDeviceInfo>();
  @$core.pragma('dart2js:noInline')
  static LinuxDeviceInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LinuxDeviceInfo>(create);
  static LinuxDeviceInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get version => $_getSZ(1);
  @$pb.TagNumber(2)
  set version($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get id => $_getSZ(2);
  @$pb.TagNumber(3)
  set id($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.String> get idLike => $_getList(3);

  @$pb.TagNumber(5)
  $core.String get versionCodename => $_getSZ(4);
  @$pb.TagNumber(5)
  set versionCodename($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasVersionCodename() => $_has(4);
  @$pb.TagNumber(5)
  void clearVersionCodename() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get versionId => $_getSZ(5);
  @$pb.TagNumber(6)
  set versionId($core.String v) {
    $_setString(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasVersionId() => $_has(5);
  @$pb.TagNumber(6)
  void clearVersionId() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get prettyName => $_getSZ(6);
  @$pb.TagNumber(7)
  set prettyName($core.String v) {
    $_setString(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasPrettyName() => $_has(6);
  @$pb.TagNumber(7)
  void clearPrettyName() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get buildId => $_getSZ(7);
  @$pb.TagNumber(8)
  set buildId($core.String v) {
    $_setString(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasBuildId() => $_has(7);
  @$pb.TagNumber(8)
  void clearBuildId() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get variant => $_getSZ(8);
  @$pb.TagNumber(9)
  set variant($core.String v) {
    $_setString(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasVariant() => $_has(8);
  @$pb.TagNumber(9)
  void clearVariant() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get variantId => $_getSZ(9);
  @$pb.TagNumber(10)
  set variantId($core.String v) {
    $_setString(9, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasVariantId() => $_has(9);
  @$pb.TagNumber(10)
  void clearVariantId() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get machineId => $_getSZ(10);
  @$pb.TagNumber(11)
  set machineId($core.String v) {
    $_setString(10, v);
  }

  @$pb.TagNumber(11)
  $core.bool hasMachineId() => $_has(10);
  @$pb.TagNumber(11)
  void clearMachineId() => clearField(11);
}

class MacOSDeviceInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'MacOSDeviceInfo',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'computerName',
        protoName: 'computerName')
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'hostName',
        protoName: 'hostName')
    ..aOS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'arch')
    ..aOS(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'model')
    ..aOS(
        5,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'kernelVersion',
        protoName: 'kernelVersion')
    ..aOS(
        6,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'osRelease',
        protoName: 'osRelease')
    ..a<$core.int>(
        7,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'activeCPUs',
        $pb.PbFieldType.OU3,
        protoName: 'activeCPUs')
    ..a<$fixnum.Int64>(
        8,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'memorySize',
        $pb.PbFieldType.OU6,
        protoName: 'memorySize',
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        9,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'cpuFrequency',
        $pb.PbFieldType.OU6,
        protoName: 'cpuFrequency',
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  MacOSDeviceInfo._() : super();
  factory MacOSDeviceInfo({
    $core.String? computerName,
    $core.String? hostName,
    $core.String? arch,
    $core.String? model,
    $core.String? kernelVersion,
    $core.String? osRelease,
    $core.int? activeCPUs,
    $fixnum.Int64? memorySize,
    $fixnum.Int64? cpuFrequency,
  }) {
    final _result = create();
    if (computerName != null) {
      _result.computerName = computerName;
    }
    if (hostName != null) {
      _result.hostName = hostName;
    }
    if (arch != null) {
      _result.arch = arch;
    }
    if (model != null) {
      _result.model = model;
    }
    if (kernelVersion != null) {
      _result.kernelVersion = kernelVersion;
    }
    if (osRelease != null) {
      _result.osRelease = osRelease;
    }
    if (activeCPUs != null) {
      _result.activeCPUs = activeCPUs;
    }
    if (memorySize != null) {
      _result.memorySize = memorySize;
    }
    if (cpuFrequency != null) {
      _result.cpuFrequency = cpuFrequency;
    }
    return _result;
  }
  factory MacOSDeviceInfo.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory MacOSDeviceInfo.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  MacOSDeviceInfo clone() => MacOSDeviceInfo()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  MacOSDeviceInfo copyWith(void Function(MacOSDeviceInfo) updates) =>
      super.copyWith((message) => updates(message as MacOSDeviceInfo))
          as MacOSDeviceInfo; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MacOSDeviceInfo create() => MacOSDeviceInfo._();
  MacOSDeviceInfo createEmptyInstance() => create();
  static $pb.PbList<MacOSDeviceInfo> createRepeated() =>
      $pb.PbList<MacOSDeviceInfo>();
  @$core.pragma('dart2js:noInline')
  static MacOSDeviceInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MacOSDeviceInfo>(create);
  static MacOSDeviceInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get computerName => $_getSZ(0);
  @$pb.TagNumber(1)
  set computerName($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasComputerName() => $_has(0);
  @$pb.TagNumber(1)
  void clearComputerName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get hostName => $_getSZ(1);
  @$pb.TagNumber(2)
  set hostName($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasHostName() => $_has(1);
  @$pb.TagNumber(2)
  void clearHostName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get arch => $_getSZ(2);
  @$pb.TagNumber(3)
  set arch($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasArch() => $_has(2);
  @$pb.TagNumber(3)
  void clearArch() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get model => $_getSZ(3);
  @$pb.TagNumber(4)
  set model($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasModel() => $_has(3);
  @$pb.TagNumber(4)
  void clearModel() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get kernelVersion => $_getSZ(4);
  @$pb.TagNumber(5)
  set kernelVersion($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasKernelVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearKernelVersion() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get osRelease => $_getSZ(5);
  @$pb.TagNumber(6)
  set osRelease($core.String v) {
    $_setString(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasOsRelease() => $_has(5);
  @$pb.TagNumber(6)
  void clearOsRelease() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get activeCPUs => $_getIZ(6);
  @$pb.TagNumber(7)
  set activeCPUs($core.int v) {
    $_setUnsignedInt32(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasActiveCPUs() => $_has(6);
  @$pb.TagNumber(7)
  void clearActiveCPUs() => clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get memorySize => $_getI64(7);
  @$pb.TagNumber(8)
  set memorySize($fixnum.Int64 v) {
    $_setInt64(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasMemorySize() => $_has(7);
  @$pb.TagNumber(8)
  void clearMemorySize() => clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get cpuFrequency => $_getI64(8);
  @$pb.TagNumber(9)
  set cpuFrequency($fixnum.Int64 v) {
    $_setInt64(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasCpuFrequency() => $_has(8);
  @$pb.TagNumber(9)
  void clearCpuFrequency() => clearField(9);
}

class WindowsDeviceInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'WindowsDeviceInfo',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'computerName',
        protoName: 'computerName')
    ..a<$core.int>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'numberOfCores',
        $pb.PbFieldType.OU3,
        protoName: 'numberOfCores')
    ..a<$core.int>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'systemMemoryInMegabytes',
        $pb.PbFieldType.OU3,
        protoName: 'systemMemoryInMegabytes')
    ..hasRequiredFields = false;

  WindowsDeviceInfo._() : super();
  factory WindowsDeviceInfo({
    $core.String? computerName,
    $core.int? numberOfCores,
    $core.int? systemMemoryInMegabytes,
  }) {
    final _result = create();
    if (computerName != null) {
      _result.computerName = computerName;
    }
    if (numberOfCores != null) {
      _result.numberOfCores = numberOfCores;
    }
    if (systemMemoryInMegabytes != null) {
      _result.systemMemoryInMegabytes = systemMemoryInMegabytes;
    }
    return _result;
  }
  factory WindowsDeviceInfo.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory WindowsDeviceInfo.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  WindowsDeviceInfo clone() => WindowsDeviceInfo()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  WindowsDeviceInfo copyWith(void Function(WindowsDeviceInfo) updates) =>
      super.copyWith((message) => updates(message as WindowsDeviceInfo))
          as WindowsDeviceInfo; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static WindowsDeviceInfo create() => WindowsDeviceInfo._();
  WindowsDeviceInfo createEmptyInstance() => create();
  static $pb.PbList<WindowsDeviceInfo> createRepeated() =>
      $pb.PbList<WindowsDeviceInfo>();
  @$core.pragma('dart2js:noInline')
  static WindowsDeviceInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WindowsDeviceInfo>(create);
  static WindowsDeviceInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get computerName => $_getSZ(0);
  @$pb.TagNumber(1)
  set computerName($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasComputerName() => $_has(0);
  @$pb.TagNumber(1)
  void clearComputerName() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get numberOfCores => $_getIZ(1);
  @$pb.TagNumber(2)
  set numberOfCores($core.int v) {
    $_setUnsignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasNumberOfCores() => $_has(1);
  @$pb.TagNumber(2)
  void clearNumberOfCores() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get systemMemoryInMegabytes => $_getIZ(2);
  @$pb.TagNumber(3)
  set systemMemoryInMegabytes($core.int v) {
    $_setUnsignedInt32(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasSystemMemoryInMegabytes() => $_has(2);
  @$pb.TagNumber(3)
  void clearSystemMemoryInMegabytes() => clearField(3);
}

class WebBrowserInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'WebBrowserInfo',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..e<BrowserName>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'browserName',
        $pb.PbFieldType.OE,
        protoName: 'browserName',
        defaultOrMaker: BrowserName.unknown,
        valueOf: BrowserName.valueOf,
        enumValues: BrowserName.values)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'appCodeName',
        protoName: 'appCodeName')
    ..aOS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'appName',
        protoName: 'appName')
    ..aOS(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'appVersion',
        protoName: 'appVersion')
    ..a<$fixnum.Int64>(
        5,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'deviceMemory',
        $pb.PbFieldType.OU6,
        protoName: 'deviceMemory',
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(
        6,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'language')
    ..pPS(
        7,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'languages')
    ..aOS(
        8,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'platform')
    ..aOS(
        9,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'product')
    ..aOS(
        10,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'productSub',
        protoName: 'productSub')
    ..aOS(
        11,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'userAgent',
        protoName: 'userAgent')
    ..aOS(
        12,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'vendor')
    ..aOS(
        13,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'vendorSub',
        protoName: 'vendorSub')
    ..a<$core.int>(
        14,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'hardwareConcurrency',
        $pb.PbFieldType.OU3,
        protoName: 'hardwareConcurrency')
    ..a<$core.int>(
        15,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'maxTouchPoints',
        $pb.PbFieldType.OU3,
        protoName: 'maxTouchPoints')
    ..hasRequiredFields = false;

  WebBrowserInfo._() : super();
  factory WebBrowserInfo({
    BrowserName? browserName,
    $core.String? appCodeName,
    $core.String? appName,
    $core.String? appVersion,
    $fixnum.Int64? deviceMemory,
    $core.String? language,
    $core.Iterable<$core.String>? languages,
    $core.String? platform,
    $core.String? product,
    $core.String? productSub,
    $core.String? userAgent,
    $core.String? vendor,
    $core.String? vendorSub,
    $core.int? hardwareConcurrency,
    $core.int? maxTouchPoints,
  }) {
    final _result = create();
    if (browserName != null) {
      _result.browserName = browserName;
    }
    if (appCodeName != null) {
      _result.appCodeName = appCodeName;
    }
    if (appName != null) {
      _result.appName = appName;
    }
    if (appVersion != null) {
      _result.appVersion = appVersion;
    }
    if (deviceMemory != null) {
      _result.deviceMemory = deviceMemory;
    }
    if (language != null) {
      _result.language = language;
    }
    if (languages != null) {
      _result.languages.addAll(languages);
    }
    if (platform != null) {
      _result.platform = platform;
    }
    if (product != null) {
      _result.product = product;
    }
    if (productSub != null) {
      _result.productSub = productSub;
    }
    if (userAgent != null) {
      _result.userAgent = userAgent;
    }
    if (vendor != null) {
      _result.vendor = vendor;
    }
    if (vendorSub != null) {
      _result.vendorSub = vendorSub;
    }
    if (hardwareConcurrency != null) {
      _result.hardwareConcurrency = hardwareConcurrency;
    }
    if (maxTouchPoints != null) {
      _result.maxTouchPoints = maxTouchPoints;
    }
    return _result;
  }
  factory WebBrowserInfo.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory WebBrowserInfo.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  WebBrowserInfo clone() => WebBrowserInfo()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  WebBrowserInfo copyWith(void Function(WebBrowserInfo) updates) =>
      super.copyWith((message) => updates(message as WebBrowserInfo))
          as WebBrowserInfo; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static WebBrowserInfo create() => WebBrowserInfo._();
  WebBrowserInfo createEmptyInstance() => create();
  static $pb.PbList<WebBrowserInfo> createRepeated() =>
      $pb.PbList<WebBrowserInfo>();
  @$core.pragma('dart2js:noInline')
  static WebBrowserInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WebBrowserInfo>(create);
  static WebBrowserInfo? _defaultInstance;

  @$pb.TagNumber(1)
  BrowserName get browserName => $_getN(0);
  @$pb.TagNumber(1)
  set browserName(BrowserName v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasBrowserName() => $_has(0);
  @$pb.TagNumber(1)
  void clearBrowserName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get appCodeName => $_getSZ(1);
  @$pb.TagNumber(2)
  set appCodeName($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasAppCodeName() => $_has(1);
  @$pb.TagNumber(2)
  void clearAppCodeName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get appName => $_getSZ(2);
  @$pb.TagNumber(3)
  set appName($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasAppName() => $_has(2);
  @$pb.TagNumber(3)
  void clearAppName() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get appVersion => $_getSZ(3);
  @$pb.TagNumber(4)
  set appVersion($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasAppVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearAppVersion() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get deviceMemory => $_getI64(4);
  @$pb.TagNumber(5)
  set deviceMemory($fixnum.Int64 v) {
    $_setInt64(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasDeviceMemory() => $_has(4);
  @$pb.TagNumber(5)
  void clearDeviceMemory() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get language => $_getSZ(5);
  @$pb.TagNumber(6)
  set language($core.String v) {
    $_setString(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasLanguage() => $_has(5);
  @$pb.TagNumber(6)
  void clearLanguage() => clearField(6);

  @$pb.TagNumber(7)
  $core.List<$core.String> get languages => $_getList(6);

  @$pb.TagNumber(8)
  $core.String get platform => $_getSZ(7);
  @$pb.TagNumber(8)
  set platform($core.String v) {
    $_setString(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasPlatform() => $_has(7);
  @$pb.TagNumber(8)
  void clearPlatform() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get product => $_getSZ(8);
  @$pb.TagNumber(9)
  set product($core.String v) {
    $_setString(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasProduct() => $_has(8);
  @$pb.TagNumber(9)
  void clearProduct() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get productSub => $_getSZ(9);
  @$pb.TagNumber(10)
  set productSub($core.String v) {
    $_setString(9, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasProductSub() => $_has(9);
  @$pb.TagNumber(10)
  void clearProductSub() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get userAgent => $_getSZ(10);
  @$pb.TagNumber(11)
  set userAgent($core.String v) {
    $_setString(10, v);
  }

  @$pb.TagNumber(11)
  $core.bool hasUserAgent() => $_has(10);
  @$pb.TagNumber(11)
  void clearUserAgent() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get vendor => $_getSZ(11);
  @$pb.TagNumber(12)
  set vendor($core.String v) {
    $_setString(11, v);
  }

  @$pb.TagNumber(12)
  $core.bool hasVendor() => $_has(11);
  @$pb.TagNumber(12)
  void clearVendor() => clearField(12);

  @$pb.TagNumber(13)
  $core.String get vendorSub => $_getSZ(12);
  @$pb.TagNumber(13)
  set vendorSub($core.String v) {
    $_setString(12, v);
  }

  @$pb.TagNumber(13)
  $core.bool hasVendorSub() => $_has(12);
  @$pb.TagNumber(13)
  void clearVendorSub() => clearField(13);

  @$pb.TagNumber(14)
  $core.int get hardwareConcurrency => $_getIZ(13);
  @$pb.TagNumber(14)
  set hardwareConcurrency($core.int v) {
    $_setUnsignedInt32(13, v);
  }

  @$pb.TagNumber(14)
  $core.bool hasHardwareConcurrency() => $_has(13);
  @$pb.TagNumber(14)
  void clearHardwareConcurrency() => clearField(14);

  @$pb.TagNumber(15)
  $core.int get maxTouchPoints => $_getIZ(14);
  @$pb.TagNumber(15)
  set maxTouchPoints($core.int v) {
    $_setUnsignedInt32(14, v);
  }

  @$pb.TagNumber(15)
  $core.bool hasMaxTouchPoints() => $_has(14);
  @$pb.TagNumber(15)
  void clearMaxTouchPoints() => clearField(15);
}
