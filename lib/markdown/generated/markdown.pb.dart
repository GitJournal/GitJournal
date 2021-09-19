// SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

///
//  Generated code. Do not modify.
//  source: markdown.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class NodeList extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'NodeList',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..pc<Node>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'node',
        $pb.PbFieldType.PM,
        subBuilder: Node.create)
    ..hasRequiredFields = false;

  NodeList._() : super();
  factory NodeList({
    $core.Iterable<Node>? node,
  }) {
    final _result = create();
    if (node != null) {
      _result.node.addAll(node);
    }
    return _result;
  }
  factory NodeList.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory NodeList.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  NodeList clone() => NodeList()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  NodeList copyWith(void Function(NodeList) updates) =>
      super.copyWith((message) => updates(message as NodeList))
          as NodeList; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static NodeList create() => NodeList._();
  NodeList createEmptyInstance() => create();
  static $pb.PbList<NodeList> createRepeated() => $pb.PbList<NodeList>();
  @$core.pragma('dart2js:noInline')
  static NodeList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NodeList>(create);
  static NodeList? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Node> get node => $_getList(0);
}

enum Node_Value { element, text, notSet }

class Node extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, Node_Value> _Node_ValueByTag = {
    1: Node_Value.element,
    2: Node_Value.text,
    0: Node_Value.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'Node',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<Element>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'element',
        subBuilder: Element.create)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'text')
    ..hasRequiredFields = false;

  Node._() : super();
  factory Node({
    Element? element,
    $core.String? text,
  }) {
    final _result = create();
    if (element != null) {
      _result.element = element;
    }
    if (text != null) {
      _result.text = text;
    }
    return _result;
  }
  factory Node.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Node.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Node clone() => Node()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Node copyWith(void Function(Node) updates) =>
      super.copyWith((message) => updates(message as Node))
          as Node; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Node create() => Node._();
  Node createEmptyInstance() => create();
  static $pb.PbList<Node> createRepeated() => $pb.PbList<Node>();
  @$core.pragma('dart2js:noInline')
  static Node getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Node>(create);
  static Node? _defaultInstance;

  Node_Value whichValue() => _Node_ValueByTag[$_whichOneof(0)]!;
  void clearValue() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  Element get element => $_getN(0);
  @$pb.TagNumber(1)
  set element(Element v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasElement() => $_has(0);
  @$pb.TagNumber(1)
  void clearElement() => clearField(1);
  @$pb.TagNumber(1)
  Element ensureElement() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => clearField(2);
}

class Element extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'Element',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'tag')
    ..m<$core.String, $core.String>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'attributes',
        entryClassName: 'Element.AttributesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('gitjournal'))
    ..pc<Node>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'children',
        $pb.PbFieldType.PM,
        subBuilder: Node.create)
    ..aOS(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'generatedId',
        protoName: 'generatedId')
    ..hasRequiredFields = false;

  Element._() : super();
  factory Element({
    $core.String? tag,
    $core.Map<$core.String, $core.String>? attributes,
    $core.Iterable<Node>? children,
    $core.String? generatedId,
  }) {
    final _result = create();
    if (tag != null) {
      _result.tag = tag;
    }
    if (attributes != null) {
      _result.attributes.addAll(attributes);
    }
    if (children != null) {
      _result.children.addAll(children);
    }
    if (generatedId != null) {
      _result.generatedId = generatedId;
    }
    return _result;
  }
  factory Element.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Element.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Element clone() => Element()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Element copyWith(void Function(Element) updates) =>
      super.copyWith((message) => updates(message as Element))
          as Element; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Element create() => Element._();
  Element createEmptyInstance() => create();
  static $pb.PbList<Element> createRepeated() => $pb.PbList<Element>();
  @$core.pragma('dart2js:noInline')
  static Element getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Element>(create);
  static Element? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tag => $_getSZ(0);
  @$pb.TagNumber(1)
  set tag($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasTag() => $_has(0);
  @$pb.TagNumber(1)
  void clearTag() => clearField(1);

  @$pb.TagNumber(2)
  $core.Map<$core.String, $core.String> get attributes => $_getMap(1);

  @$pb.TagNumber(3)
  $core.List<Node> get children => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get generatedId => $_getSZ(3);
  @$pb.TagNumber(4)
  set generatedId($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasGeneratedId() => $_has(3);
  @$pb.TagNumber(4)
  void clearGeneratedId() => clearField(4);
}
