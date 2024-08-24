//
//  Generated code. Do not modify.
//  source: markdown.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class NodeList extends $pb.GeneratedMessage {
  factory NodeList({
    $core.Iterable<Node>? node,
  }) {
    final $result = create();
    if (node != null) {
      $result.node.addAll(node);
    }
    return $result;
  }
  NodeList._() : super();
  factory NodeList.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory NodeList.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NodeList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gitjournal'),
      createEmptyInstance: create)
    ..pc<Node>(1, _omitFieldNames ? '' : 'node', $pb.PbFieldType.PM,
        subBuilder: Node.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  NodeList clone() => NodeList()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  NodeList copyWith(void Function(NodeList) updates) =>
      super.copyWith((message) => updates(message as NodeList)) as NodeList;

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
  factory Node({
    Element? element,
    $core.String? text,
  }) {
    final $result = create();
    if (element != null) {
      $result.element = element;
    }
    if (text != null) {
      $result.text = text;
    }
    return $result;
  }
  Node._() : super();
  factory Node.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Node.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, Node_Value> _Node_ValueByTag = {
    1: Node_Value.element,
    2: Node_Value.text,
    0: Node_Value.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Node',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gitjournal'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<Element>(1, _omitFieldNames ? '' : 'element',
        subBuilder: Element.create)
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Node clone() => Node()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Node copyWith(void Function(Node) updates) =>
      super.copyWith((message) => updates(message as Node)) as Node;

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
  factory Element({
    $core.String? tag,
    $core.Map<$core.String, $core.String>? attributes,
    $core.Iterable<Node>? children,
    $core.String? generatedId,
  }) {
    final $result = create();
    if (tag != null) {
      $result.tag = tag;
    }
    if (attributes != null) {
      $result.attributes.addAll(attributes);
    }
    if (children != null) {
      $result.children.addAll(children);
    }
    if (generatedId != null) {
      $result.generatedId = generatedId;
    }
    return $result;
  }
  Element._() : super();
  factory Element.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Element.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Element',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'gitjournal'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tag')
    ..m<$core.String, $core.String>(2, _omitFieldNames ? '' : 'attributes',
        entryClassName: 'Element.AttributesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('gitjournal'))
    ..pc<Node>(3, _omitFieldNames ? '' : 'children', $pb.PbFieldType.PM,
        subBuilder: Node.create)
    ..aOS(4, _omitFieldNames ? '' : 'generatedId', protoName: 'generatedId')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Element clone() => Element()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Element copyWith(void Function(Element) updates) =>
      super.copyWith((message) => updates(message as Element)) as Element;

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

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
