import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:git_bindings/git_bindings.dart' as gb;
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart';

import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/ssh/binary_length_value.dart';

class SshKey {
  final String publicKey;
  final String privateKey;
  final String password;

  const SshKey({
    required this.publicKey,
    required this.privateKey,
    required this.password,
  });
}

final bool useDartKeyGen = false;

Future<SshKey?> generateSSHKeys({required String comment}) async {
  if (Platform.isAndroid || Platform.isIOS) {
    return generateSSHKeysNative(comment: comment);
  } else {
    return generateSSHKeysKeygen(comment: comment);
  }
}

/*
Future<SshKey> generateSSHKeysDart({@required String comment}) async {
  try {
    var stopwatch = Stopwatch()..start();
    var keyPair = await RsaKeyPair.generateAsync();
    Log.i("Generating KeyPair took: ${stopwatch.elapsed}");

    return SshKey(
      publicKey: keyPair.publicKeyString(comment: comment),
      privateKey: keyPair.privateKeyString(),
      password: "",
    );
  } catch (e, st) {
    Log.e("generateSSHKeysDart", ex: e, stacktrace: st);
  }

  return null;
}
*/

Future<SshKey?> generateSSHKeysNative({required String comment}) async {
  try {
    var stopwatch = Stopwatch()..start();
    var dir = await Directory.systemTemp.createTemp('keys');
    var publicKeyPath = p.join(dir.path, 'id_rsa.pub');
    var privateKeyPath = p.join(dir.path, 'id_rsa');

    await gb.generateSSHKeys(
      publicKeyPath: publicKeyPath,
      privateKeyPath: privateKeyPath,
      comment: comment,
    );
    Log.i("Generating KeyPair took: ${stopwatch.elapsed}");

    var all = dir.listSync().map((e) => e.path).toList();
    Log.d("Keys Dir: $all");

    return SshKey(
      publicKey: await File(publicKeyPath).readAsString(),
      privateKey: await File(privateKeyPath).readAsString(),
      password: "",
    );
  } catch (e, st) {
    Log.e("generateSSHKeysNative", ex: e, stacktrace: st);
  }

  return null;
}

Future<SshKey?> generateSSHKeysKeygen({required String comment}) async {
  var privateFile = p.join(Directory.systemTemp.path, 'id_rsa');

  // ssh-keygen -f /tmp/r -t rsa -b 4096 -q -N "" -C 'happy'
  var process = await Process.start('ssh-keygen', [
    '-f',
    privateFile,
    '-t',
    'rsa',
    '-b',
    '4096',
    '-q',
    '-N',
    '',
    '-C',
    comment,
  ]);

  var exitCode = await process.exitCode;
  if (exitCode != 0) {
    // FIXME: Give me an error!
    return null;
  }

  return SshKey(
    publicKey: await File(privateFile + '.pub').readAsString(),
    privateKey: await File(privateFile).readAsString(),
    password: "",
  );
}

Future<SshKey> generateSSHEccKeys({required String comment}) async {
  print("Generating KeyPair ...");
  var stopwatch = Stopwatch()..start();
  var keyPair = CryptoUtils.generateEcKeyPair(curve: 'secp384r1');
  var publicKey = keyPair.publicKey as ECPublicKey;
  var privateKey = keyPair.privateKey as ECPrivateKey;
  print("Generating KeyPair took: ${stopwatch.elapsed}");

  //var publicPem = CryptoUtils.encodeEcPublicKeyToPem(publicKey);
  var privatePem = CryptoUtils.encodeEcPrivateKeyToPem(privateKey);

  // FIXME: I need to learn to convert from the public key PEM format to ecdsa-sha2-nistp384
  return SshKey(
    publicKey: publicKeyString(publicKey, comment),
    privateKey: privatePem,
    password: "",
  );
}

// https://datatracker.ietf.org/doc/html/rfc5656
String publicKeyString(ECPublicKey publicKey, String comment) {
  var publicPem = CryptoUtils.encodeEcPublicKeyToPem(publicKey);

  print('public PEM');
  print(publicPem);
  print('\n');

  var publicKeyBytes2 = CryptoUtils.getBytesFromPEMString(publicPem);

  var publicKeyBytes = publicKey.Q!.getEncoded(false);
  if (publicKeyBytes != publicKeyBytes2) {
    print("THE BYTES ARE NOT EQAU~L");
  }
  print("HUURAY");

  var data = BinaryLengthValue.encode([
    BinaryLengthValue.fromString("ecdsa-sha2-nistp384"),
    BinaryLengthValue(publicKeyBytes),
  ]);

  if (comment.isNotEmpty) {
    comment = comment.replaceAll('\r', ' ');
    comment = comment.replaceAll('\n', ' ');
    comment = ' $comment';
  }

  return 'ecdsa-sha2-nistp384 ${base64.encode(data)}$comment';
}
