/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:cryptography/cryptography.dart';
import 'package:git_bindings/git_bindings.dart' as gb;
import 'package:git_setup/keygen.dart';
import 'package:openssh_ed25519/openssh_ed25519.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart' as io;

import 'package:gitjournal/logger/logger.dart';

class GitJournalKeygen implements Keygen {
  @override
  Future<SshKey?> generate({
    required SshKeyType type,
    required String comment,
  }) {
    switch (type) {
      case SshKeyType.Rsa:
        return generateSSHKeysRsa(comment: comment);
      case SshKeyType.Ed25519:
      default:
        return generateSSHKeysEd25519(comment: comment);
    }
  }
}

Future<SshKey?> generateSSHKeysRsa({required String comment}) async {
  try {
    var stopwatch = Stopwatch()..start();
    var dir = await io.Directory.systemTemp.createTemp('keys');
    var publicKeyPath = p.join(dir.path, 'id_rsa.pub');
    var privateKeyPath = p.join(dir.path, 'id_rsa');

    await gb.generateSSHKeys(
      publicKeyPath: publicKeyPath,
      privateKeyPath: privateKeyPath,
      comment: comment,
    );
    Log.i("Generating RSA KeyPair took: ${stopwatch.elapsed}");

    var all = dir.listSync().map((e) => e.path).toList();
    Log.d("Keys Dir: $all");

    return SshKey(
      publicKey: await io.File(publicKeyPath).readAsString(),
      privateKey: await io.File(privateKeyPath).readAsString(),
      password: "",
      type: SshKeyType.Rsa,
    );
  } catch (e, st) {
    Log.e("generateSSHKeysNative", ex: e, stacktrace: st);
  }

  return null;
}

Future<SshKey?> generateSSHKeysEd25519({required String comment}) async {
  final keyPair = await Ed25519().newKeyPair();

  var privateBytes = await keyPair.extractPrivateKeyBytes();
  var public = await keyPair.extractPublicKey();
  var publicBytes = public.bytes;

  var publicStr = encodeEd25519Public(publicBytes, comment);
  var privateStr = encodeEd25519Private(
    privateBytes: privateBytes,
    publicBytes: publicBytes,
  );

  return SshKey(
    publicKey: publicStr,
    privateKey: privateStr,
    password: "",
    type: SshKeyType.Ed25519,
  );
}
