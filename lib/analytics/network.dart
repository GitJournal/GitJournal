/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:grpc/grpc.dart';

import 'package:gitjournal/.env.dart';
import 'package:gitjournal/analytics/generated/analytics.pbgrpc.dart';
import 'package:gitjournal/utils/result.dart';
import 'generated/analytics.pb.dart' as pb;

import 'package:dio/dio.dart';

const _port = 443;
const _timeout = Duration(seconds: 120);

var dio = Dio();

Future<Result<void>> sendAnalytics(pb.AnalyticsMessage msg) async {
  try {
    await dio.post(
      Env.analyticsUrl,
      data: msg.writeToJson(),
      options: Options(
        headers: {Headers.contentTypeHeader: "application/json"},
      ),
    );
  } catch (ex, st) {
    return Result.fail(ex, st);
  }

  return Result(null);
}
