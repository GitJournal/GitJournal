/*

import 'dart:async';
import 'dart:convert';

import 'package:crypton/crypton.dart';
import 'package:meta/meta.dart';

import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/ssh/binary_length_value.dart';
import 'package:gitjournal/utils/logger.dart';

class RsaKeyPair {
  RSAPublicKey publicKey;
  RSAPrivateKey privateKey;

  RsaKeyPair.fromStrings({
    @required String privateKey,
    @required String publicKey,
  }) {
    publicKey = publicKey.trim();
    try {
      var key = ssh_key.publicKeyDecode(publicKey);
      if (key is ssh_key.RSAPublicKeyWithInfo) {
        this.publicKey = RSAPublicKey(key.modulus, key.exponent);
      }
    } catch (e) {
      print(e);
    }

    if (publicKey == null) {
      try {
        this.publicKey = RSAPublicKey.fromString(publicKey);
      } catch (e) {
        print(e);
      }
    }

    try {
      var key = ssh_key.privateKeyDecode(privateKey);
      if (key is ssh_key.RSAPrivateKeyWithInfo) {
        this.privateKey =
            RSAPrivateKey(key.modulus, key.exponent, key.p, key.q);
      }
    } catch (e) {
      print(e);
    }

    if (privateKey == null) {
      try {
        this.privateKey = RSAPrivateKey.fromPEM(privateKey);
      } catch (e) {
        print(e);
      }
    }

    if (privateKey == null) {
      try {
        this.privateKey = RSAPrivateKey.fromString(privateKey);
      } catch (e) {
        print(e);
      }
    }
  }

  RsaKeyPair.generate() {
    var keyPair = RSAKeypair.fromRandom(keySize: 4096);

    publicKey = keyPair.publicKey;
    privateKey = keyPair.privateKey;
  }

  // Tries to encrypt and decrypt
  bool isValid() {
    if (publicKey == null || privateKey == null) {
      return false;
    }
    var orig = 'word';
    var enc = publicKey.encrypt(orig);
    var dec = privateKey.decrypt(enc);

    return orig == dec;
  }

  // OpenSSH Public Key (single-line format)
  String publicKeyString({String comment = ""}) {
    var pk = publicKey.asPointyCastle;

    var data = BinaryLengthValue.encode([
      BinaryLengthValue.fromString("ssh-rsa"),
      BinaryLengthValue.fromBigInt(pk.exponent),
      BinaryLengthValue.fromBigInt(pk.modulus),
    ]);

    if (comment.isNotEmpty) {
      comment = comment.replaceAll('\r', ' ');
      comment = comment.replaceAll('\n', ' ');
      comment = ' $comment';
    }

    return 'ssh-rsa ${base64.encode(data)}$comment';
  }

  String privateKeyString() {
    return privateKey.toPEM();
  }

  static Future<RsaKeyPair> generateAsync() async {
    IsolateRunner iso = await IsolateRunner.spawn();
    try {
      return await iso.run(_gen, null);
    } catch (e) {
      Log.e(e);
      logException(e, StackTrace.current);
      return null;
    } finally {
      iso.close();
    }
  }
}

FutureOr<RsaKeyPair> _gen(void _) async {
  return RsaKeyPair.generate();
}
*/
