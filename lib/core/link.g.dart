/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LinkAdapter extends TypeAdapter<Link> {
  @override
  final int typeId = 0;

  @override
  Link read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Link(
      publicTerm: fields[0] as String?,
      filePath: fields[1] as String?,
      headingID: fields[2] as String?,
      alt: fields[3] as String?,
    )..wikiTerm = fields[5] as String?;
  }

  @override
  void write(BinaryWriter writer, Link obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.publicTerm)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.headingID)
      ..writeByte(3)
      ..write(obj.alt)
      ..writeByte(5)
      ..write(obj.wikiTerm);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
