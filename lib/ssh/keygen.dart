import 'package:meta/meta.dart';

import 'package:gitjournal/ssh/rsa_key_pair.dart';
import 'package:gitjournal/utils/logger.dart';

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

Future<SshKey> generateSSHKeys({@required String comment}) async {
  try {
    var stopwatch = Stopwatch()..start();
    var keyPair = await RsaKeyPair.generateAsync();
    Log.i("Generating KeyPair took: ${stopwatch.elapsed}");

    return SshKey(
      publicKey: keyPair.publicKeyString(comment: comment),
      privateKey: keyPair.privateKeyString(),
      password: "",
    );
  } catch (e) {
    Log.e(e);
  }

  return null;
}
