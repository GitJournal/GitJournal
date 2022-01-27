/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/foundation.dart';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:yaml/yaml.dart';

import 'package:gitjournal/generated/core.pb.dart' as pb;
import 'package:gitjournal/utils/datetime.dart';

Function _deepEq = const DeepCollectionEquality().equals;

class MdYamlDoc {
  final String body;
  late final ListMap<String, dynamic> props;

  MdYamlDoc({
    this.body = "",
    ListMap<String, dynamic>? props,
  }) {
    this.props = props ?? ListMap.empty();
  }

  MdYamlDoc copyWith({String? body, ListMap<String, dynamic>? props}) {
    return MdYamlDoc(
      body: body ?? this.body,
      props: props ?? this.props,
    );
  }

  @override
  int get hashCode => body.hashCode ^ props.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MdYamlDoc &&
          runtimeType == other.runtimeType &&
          body == other.body &&
          _deepEq(props, other.props);

  @override
  String toString() {
    if (kDebugMode) {
      var buffer = StringBuffer();
      buffer.write("{");
      for (var e in props.entries) {
        buffer.write('${e.key}: ${e.value}, ');
      }
      buffer.write('}');
      return 'MdYamlDoc{body: "$body", props: ${buffer.toString()}}';
    } else {
      return 'MdYamlDoc{body: "<hidden>", props: <hidden>}';
    }
  }

  pb.MdYamlDoc toProtoBuf() {
    return pb.MdYamlDoc(
      body: body,
      map: mapToProtoBuf(props),
    );
  }

  static MdYamlDoc fromProtoBuf(pb.MdYamlDoc p) {
    return MdYamlDoc(
      body: p.body,
      props: ListMap.of(mapFromProtoBuf(p.map)),
    );
  }
}

Map<String, pb.Union> mapToProtoBuf(Map<String, dynamic> map) =>
    map.map((key, val) => MapEntry(key, _toUnion(val)));

Map<String, dynamic> mapFromProtoBuf(Map<String, pb.Union> map) =>
    map.map((key, val) => MapEntry(key, _fromUnion(val)));

pb.Union _toUnion(dynamic val) {
  if (val is String) {
    return pb.Union(stringValue: val);
  } else if (val is int) {
    return pb.Union(intValue: fixnum.Int64(val));
  } else if (val is fixnum.Int64) {
    return pb.Union(intValue: val);
  } else if (val is bool) {
    return pb.Union(booleanValue: val);
  } else if (val is DateTime) {
    return pb.Union(dateValue: val.toProtoBuf());
  } else if (val == null) {
    return pb.Union(isNull: true);
  }

  if (val is YamlList || val is List) {
    var list = <pb.Union>[];
    for (var v in val) {
      list.add(_toUnion(v));
    }

    return pb.Union(listValue: list);
  }

  if (val is Map) {
    var map = <String, pb.Union>{};
    for (var e in val.entries) {
      map[e.key.toString()] = _toUnion(e.value);
    }

    return pb.Union(mapValue: map);
  }

  throw Exception(
      "Type cannot be converted to Protobuf Union - ${val.runtimeType}");
}

dynamic _fromUnion(pb.Union u) {
  if (u.hasStringValue()) {
    return u.stringValue;
  } else if (u.hasIntValue()) {
    return u.intValue.toInt();
  } else if (u.hasBooleanValue()) {
    return u.booleanValue;
  } else if (u.hasDateValue()) {
    return u.dateValue.toDateTime();
  } else if (u.listValue.isNotEmpty) {
    var list = <dynamic>[];
    for (var v in u.listValue) {
      list.add(_fromUnion(v));
    }
    return list;
  } else if (u.mapValue.isNotEmpty) {
    var map = <String, dynamic>{};
    for (var e in u.mapValue.entries) {
      map[e.key] = _fromUnion(e.value);
    }
    return map;
  } else if (u.isNull) {
    return null;
  }

  throw Exception("Type cannot be converted from Protobuf Union");
}
