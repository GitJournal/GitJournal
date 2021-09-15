// Taken from : https://github.com/hoylen/ssh_key

/*
 * SPDX-FileCopyrightText: 2020 Hoylen Sue <hoylen@hoylen.com>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';
import 'dart:typed_data';

//################################################################
/// Represents a length-value encoding of a value.
///
/// Use the [BinaryLengthValue.encode] method to convert a list of
/// [BinaryLengthValue] to a sequence of bytes. The items in that list can
/// be created from Uint8List using the default constructor, from a BigInt
/// with [BinaryLengthValue.fromBigInt] or from a String with
/// [BinaryLengthValue.fromString].

class BinaryLengthValue {
  //================================================================
  // Constructors

  //----------------------------------------------------------------
  /// Create a length-value for a sequence of bytes.

  BinaryLengthValue(Uint8List bytes) : _dataBytes = bytes;

  //----------------------------------------------------------------
  /// Create a length-value for a multiple precision integer.
  ///
  /// See section 5 of
  /// [RFC 4251](https://tools.ietf.org/html/rfc4251#section-5) for a definition
  /// of this format.

  BinaryLengthValue.fromBigInt(BigInt value) : _dataBytes = _encodeMPInt(value);

  //----------------------------------------------------------------
  /// Create a length plus bytes for a string.
  ///
  /// The string is encoded using the [encoding], which defaults to utf8.
  /// This default works for US-ASCII too if the value can be guaranteed to only
  /// contain US-ASCII characters, since US-ASCII is a subset of utf8.

  BinaryLengthValue.fromString(String value, {Encoding encoding = utf8})
      : _dataBytes = Uint8List.fromList(encoding.encode(value));

  //================================================================
  // Members

  /// The bytes making up the value. That is, without the length bytes.

  final Uint8List _dataBytes;

  //================================================================
  // Static methods

  //----------------------------------------------------------------
  /// Encodes a sequence of length-value.
  ///
  /// Returns a sequence of bytes that contains each of the [items] in order.
  /// Each of those items is represented by a length followed by the bytes
  /// of the item. The length is always four bytes: a big-endian unsigned 32-bit
  /// integer.

  static Uint8List encode(Iterable<BinaryLengthValue> items) {
    final bytes = <int>[];

    for (final chunk in items) {
      // Chunk length (4-byte big-endian)
      final n = chunk._dataBytes.length;
      bytes
        ..add((n >> 24) & 0xFF)
        ..add((n >> 16) & 0xFF)
        ..add((n >> 8) & 0xFF)
        ..add((n >> 0) & 0xFF)
        ..addAll(chunk._dataBytes);
    }

    return Uint8List.fromList(bytes);
  }

  //----------------------------------------------------------------
  /// Encode a multiple precision integer.
  ///
  /// Returns a sequence of bytes that represents the [value] as a multiple
  /// precision integer. See section 5 of
  /// [RFC 4251](https://tools.ietf.org/html/rfc4251#section-5) for a definition
  /// of this format.
  ///
  /// Note: the returned value is just the number and does not have any bytes
  /// to indicate its length.

  static Uint8List _encodeMPInt(BigInt value) {
    if (value == BigInt.zero) {
      return Uint8List(0); // no bytes in representation
    } else if (!value.isNegative) {
      // Positive multiple precision integer

      var e = value;

      final numBytes = 2 + ((e.bitLength - 1) ~/ 8);
      final bytes = Uint8List(numBytes);

      // Extract each byte of the number, starting with least-significant-byte
      // (the right most byte and working back to the beginning)

      var i = numBytes - 1;

      while (1 <= i) {
        final b = e & BigInt.from(0xFF); // least significant byte
        e = e >> 8;
        bytes[i--] = b.toInt();
      }
      assert(e == BigInt.zero);

      // The padding byte is only needed if the first real byte has its MSB set

      bytes[0] = 0x00; // padding byte
      final start = (bytes[1] & 0x80 != 0) ? 0 : 1; // use padding byte or not

      return bytes.sublist(start);
    } else {
      // Negative multiple precision integer: represent as twos-complement

      final x = (value.abs() - BigInt.one).bitLength + 1;
      var bytesToHoldTwosComplement = x ~/ 8;
      if (x % 8 != 0) {
        bytesToHoldTwosComplement += 1; // to hold additional bits
      }
      assert(0 < bytesToHoldTwosComplement);

      final msbContrib = BigInt.two.pow((bytesToHoldTwosComplement * 8) - 1);
      var e = value + msbContrib; // without negative MSB contribution
      assert(!e.isNegative);

      final numBytes = bytesToHoldTwosComplement + 1;
      final bytes = Uint8List(numBytes);

      // Encode e using ones-complement, starting with the
      // least-significant-byte
      // (the right most byte and working back to the beginning)

      var i = numBytes - 1;

      while (1 <= i) {
        final b = (e & BigInt.from(0xFF)); // least significant byte, bit-neg
        e = e >> 8;
        bytes[i--] = b.toInt();
      }
      assert(e == BigInt.zero);

      // Incorporate negative 2 ^ (N - 1) factor

      if (bytes[1] & 0x80 != 0x80) {
        // MSB on first byte is not set: can use it for the MSB
        bytes[1] |= 0x80; // set the MSB on the first byte
        return bytes.sublist(1); // result without the extra padding byte
      } else {
        // MSB on first byte is already set: need to use the padding byte
        bytes[0] = 0x80; // set the MSB on padding byte and zero the rest of it
        return bytes; // result is the padding byte and the other bytes
      }
    }
  }
}
