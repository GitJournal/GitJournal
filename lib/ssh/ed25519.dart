/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

// Code adapted from https://github.com/mikesmitty/edkey

import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:cryptography/cryptography.dart';

Future<void> main() async {
  final algorithm = Ed25519();
  final keyPair = await algorithm.newKeyPair();

  var privateBytes = Uint8List.fromList(await keyPair.extractPrivateKeyBytes());
  var public = await keyPair.extractPublicKey();
  var publicBytes = Uint8List.fromList(public.bytes);

  // var pemStr = File('test').readAsStringSync();
  // var keyData =
  // PemCodec(PemLabel.privateKey, unsafeIgnoreLabel: true).decode(pemStr);
  // print(keyData);
  // print(keyData.length);

  var pStr = marshallPublic(publicBytes);
  print(pStr);

  // print(buffer);
  // print(ascii.decode(buffer));

  var priv = marshallPrivate(privateBytes, publicBytes);
  var privStr = encodePem("OPENSSH PRIVATE KEY", priv);
  print(privStr);
}

// I need a freaking test for this!!
// How do I do that?
// -> Read the files via golang
//    and print the public and private bytes encoded in base64

var keyName = 'ssh-ed25519';

String marshallPublic(List<int> bytes) {
  var buf = StringBuffer();
  buf.write(keyName);
  buf.write(' ');

  var key = <int>[];
  key.addAll(encodeString(keyName));
  key.addAll(encodeBytes(bytes));

  buf.write('' + base64.encode(key));
  buf.write('\n');

  var r = buf.toString();
  assert(r.length == 81);
  return r;
}

List<int> encodeString(String s) => encodeBytes(utf8.encode(s));

List<int> encodeBytes(List<int> b) {
  var bytes = Uint8List.fromList(b);

  var val = <int>[];
  val.addAll(encodeUInt32(bytes.length));
  val.addAll(bytes);
  return val;
}

Uint8List encodeUInt32(int n) {
  var t = Uint8List(4);
  t[0] = n >> 24;
  t[1] = n >> 16;
  t[2] = n >> 8;
  t[3] = n;

  return t;
}

// Private part
// -> https://github.com/TerminalStudio/dartssh2/blob/67ea524c157afaf271696e599878c760ce65170e/lib/src/pem.dart#L359

List<int> marshallPrivate(List<int> privateBytes, List<int> publicBytes) {
  var fullPrivate = <int>[];
  fullPrivate.addAll(privateBytes);
  fullPrivate.addAll(publicBytes);

  // pk1

  // Check1  uint32
  // Check2  uint32
  // Keytype string
  // Pub     []byte
  // Priv    []byte
  // Comment string
  // Pad     []byte `ssh:"rest"`

  var check = math.Random().nextInt(1 << 32);

  var pk1 = <int>[];
  pk1.addAll(encodeUInt32(check));
  pk1.addAll(encodeUInt32(check));
  pk1.addAll(encodeString(keyName));
  pk1.addAll(encodeBytes(publicBytes));
  pk1.addAll(encodeBytes(fullPrivate));
  pk1.addAll(encodeBytes([])); // empty comment

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
  prefix.addAll(utf8.encode(keyName));
  prefix.addAll([0x0, 0x0, 0x0, 0x20]);

  assert(prefix.length == 19);

  var output = <int>[];
  output.addAll(utf8.encode("openssh-key-v1"));
  output.add(0);
  assert(output.length == 15);

  output.addAll(encodeString("none"));
  output.addAll(encodeString("none"));
  output.addAll(encodeString(""));
  output.addAll(encodeUInt32(1));
  output.addAll(encodeBytes([...prefix, ...publicBytes]));
  output.addAll(encodeBytes(pk1));

  assert(output.length == 234);
  return output;
}

String encodePem(String label, List<int> data) {
  final s = StringBuffer();

  s.writeln('-----BEGIN $label-----');
  final lines = base64.encode(data);
  for (var i = 0; i < lines.length; i += 64) {
    s.writeln(lines.substring(i, math.min(lines.length, i + 64)));
  }
  s.writeln('-----END $label-----');
  return s.toString();
}
