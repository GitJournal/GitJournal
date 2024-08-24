//
//  Generated code. Do not modify.
//  source: analytics.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'analytics.pbenum.dart';

export 'analytics.pbenum.dart';

class AnalyticsReply extends $pb.GeneratedMessage {
  factory AnalyticsReply() => create();
  AnalyticsReply._() : super();
  factory AnalyticsReply.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory AnalyticsReply.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AnalyticsReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gitjournal'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  AnalyticsReply clone() => AnalyticsReply()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  AnalyticsReply copyWith(void Function(AnalyticsReply) updates) =>
      super.copyWith((message) => updates(message as AnalyticsReply))
          as AnalyticsReply;

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
  factory AnalyticsMessage({
    $core.String? appId,
    $core.Iterable<Event>? events,
    DeviceInfo? deviceInfo,
    PackageInfo? packageInfo,
  }) {
    final $result = create();
    if (appId != null) {
      $result.appId = appId;
    }
    if (events != null) {
      $result.events.addAll(events);
    }
    if (deviceInfo != null) {
      $result.deviceInfo = deviceInfo;
    }
    if (packageInfo != null) {
      $result.packageInfo = packageInfo;
    }
    return $result;
  }
  AnalyticsMessage._() : super();
  factory AnalyticsMessage.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory AnalyticsMessage.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AnalyticsMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'appId', protoName: 'appId')
    ..pc<Event>(2, _omitFieldNames ? '' : 'events', $pb.PbFieldType.PM,
        subBuilder: Event.create)
    ..aOM<DeviceInfo>(3, _omitFieldNames ? '' : 'deviceInfo',
        protoName: 'deviceInfo', subBuilder: DeviceInfo.create)
    ..aOM<PackageInfo>(4, _omitFieldNames ? '' : 'packageInfo',
        protoName: 'packageInfo', subBuilder: PackageInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  AnalyticsMessage clone() => AnalyticsMessage()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  AnalyticsMessage copyWith(void Function(AnalyticsMessage) updates) =>
      super.copyWith((message) => updates(message as AnalyticsMessage))
          as AnalyticsMessage;

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
  factory Event({
    $core.String? name,
    $fixnum.Int64? date,
    $core.Map<$core.String, $core.String>? params,
    $core.String? userId,
    $core.String? pseudoId,
    $core.Map<$core.String, $core.String>? userProperties,
    $core.int? sessionID,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (date != null) {
      $result.date = date;
    }
    if (params != null) {
      $result.params.addAll(params);
    }
    if (userId != null) {
      $result.userId = userId;
    }
    if (pseudoId != null) {
      $result.pseudoId = pseudoId;
    }
    if (userProperties != null) {
      $result.userProperties.addAll(userProperties);
    }
    if (sessionID != null) {
      $result.sessionID = sessionID;
    }
    return $result;
  }
  Event._() : super();
  factory Event.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Event.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'date', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'params',
        entryClassName: 'Event.ParamsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('gitjournal'))
    ..aOS(4, _omitFieldNames ? '' : 'userId', protoName: 'userId')
    ..aOS(5, _omitFieldNames ? '' : 'pseudoId', protoName: 'pseudoId')
    ..m<$core.String, $core.String>(6, _omitFieldNames ? '' : 'userProperties',
        protoName: 'userProperties',
        entryClassName: 'Event.UserPropertiesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('gitjournal'))
    ..a<$core.int>(7, _omitFieldNames ? '' : 'sessionID', $pb.PbFieldType.OU3,
        protoName: 'sessionID')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Event clone() => Event()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Event copyWith(void Function(Event) updates) =>
      super.copyWith((message) => updates(message as Event)) as Event;

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
  factory DeviceInfo({
    Platform? platform,
    AndroidDeviceInfo? androidDeviceInfo,
    IosDeviceInfo? iosDeviceInfo,
    LinuxDeviceInfo? linuxDeviceInfo,
    MacOSDeviceInfo? macOSDeviceInfo,
    WindowsDeviceInfo? windowsDeviceInfo,
    WebBrowserInfo? webBrowserInfo,
  }) {
    final $result = create();
    if (platform != null) {
      $result.platform = platform;
    }
    if (androidDeviceInfo != null) {
      $result.androidDeviceInfo = androidDeviceInfo;
    }
    if (iosDeviceInfo != null) {
      $result.iosDeviceInfo = iosDeviceInfo;
    }
    if (linuxDeviceInfo != null) {
      $result.linuxDeviceInfo = linuxDeviceInfo;
    }
    if (macOSDeviceInfo != null) {
      $result.macOSDeviceInfo = macOSDeviceInfo;
    }
    if (windowsDeviceInfo != null) {
      $result.windowsDeviceInfo = windowsDeviceInfo;
    }
    if (webBrowserInfo != null) {
      $result.webBrowserInfo = webBrowserInfo;
    }
    return $result;
  }
  DeviceInfo._() : super();
  factory DeviceInfo.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory DeviceInfo.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

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
      _omitMessageNames ? '' : 'DeviceInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gitjournal'),
      createEmptyInstance: create)
    ..oo(0, [11, 12, 13, 14, 15, 16])
    ..e<Platform>(1, _omitFieldNames ? '' : 'platform', $pb.PbFieldType.OE,
        defaultOrMaker: Platform.android,
        valueOf: Platform.valueOf,
        enumValues: Platform.values)
    ..aOM<AndroidDeviceInfo>(11, _omitFieldNames ? '' : 'androidDeviceInfo',
        protoName: 'androidDeviceInfo', subBuilder: AndroidDeviceInfo.create)
    ..aOM<IosDeviceInfo>(12, _omitFieldNames ? '' : 'iosDeviceInfo',
        protoName: 'iosDeviceInfo', subBuilder: IosDeviceInfo.create)
    ..aOM<LinuxDeviceInfo>(13, _omitFieldNames ? '' : 'linuxDeviceInfo',
        protoName: 'linuxDeviceInfo', subBuilder: LinuxDeviceInfo.create)
    ..aOM<MacOSDeviceInfo>(14, _omitFieldNames ? '' : 'macOSDeviceInfo',
        protoName: 'macOSDeviceInfo', subBuilder: MacOSDeviceInfo.create)
    ..aOM<WindowsDeviceInfo>(15, _omitFieldNames ? '' : 'windowsDeviceInfo',
        protoName: 'windowsDeviceInfo', subBuilder: WindowsDeviceInfo.create)
    ..aOM<WebBrowserInfo>(16, _omitFieldNames ? '' : 'webBrowserInfo',
        protoName: 'webBrowserInfo', subBuilder: WebBrowserInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  DeviceInfo clone() => DeviceInfo()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  DeviceInfo copyWith(void Function(DeviceInfo) updates) =>
      super.copyWith((message) => updates(message as DeviceInfo)) as DeviceInfo;

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
  factory PackageInfo({
    $core.String? appName,
    $core.String? packageName,
    $core.String? version,
    $core.String? buildNumber,
    $core.String? buildSignature,
    $core.String? installSource,
  }) {
    final $result = create();
    if (appName != null) {
      $result.appName = appName;
    }
    if (packageName != null) {
      $result.packageName = packageName;
    }
    if (version != null) {
      $result.version = version;
    }
    if (buildNumber != null) {
      $result.buildNumber = buildNumber;
    }
    if (buildSignature != null) {
      $result.buildSignature = buildSignature;
    }
    if (installSource != null) {
      $result.installSource = installSource;
    }
    return $result;
  }
  PackageInfo._() : super();
  factory PackageInfo.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory PackageInfo.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PackageInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'appName', protoName: 'appName')
    ..aOS(2, _omitFieldNames ? '' : 'packageName', protoName: 'packageName')
    ..aOS(3, _omitFieldNames ? '' : 'version')
    ..aOS(4, _omitFieldNames ? '' : 'buildNumber', protoName: 'buildNumber')
    ..aOS(5, _omitFieldNames ? '' : 'buildSignature',
        protoName: 'buildSignature')
    ..aOS(6, _omitFieldNames ? '' : 'installSource', protoName: 'installSource')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  PackageInfo clone() => PackageInfo()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  PackageInfo copyWith(void Function(PackageInfo) updates) =>
      super.copyWith((message) => updates(message as PackageInfo))
          as PackageInfo;

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
  factory AndroidBuildVersion({
    $core.String? baseOS,
    $core.String? codename,
    $core.String? incremental,
    $core.int? previewSdkInt,
    $core.String? release,
    $core.int? sdkInt,
    $core.String? securityPatch,
  }) {
    final $result = create();
    if (baseOS != null) {
      $result.baseOS = baseOS;
    }
    if (codename != null) {
      $result.codename = codename;
    }
    if (incremental != null) {
      $result.incremental = incremental;
    }
    if (previewSdkInt != null) {
      $result.previewSdkInt = previewSdkInt;
    }
    if (release != null) {
      $result.release = release;
    }
    if (sdkInt != null) {
      $result.sdkInt = sdkInt;
    }
    if (securityPatch != null) {
      $result.securityPatch = securityPatch;
    }
    return $result;
  }
  AndroidBuildVersion._() : super();
  factory AndroidBuildVersion.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory AndroidBuildVersion.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AndroidBuildVersion',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'baseOS', protoName: 'baseOS')
    ..aOS(2, _omitFieldNames ? '' : 'codename')
    ..aOS(3, _omitFieldNames ? '' : 'incremental')
    ..a<$core.int>(
        4, _omitFieldNames ? '' : 'previewSdkInt', $pb.PbFieldType.OU3,
        protoName: 'previewSdkInt')
    ..aOS(5, _omitFieldNames ? '' : 'release')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'sdkInt', $pb.PbFieldType.OU3,
        protoName: 'sdkInt')
    ..aOS(7, _omitFieldNames ? '' : 'securityPatch', protoName: 'securityPatch')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  AndroidBuildVersion clone() => AndroidBuildVersion()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  AndroidBuildVersion copyWith(void Function(AndroidBuildVersion) updates) =>
      super.copyWith((message) => updates(message as AndroidBuildVersion))
          as AndroidBuildVersion;

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
    final $result = create();
    if (version != null) {
      $result.version = version;
    }
    if (board != null) {
      $result.board = board;
    }
    if (bootloader != null) {
      $result.bootloader = bootloader;
    }
    if (brand != null) {
      $result.brand = brand;
    }
    if (device != null) {
      $result.device = device;
    }
    if (display != null) {
      $result.display = display;
    }
    if (fingerprint != null) {
      $result.fingerprint = fingerprint;
    }
    if (hardware != null) {
      $result.hardware = hardware;
    }
    if (host != null) {
      $result.host = host;
    }
    if (id != null) {
      $result.id = id;
    }
    if (manufacturer != null) {
      $result.manufacturer = manufacturer;
    }
    if (model != null) {
      $result.model = model;
    }
    if (product != null) {
      $result.product = product;
    }
    if (supported32BitAbis != null) {
      $result.supported32BitAbis.addAll(supported32BitAbis);
    }
    if (supported64BitAbis != null) {
      $result.supported64BitAbis.addAll(supported64BitAbis);
    }
    if (supportedAbis != null) {
      $result.supportedAbis.addAll(supportedAbis);
    }
    if (tags != null) {
      $result.tags = tags;
    }
    if (type != null) {
      $result.type = type;
    }
    if (isPhysicalDevice != null) {
      $result.isPhysicalDevice = isPhysicalDevice;
    }
    if (androidId != null) {
      $result.androidId = androidId;
    }
    if (systemFeatures != null) {
      $result.systemFeatures.addAll(systemFeatures);
    }
    return $result;
  }
  AndroidDeviceInfo._() : super();
  factory AndroidDeviceInfo.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory AndroidDeviceInfo.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AndroidDeviceInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gitjournal'),
      createEmptyInstance: create)
    ..aOM<AndroidBuildVersion>(1, _omitFieldNames ? '' : 'version',
        subBuilder: AndroidBuildVersion.create)
    ..aOS(2, _omitFieldNames ? '' : 'board')
    ..aOS(3, _omitFieldNames ? '' : 'bootloader')
    ..aOS(4, _omitFieldNames ? '' : 'brand')
    ..aOS(5, _omitFieldNames ? '' : 'device')
    ..aOS(6, _omitFieldNames ? '' : 'display')
    ..aOS(7, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(8, _omitFieldNames ? '' : 'hardware')
    ..aOS(9, _omitFieldNames ? '' : 'host')
    ..aOS(10, _omitFieldNames ? '' : 'id')
    ..aOS(11, _omitFieldNames ? '' : 'manufacturer')
    ..aOS(12, _omitFieldNames ? '' : 'model')
    ..aOS(13, _omitFieldNames ? '' : 'product')
    ..pPS(14, _omitFieldNames ? '' : 'supported32BitAbis',
        protoName: 'supported32BitAbis')
    ..pPS(15, _omitFieldNames ? '' : 'supported64BitAbis',
        protoName: 'supported64BitAbis')
    ..pPS(16, _omitFieldNames ? '' : 'supportedAbis',
        protoName: 'supportedAbis')
    ..aOS(17, _omitFieldNames ? '' : 'tags')
    ..aOS(18, _omitFieldNames ? '' : 'type')
    ..aOB(19, _omitFieldNames ? '' : 'isPhysicalDevice',
        protoName: 'isPhysicalDevice')
    ..aOS(20, _omitFieldNames ? '' : 'androidId', protoName: 'androidId')
    ..pPS(21, _omitFieldNames ? '' : 'systemFeatures',
        protoName: 'systemFeatures')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  AndroidDeviceInfo clone() => AndroidDeviceInfo()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  AndroidDeviceInfo copyWith(void Function(AndroidDeviceInfo) updates) =>
      super.copyWith((message) => updates(message as AndroidDeviceInfo))
          as AndroidDeviceInfo;

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
  factory IosUtsname({
    $core.String? sysname,
    $core.String? nodename,
    $core.String? release,
    $core.String? version,
    $core.String? machine,
  }) {
    final $result = create();
    if (sysname != null) {
      $result.sysname = sysname;
    }
    if (nodename != null) {
      $result.nodename = nodename;
    }
    if (release != null) {
      $result.release = release;
    }
    if (version != null) {
      $result.version = version;
    }
    if (machine != null) {
      $result.machine = machine;
    }
    return $result;
  }
  IosUtsname._() : super();
  factory IosUtsname.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory IosUtsname.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IosUtsname',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sysname')
    ..aOS(2, _omitFieldNames ? '' : 'nodename')
    ..aOS(3, _omitFieldNames ? '' : 'release')
    ..aOS(4, _omitFieldNames ? '' : 'version')
    ..aOS(5, _omitFieldNames ? '' : 'machine')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  IosUtsname clone() => IosUtsname()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  IosUtsname copyWith(void Function(IosUtsname) updates) =>
      super.copyWith((message) => updates(message as IosUtsname)) as IosUtsname;

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
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (systemName != null) {
      $result.systemName = systemName;
    }
    if (systemVersion != null) {
      $result.systemVersion = systemVersion;
    }
    if (model != null) {
      $result.model = model;
    }
    if (localizedModel != null) {
      $result.localizedModel = localizedModel;
    }
    if (identifierForVendor != null) {
      $result.identifierForVendor = identifierForVendor;
    }
    if (isPhysicalDevice != null) {
      $result.isPhysicalDevice = isPhysicalDevice;
    }
    if (utsname != null) {
      $result.utsname = utsname;
    }
    return $result;
  }
  IosDeviceInfo._() : super();
  factory IosDeviceInfo.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory IosDeviceInfo.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IosDeviceInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'systemName', protoName: 'systemName')
    ..aOS(3, _omitFieldNames ? '' : 'systemVersion', protoName: 'systemVersion')
    ..aOS(4, _omitFieldNames ? '' : 'model')
    ..aOS(5, _omitFieldNames ? '' : 'localizedModel',
        protoName: 'localizedModel')
    ..aOS(6, _omitFieldNames ? '' : 'identifierForVendor',
        protoName: 'identifierForVendor')
    ..aOB(7, _omitFieldNames ? '' : 'isPhysicalDevice',
        protoName: 'isPhysicalDevice')
    ..aOM<IosUtsname>(8, _omitFieldNames ? '' : 'utsname',
        subBuilder: IosUtsname.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  IosDeviceInfo clone() => IosDeviceInfo()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  IosDeviceInfo copyWith(void Function(IosDeviceInfo) updates) =>
      super.copyWith((message) => updates(message as IosDeviceInfo))
          as IosDeviceInfo;

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
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (version != null) {
      $result.version = version;
    }
    if (id != null) {
      $result.id = id;
    }
    if (idLike != null) {
      $result.idLike.addAll(idLike);
    }
    if (versionCodename != null) {
      $result.versionCodename = versionCodename;
    }
    if (versionId != null) {
      $result.versionId = versionId;
    }
    if (prettyName != null) {
      $result.prettyName = prettyName;
    }
    if (buildId != null) {
      $result.buildId = buildId;
    }
    if (variant != null) {
      $result.variant = variant;
    }
    if (variantId != null) {
      $result.variantId = variantId;
    }
    if (machineId != null) {
      $result.machineId = machineId;
    }
    return $result;
  }
  LinuxDeviceInfo._() : super();
  factory LinuxDeviceInfo.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory LinuxDeviceInfo.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LinuxDeviceInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'version')
    ..aOS(3, _omitFieldNames ? '' : 'id')
    ..pPS(4, _omitFieldNames ? '' : 'idLike', protoName: 'idLike')
    ..aOS(5, _omitFieldNames ? '' : 'versionCodename',
        protoName: 'versionCodename')
    ..aOS(6, _omitFieldNames ? '' : 'versionId', protoName: 'versionId')
    ..aOS(7, _omitFieldNames ? '' : 'prettyName', protoName: 'prettyName')
    ..aOS(8, _omitFieldNames ? '' : 'buildId', protoName: 'buildId')
    ..aOS(9, _omitFieldNames ? '' : 'variant')
    ..aOS(10, _omitFieldNames ? '' : 'variantId', protoName: 'variantId')
    ..aOS(11, _omitFieldNames ? '' : 'machineId', protoName: 'machineId')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  LinuxDeviceInfo clone() => LinuxDeviceInfo()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  LinuxDeviceInfo copyWith(void Function(LinuxDeviceInfo) updates) =>
      super.copyWith((message) => updates(message as LinuxDeviceInfo))
          as LinuxDeviceInfo;

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
    final $result = create();
    if (computerName != null) {
      $result.computerName = computerName;
    }
    if (hostName != null) {
      $result.hostName = hostName;
    }
    if (arch != null) {
      $result.arch = arch;
    }
    if (model != null) {
      $result.model = model;
    }
    if (kernelVersion != null) {
      $result.kernelVersion = kernelVersion;
    }
    if (osRelease != null) {
      $result.osRelease = osRelease;
    }
    if (activeCPUs != null) {
      $result.activeCPUs = activeCPUs;
    }
    if (memorySize != null) {
      $result.memorySize = memorySize;
    }
    if (cpuFrequency != null) {
      $result.cpuFrequency = cpuFrequency;
    }
    return $result;
  }
  MacOSDeviceInfo._() : super();
  factory MacOSDeviceInfo.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory MacOSDeviceInfo.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MacOSDeviceInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'computerName', protoName: 'computerName')
    ..aOS(2, _omitFieldNames ? '' : 'hostName', protoName: 'hostName')
    ..aOS(3, _omitFieldNames ? '' : 'arch')
    ..aOS(4, _omitFieldNames ? '' : 'model')
    ..aOS(5, _omitFieldNames ? '' : 'kernelVersion', protoName: 'kernelVersion')
    ..aOS(6, _omitFieldNames ? '' : 'osRelease', protoName: 'osRelease')
    ..a<$core.int>(7, _omitFieldNames ? '' : 'activeCPUs', $pb.PbFieldType.OU3,
        protoName: 'activeCPUs')
    ..a<$fixnum.Int64>(
        8, _omitFieldNames ? '' : 'memorySize', $pb.PbFieldType.OU6,
        protoName: 'memorySize', defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        9, _omitFieldNames ? '' : 'cpuFrequency', $pb.PbFieldType.OU6,
        protoName: 'cpuFrequency', defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  MacOSDeviceInfo clone() => MacOSDeviceInfo()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  MacOSDeviceInfo copyWith(void Function(MacOSDeviceInfo) updates) =>
      super.copyWith((message) => updates(message as MacOSDeviceInfo))
          as MacOSDeviceInfo;

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
  factory WindowsDeviceInfo({
    $core.String? computerName,
    $core.int? numberOfCores,
    $core.int? systemMemoryInMegabytes,
  }) {
    final $result = create();
    if (computerName != null) {
      $result.computerName = computerName;
    }
    if (numberOfCores != null) {
      $result.numberOfCores = numberOfCores;
    }
    if (systemMemoryInMegabytes != null) {
      $result.systemMemoryInMegabytes = systemMemoryInMegabytes;
    }
    return $result;
  }
  WindowsDeviceInfo._() : super();
  factory WindowsDeviceInfo.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory WindowsDeviceInfo.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WindowsDeviceInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'computerName', protoName: 'computerName')
    ..a<$core.int>(
        2, _omitFieldNames ? '' : 'numberOfCores', $pb.PbFieldType.OU3,
        protoName: 'numberOfCores')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'systemMemoryInMegabytes',
        $pb.PbFieldType.OU3,
        protoName: 'systemMemoryInMegabytes')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  WindowsDeviceInfo clone() => WindowsDeviceInfo()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  WindowsDeviceInfo copyWith(void Function(WindowsDeviceInfo) updates) =>
      super.copyWith((message) => updates(message as WindowsDeviceInfo))
          as WindowsDeviceInfo;

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
    final $result = create();
    if (browserName != null) {
      $result.browserName = browserName;
    }
    if (appCodeName != null) {
      $result.appCodeName = appCodeName;
    }
    if (appName != null) {
      $result.appName = appName;
    }
    if (appVersion != null) {
      $result.appVersion = appVersion;
    }
    if (deviceMemory != null) {
      $result.deviceMemory = deviceMemory;
    }
    if (language != null) {
      $result.language = language;
    }
    if (languages != null) {
      $result.languages.addAll(languages);
    }
    if (platform != null) {
      $result.platform = platform;
    }
    if (product != null) {
      $result.product = product;
    }
    if (productSub != null) {
      $result.productSub = productSub;
    }
    if (userAgent != null) {
      $result.userAgent = userAgent;
    }
    if (vendor != null) {
      $result.vendor = vendor;
    }
    if (vendorSub != null) {
      $result.vendorSub = vendorSub;
    }
    if (hardwareConcurrency != null) {
      $result.hardwareConcurrency = hardwareConcurrency;
    }
    if (maxTouchPoints != null) {
      $result.maxTouchPoints = maxTouchPoints;
    }
    return $result;
  }
  WebBrowserInfo._() : super();
  factory WebBrowserInfo.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory WebBrowserInfo.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WebBrowserInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gitjournal'),
      createEmptyInstance: create)
    ..e<BrowserName>(
        1, _omitFieldNames ? '' : 'browserName', $pb.PbFieldType.OE,
        protoName: 'browserName',
        defaultOrMaker: BrowserName.unknown,
        valueOf: BrowserName.valueOf,
        enumValues: BrowserName.values)
    ..aOS(2, _omitFieldNames ? '' : 'appCodeName', protoName: 'appCodeName')
    ..aOS(3, _omitFieldNames ? '' : 'appName', protoName: 'appName')
    ..aOS(4, _omitFieldNames ? '' : 'appVersion', protoName: 'appVersion')
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'deviceMemory', $pb.PbFieldType.OU6,
        protoName: 'deviceMemory', defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(6, _omitFieldNames ? '' : 'language')
    ..pPS(7, _omitFieldNames ? '' : 'languages')
    ..aOS(8, _omitFieldNames ? '' : 'platform')
    ..aOS(9, _omitFieldNames ? '' : 'product')
    ..aOS(10, _omitFieldNames ? '' : 'productSub', protoName: 'productSub')
    ..aOS(11, _omitFieldNames ? '' : 'userAgent', protoName: 'userAgent')
    ..aOS(12, _omitFieldNames ? '' : 'vendor')
    ..aOS(13, _omitFieldNames ? '' : 'vendorSub', protoName: 'vendorSub')
    ..a<$core.int>(
        14, _omitFieldNames ? '' : 'hardwareConcurrency', $pb.PbFieldType.OU3,
        protoName: 'hardwareConcurrency')
    ..a<$core.int>(
        15, _omitFieldNames ? '' : 'maxTouchPoints', $pb.PbFieldType.OU3,
        protoName: 'maxTouchPoints')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  WebBrowserInfo clone() => WebBrowserInfo()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  WebBrowserInfo copyWith(void Function(WebBrowserInfo) updates) =>
      super.copyWith((message) => updates(message as WebBrowserInfo))
          as WebBrowserInfo;

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

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
