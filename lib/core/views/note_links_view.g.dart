/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_links_view.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LinksListAdapter extends TypeAdapter<_LinksList> {
  @override
  final int typeId = 1;

  @override
  _LinksList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _LinksList(
      (fields[0] as List).cast<Link>(),
    );
  }

  @override
  void write(BinaryWriter writer, _LinksList obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.list);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinksListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
