/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:cryptography/cryptography.dart';
import 'package:openssh_ed25519/openssh_ed25519.dart';

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
