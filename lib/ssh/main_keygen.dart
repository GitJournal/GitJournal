import 'dart:io';

import 'package:gitjournal/ssh/rsa_key_pair.dart';

void main() {
  print("Generating new random key");
  var keyPair = RsaKeyPair.generate();
  var publicKeyStr = keyPair.publicKeyString(comment: "No Comment");
  var privateKeyStr = keyPair.privateKeyString();

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
