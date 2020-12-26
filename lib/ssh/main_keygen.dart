import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';

import './binary_length_value.dart';

void main() async {
  print("Generating new random key");
  final keyPair = await ed25519.newKeyPair();

  var publicKey = keyPair.publicKey;
  var privateKey = keyPair.privateKey;

  var publicKeyStr = publicKeyString(publicKey.bytes);
  var privateKeyStr = ""; //keyPair.privateKeyString();

  print(privateKey);

  var keyName = "key_";
  var num = 0;
  while (File(keyName + num.toString()).existsSync()) {
    num++;
  }

  print("Writing public key to key_$num.pub");
  print("Writing private key to key_$num");

  File("key_$num.pub").writeAsStringSync(publicKeyStr + '\n');
  File("key_$num").writeAsStringSync(privateKeyStr + '\n');
}

String publicKeyString(List<int> publicKeyBytes, {String comment = ""}) {
  var data = BinaryLengthValue.encode([
    BinaryLengthValue.fromString("ssh-ed25519"),
    BinaryLengthValue(publicKeyBytes),
  ]);

  if (comment.isNotEmpty) {
    comment = comment.replaceAll('\r', ' ');
    comment = comment.replaceAll('\n', ' ');
    comment = ' $comment';
  }

  return 'ssh-ed25519 ${base64.encode(data)}$comment';
}

String privateKeyString() {
  var str = '-----BEGIN OPENSSH PRIVATE KEY-----\n';
  return str;
}

// Either the openssl code or the openssh-portable code
// or some go code
// -> https://golang.org/src/crypto/x509/pkcs8.go

// Key format is PKCS8 or OpenSSH.
