import 'package:dart_git/utils/result.dart';
import 'package:grpc/grpc.dart';

import 'package:gitjournal/analytics/generated/analytics.pbgrpc.dart';
import 'generated/analytics.pb.dart' as pb;

const _url = 'analyticsbackend-wetu2tkdpq-ew.a.run.app';
const _port = 444;
const _timeout = Duration(seconds: 30);

Future<Result<void>> sendAnalytics(pb.AnalyticsMessage msg) async {
  final channel = ClientChannel(
    _url,
    port: _port,
    options: ChannelOptions(
      // credentials: const ChannelCredentials.insecure(),
      credentials: const ChannelCredentials.secure(),
      codecRegistry: CodecRegistry(codecs: const [
        IdentityCodec(),
        GzipCodec(),
      ]),
    ),
  );

  final client = AnalyticsServiceClient(channel);
  try {
    var call = client.sendData(
      msg,
      options: CallOptions(
        timeout: _timeout,
        compression: const GzipCodec(),
      ),
    );
    await call;
  } on Exception catch (e, st) {
    await channel.shutdown();
    return Result.fail(e, st);
  }

  await channel.shutdown();
  return Result(null);
}
