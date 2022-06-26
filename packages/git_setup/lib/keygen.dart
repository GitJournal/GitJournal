/*
 * SPDX-FileCopyrightText: 2019-2022 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

class SshKey {
  final String publicKey;
  final String privateKey;
  final String password;
  final SshKeyType type;

  const SshKey({
    required this.publicKey,
    required this.privateKey,
    required this.password,
    required this.type,
  });
}

enum SshKeyType {
  Rsa,
  Ed25519,
}

abstract class Keygen {
  Future<SshKey?> generate({
    required SshKeyType type,
    required String comment,
  });
}
