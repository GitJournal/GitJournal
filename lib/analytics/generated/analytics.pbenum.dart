// SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

///
//  Generated code. Do not modify.
//  source: analytics.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

// ignore_for_file: UNDEFINED_SHOWN_NAME

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Platform extends $pb.ProtobufEnum {
  static const Platform android = Platform._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'android');
  static const Platform ios = Platform._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'ios');
  static const Platform linux = Platform._(
      2,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'linux');
  static const Platform macos = Platform._(
      3,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'macos');
  static const Platform windows = Platform._(
      4,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'windows');
  static const Platform web = Platform._(
      5,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'web');

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
  static const BrowserName unknown = BrowserName._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'unknown');
  static const BrowserName firefox = BrowserName._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'firefox');
  static const BrowserName samsungInternet = BrowserName._(
      2,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'samsungInternet');
  static const BrowserName opera = BrowserName._(
      3,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'opera');
  static const BrowserName msie = BrowserName._(
      4,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'msie');
  static const BrowserName edge = BrowserName._(
      5,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'edge');
  static const BrowserName chrome = BrowserName._(
      6,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'chrome');
  static const BrowserName safari = BrowserName._(
      7,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'safari');

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
