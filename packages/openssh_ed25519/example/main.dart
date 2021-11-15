/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:openssh_ed25519/openssh_ed25519.dart';

Future<void> main() async {
  final keyPair = await Ed25519().newKeyPair();

  var privateBytes = await keyPair.extractPrivateKeyBytes();
  var public = await keyPair.extractPublicKey();
  var publicBytes = public.bytes;

  var publicStr = encodeEd25519Public(publicBytes);
  var privateStr = encodeEd25519Private(
    privateBytes: privateBytes,
    publicBytes: publicBytes,
  );

  await File('id_ed25519.pub').writeAsString(publicStr);
  await File('id_ed25519').writeAsString(privateStr);
}
