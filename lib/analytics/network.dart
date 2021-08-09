import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';

import 'package:gitjournal/analytics/generated/analytics.pbgrpc.dart';
import 'generated/analytics.pb.dart' as pb;

Future<void> main(List<String> args) async {
  final channel = ClientChannel(
    'https://analyticsbackend-wetu2tkdpq-ew.a.run.app',
    port: 8080,
    options: ChannelOptions(
      // credentials: const ChannelCredentials.insecure(),
      credentials: const ChannelCredentials.secure(),
      codecRegistry: CodecRegistry(codecs: const [
        IdentityCodec(),
        GzipCodec(),
      ]),
    ),
  );

  final stub = AnalyticsServiceClient(channel);
  try {
    var dt = DateTime.now().add(const Duration(days: -1));
    var ev = pb.Event(
      name: 'test',
      date: Int64(dt.millisecondsSinceEpoch ~/ 1000),
      params: {'a': 'hello'},
      pseudoId: 'id',
      userProperties: {'b': 'c'},
      sessionID: 'session',
    );

    var request = AnalyticsMessage(
      appId: 'io.gitjournal',
      events: [ev],
    );
    print("Sending ${request.toDebugString()}");
    var call = stub.sendData(
      request,
      options: CallOptions(timeout: const Duration(seconds: 10)),
    );
    call.headers.then((headers) {
      print('Received header metadata: $headers');
    });
    call.trailers.then((trailers) {
      print('Received trailer metadata: $trailers');
    });
    var response = await call;
    print('Greeter client received: $response');
  } catch (e) {
    print('Caught error: $e');
    return;
  }
  await channel.shutdown();
}
