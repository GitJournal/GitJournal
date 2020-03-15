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
