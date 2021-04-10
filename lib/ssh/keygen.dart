// @dart=2.9

import 'dart:io';

import 'package:git_bindings/git_bindings.dart' as gb;
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'package:gitjournal/utils/logger.dart';

// import 'package:gitjournal/ssh/rsa_key_pair.dart';

class SshKey {
  final String publicKey;
  final String privateKey;
  final String password;

  const SshKey({
    @required this.publicKey,
    @required this.privateKey,
    @required this.password,
  });
}

final bool useDartKeyGen = false;

Future<SshKey> generateSSHKeys({@required String comment}) async {
  if (useDartKeyGen) {
    //return generateSSHKeysDart(comment: comment);
  } else {}
  return generateSSHKeysNative(comment: comment);
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

Future<SshKey> generateSSHKeysNative({@required String comment}) async {
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
