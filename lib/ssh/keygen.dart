/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:cryptography/cryptography.dart';
import 'package:git_setup/keygen.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:go_git_dart/go_git_dart.dart';
import 'package:openssh_ed25519/openssh_ed25519.dart';

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

    var bindings = GitBindings();
    var (publicKey, privateKey) = bindings.generateRsaKeys();
    Log.i("Generating RSA KeyPair took: ${stopwatch.elapsed}");

    return SshKey(
      publicKey: publicKey,
      privateKey: privateKey,
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
