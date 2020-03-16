import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:steel_crypt/PointyCastleN/key_generators/rsa_key_generator.dart';
import 'package:steel_crypt/PointyCastleN/pointycastle.dart';
import 'package:steel_crypt/PointyCastleN/random/fortuna_random.dart';
import 'package:steel_crypt/steel_crypt.dart';

void main() {
  var encrypter = RsaCrypt();
  var keyPair = _getRsaKeyPair(_getSecureRandom());
  var publicKey = keyPair.publicKey as RSAPublicKey;
  var privateKey = keyPair.privateKey as RSAPrivateKey;

  var crypted4 = encrypter.encrypt('word', keyPair.publicKey);
  print("Encryped: $crypted4");
  print("Decrypted: " + encrypter.decrypt(crypted4, keyPair.privateKey));

  var ps = encrypter.encodeKeyToString(publicKey);
  print("PS: $ps");

  var priv = encrypter.encodeKeyToString(privateKey);
  print("Priv: $priv");

  print("");
  var s = output(publicKey, "vish");
  print(s);
}

SecureRandom _getSecureRandom() {
  final secureRandom = FortunaRandom();
  final random = Random.secure();
  var seeds = List<int>.of([]);
  for (var i = 0; i < 32; i++) {
    seeds.add(random.nextInt(255));
  }
  secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
  return secureRandom;
}

///Create RSA keypair given SecureRandom.
AsymmetricKeyPair<PublicKey, PrivateKey> _getRsaKeyPair(
  SecureRandom secureRandom,
) {
  // See URL for why these values
  // https://crypto.stackexchange.com/questions/15449/rsa-key-generation-parameters-public-exponent-certainty-string-to-key-count/15450#15450?newreg=e734eafab61e42f1b155b62839ccce8f
  final rsapars = RSAKeyGeneratorParameters(BigInt.from(65537), 2048 * 2, 5);
  final params = ParametersWithRandom(rsapars, secureRandom);
  final keyGenerator = RSAKeyGenerator();
  keyGenerator.init(params);
  return keyGenerator.generateKeyPair();
}

String output(RSAPublicKey key, String comment) {
  var data = BinaryLengthValue.encode([
    BinaryLengthValue.fromString("ssh-rsa"),
    BinaryLengthValue.fromBigInt(key.exponent),
    BinaryLengthValue.fromBigInt(key.modulus),
  ]);

  if (comment.isNotEmpty) {
    comment = comment.replaceAll('\r', ' ');
    comment = comment.replaceAll('\n', ' ');
    comment = ' $comment';
  }

  return 'ssh-rsa ${base64.encode(data)}$comment';
}

/*
     const BIGNUM *pRsa_mod = NULL;
   const BIGNUM *pRsa_exp = NULL;

   RSA_get0_key(pRsa, &pRsa_mod, &pRsa_exp, NULL);

   // reading the modulus
   int nLen = BN_num_bytes(pRsa_mod);
   nBytes = (unsigned char *)malloc(nLen);
   ret = BN_bn2bin(pRsa_mod, nBytes);
   if (ret <= 0)
      goto cleanup;

   // reading the public exponent
   int eLen = BN_num_bytes(pRsa_exp);
   eBytes = (unsigned char *)malloc(eLen);
   if (eBytes == NULL)
   {
      gj_log_internal("write_rsa_public_key malloc failed. Length: %d", eLen);
      ret = -1;
      goto cleanup;
   }
   ret = BN_bn2bin(pRsa_exp, eBytes);
   if (ret <= 0)
      goto cleanup;

   encodingLength = 11 + 4 + eLen + 4 + nLen;
   // correct depending on the MSB of e and N
   if (eBytes[0] & 0x80)
      encodingLength++;
   if (nBytes[0] & 0x80)
      encodingLength++;

   pEncoding = (unsigned char *)malloc(encodingLength);
   memset(pEncoding, 0, encodingLength);
   memcpy(pEncoding, pSshHeader, 11);

   index = SshEncodeBuffer(&pEncoding[11], eLen, eBytes);
   SshEncodeBuffer(&pEncoding[11 + index], nLen, nBytes);

   b64 = BIO_new(BIO_f_base64());
   BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL);

   pFile = fopen(file_path, "w");
   bio = BIO_new_fp(pFile, BIO_CLOSE);
   BIO_printf(bio, "ssh-rsa ");
   bio = BIO_push(b64, bio);
   BIO_write(bio, pEncoding, encodingLength);
   BIO_flush(bio);
   bio = BIO_pop(b64);
   BIO_printf(bio, " %s\n", comment);
   BIO_flush(bio);
   BIO_free_all(bio);
   BIO_free(b64);
   */

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

// FIXME: Also need a parser for this format
// FIXME: Also need tests for this format
// FIXME: Same for the private key format!
//        It's for the openssh format
