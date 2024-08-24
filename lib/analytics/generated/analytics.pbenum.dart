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

import 'package:protobuf/protobuf.dart' as $pb;

class Platform extends $pb.ProtobufEnum {
  static const Platform android =
      Platform._(0, _omitEnumNames ? '' : 'android');
  static const Platform ios = Platform._(1, _omitEnumNames ? '' : 'ios');
  static const Platform linux = Platform._(2, _omitEnumNames ? '' : 'linux');
  static const Platform macos = Platform._(3, _omitEnumNames ? '' : 'macos');
  static const Platform windows =
      Platform._(4, _omitEnumNames ? '' : 'windows');
  static const Platform web = Platform._(5, _omitEnumNames ? '' : 'web');

  static const $core.List<Platform> values = <Platform>[
    android,
    ios,
    linux,
    macos,
    windows,
    web,
  ];

  static final $core.Map<$core.int, Platform> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Platform? valueOf($core.int value) => _byValue[value];

  const Platform._($core.int v, $core.String n) : super(v, n);
}

class BrowserName extends $pb.ProtobufEnum {
  static const BrowserName unknown =
      BrowserName._(0, _omitEnumNames ? '' : 'unknown');
  static const BrowserName firefox =
      BrowserName._(1, _omitEnumNames ? '' : 'firefox');
  static const BrowserName samsungInternet =
      BrowserName._(2, _omitEnumNames ? '' : 'samsungInternet');
  static const BrowserName opera =
      BrowserName._(3, _omitEnumNames ? '' : 'opera');
  static const BrowserName msie =
      BrowserName._(4, _omitEnumNames ? '' : 'msie');
  static const BrowserName edge =
      BrowserName._(5, _omitEnumNames ? '' : 'edge');
  static const BrowserName chrome =
      BrowserName._(6, _omitEnumNames ? '' : 'chrome');
  static const BrowserName safari =
      BrowserName._(7, _omitEnumNames ? '' : 'safari');

  static const $core.List<BrowserName> values = <BrowserName>[
    unknown,
    firefox,
    samsungInternet,
    opera,
    msie,
    edge,
    chrome,
    safari,
  ];

  static final $core.Map<$core.int, BrowserName> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static BrowserName? valueOf($core.int value) => _byValue[value];

  const BrowserName._($core.int v, $core.String n) : super(v, n);
}

const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
