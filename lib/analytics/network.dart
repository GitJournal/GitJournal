/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:gitjournal/logger/logger.dart';

import 'generated/analytics.pb.dart' as pb;

const _analyticsUrl = "https://analytics-wetu2tkdpq-ew.a.run.app/v1/sendData";

final dio = () {
  var d = Dio();
  d.options.connectTimeout = 10000; // 10 sec
  d.options.receiveTimeout = 10000;

  d.interceptors.add(RetryInterceptor(
    dio: d,
    logPrint: (x) => Log.d(x),
    retries: 3,
    retryDelays: const [
      Duration(seconds: 1),
      Duration(seconds: 5),
      Duration(seconds: 15),
    ],
  ));
  // d.interceptors.add(LogInterceptor(responseBody: true));
  return d;
}();

Future<void> sendAnalytics(pb.AnalyticsMessage msg) async {
  final data = msg.writeToBuffer();
  await dio.post(
    _analyticsUrl,
    // vHanda: Send POST data in DIO is so strange. It seems to mess up the data
    //         if I just pass the Uint8List
    data: Stream.fromIterable(data.map((e) => [e])),
    options: Options(
      contentType: "application/x-protobuf",
      headers: {
        Headers.contentLengthHeader: data.lengthInBytes.toString(),
      },
    ),
  );
}
