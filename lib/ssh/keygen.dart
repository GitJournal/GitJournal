/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:git_bindings/git_bindings.dart' as gb;
import 'package:openssh_ed25519/openssh_ed25519.dart';
import 'package:path/path.dart' as p;

import 'package:gitjournal/logger/logger.dart';

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

Future<SshKey?> generateSSHKeys({required String comment}) async {
  if (Platform.isIOS) return generateSSHKeysRsa(comment: comment);
  return generateSSHKeysEd25519(comment: comment);
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

  return SshKey(publicKey: publicStr, privateKey: privateStr, password: "");
}

Future<SshKey?> generateSSHKeysRsa({required String comment}) async {
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
    Log.i("Generating RSA KeyPair took: ${stopwatch.elapsed}");

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
