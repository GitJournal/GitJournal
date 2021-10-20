/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:dart_git/utils/result.dart';
import 'package:grpc/grpc.dart';

import 'package:gitjournal/.env.dart';
import 'package:gitjournal/analytics/generated/analytics.pbgrpc.dart';
import 'generated/analytics.pb.dart' as pb;

const _port = 443;
const _timeout = Duration(seconds: 120);

Future<Result<void>> sendAnalytics(pb.AnalyticsMessage msg) async {
  final channel = ClientChannel(
    Env.analyticsUrl,
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
      options: CallOptions(timeout: _timeout),
    );
    var _ = await call;
  } catch (e, st) {
    await channel.shutdown();
    return Result.fail(e, st);
  }

  await channel.shutdown();
  return Result(null);
}
