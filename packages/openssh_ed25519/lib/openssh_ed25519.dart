/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

// Code adapted from https://github.com/mikesmitty/edkey

// library openssh_ed25519;

import 'dart:convert';
import 'dart:math' as math;

import 'ssh.dart';

var _keyName = 'ssh-ed25519';

String encodeEd25519Public(List<int> bytes, [String comment = ""]) {
  assert(bytes.length == 32);

  var buf = StringBuffer();
  buf.write(_keyName);
  buf.write(' ');

  var key = <int>[];
  key.addAll(SshFormat.encodeString(_keyName));
  key.addAll(SshFormat.encodeBytes(bytes));

  buf.write('' + base64.encode(key));
  if (comment.isNotEmpty) {
    buf.write(" ");
    buf.write(comment);
  }
  buf.write('\n');

  var r = buf.toString();
  if (comment.isEmpty) {
    assert(r.length == 81);
  }
  return r;
}

String encodeEd25519Private({
  required List<int> privateBytes,
  required List<int> publicBytes,
  int? nonce,
}) {
  var data = encodeEd25519PrivateToKey(
    privateBytes: privateBytes,
    publicBytes: publicBytes,
    nonce: nonce,
  );

  return _encodePem('OPENSSH PRIVATE KEY', data);
}

List<int> encodeEd25519PrivateToKey({
  required List<int> privateBytes,
  required List<int> publicBytes,
  int? nonce,
}) {
  assert(privateBytes.length == 32);
  assert(publicBytes.length == 32);

  var fullPrivate = <int>[];
  fullPrivate.addAll(privateBytes);
  fullPrivate.addAll(publicBytes);

  assert(fullPrivate.length == 64);

  // pk1

  // Check1  uint32
  // Check2  uint32
  // Keytype string
  // Pub     []byte
  // Priv    []byte
  // Comment string
  // Pad     []byte `ssh:"rest"`

  var check = nonce ?? math.Random().nextInt(1 << 32);

  var pk1 = <int>[];
  pk1.addAll(SshFormat.encodeUInt32(check));
  pk1.addAll(SshFormat.encodeUInt32(check));
  pk1.addAll(SshFormat.encodeString(_keyName));
  pk1.addAll(SshFormat.encodeBytes(publicBytes));
  pk1.addAll(SshFormat.encodeBytes(fullPrivate));
  pk1.addAll(SshFormat.encodeBytes([])); // empty comment

  assert(pk1.length == 131);

  var bs = 8;
  var blockLen = pk1.length;
  var padLength = (bs - (blockLen % bs)) % bs;

  var padding = <int>[];

  // Padding is a sequence of bytes like: 1, 2, 3...
  for (var i = 0; i < padLength; i++) {
    padding.add(i + 1);
  }
  pk1.addAll(padding);

  assert(pk1.length == 136);

  // w.CipherName = "none"
  // w.KdfName = "none"
  // w.KdfOpts = ""
  // w.NumKeys = 1
  // w.PubKey = append(prefix, pubKey...)
  // w.PrivKeyBlock = ssh.Marshal(pk1)

  // Generate the pubkey prefix "\0\0\0\nssh-ed25519\0\0\0 "
  var prefix = <int>[];
  prefix.addAll([0x0, 0x0, 0x0, 0x0b]);
  prefix.addAll(utf8.encode(_keyName));
  prefix.addAll([0x0, 0x0, 0x0, 0x20]);

  assert(prefix.length == 19);

  var output = <int>[];
  output.addAll(utf8.encode("openssh-key-v1"));
  output.add(0);
  assert(output.length == 15);

  output.addAll(SshFormat.encodeString("none"));
  output.addAll(SshFormat.encodeString("none"));
  output.addAll(SshFormat.encodeString(""));
  output.addAll(SshFormat.encodeUInt32(1));
  output.addAll(SshFormat.encodeBytes([...prefix, ...publicBytes]));
  output.addAll(SshFormat.encodeBytes(pk1));

  assert(output.length == 234);
  return output;
}

String _encodePem(String label, List<int> data) {
  final s = StringBuffer();

  s.writeln('-----BEGIN $label-----');
  final lines = base64.encode(data);
  for (var i = 0; i < lines.length; i += 64) {
    s.writeln(lines.substring(i, math.min(lines.length, i + 64)));
  }
  s.writeln('-----END $label-----');
  return s.toString();
}
