// SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

///
//  Generated code. Do not modify.
//  source: analytics.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;

import 'analytics.pb.dart' as $0;

export 'analytics.pb.dart';

class AnalyticsServiceClient extends $grpc.Client {
  static final _$sendData =
      $grpc.ClientMethod<$0.AnalyticsMessage, $0.AnalyticsReply>(
          '/gitjournal.AnalyticsService/SendData',
          ($0.AnalyticsMessage value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.AnalyticsReply.fromBuffer(value));

  AnalyticsServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.AnalyticsReply> sendData($0.AnalyticsMessage request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sendData, request, options: options);
  }
}

abstract class AnalyticsServiceBase extends $grpc.Service {
  $core.String get $name => 'gitjournal.AnalyticsService';

  AnalyticsServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.AnalyticsMessage, $0.AnalyticsReply>(
        'SendData',
        sendData_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AnalyticsMessage.fromBuffer(value),
        ($0.AnalyticsReply value) => value.writeToBuffer()));
  }

  $async.Future<$0.AnalyticsReply> sendData_Pre($grpc.ServiceCall call,
      $async.Future<$0.AnalyticsMessage> request) async {
    return sendData(call, await request);
  }

  $async.Future<$0.AnalyticsReply> sendData(
      $grpc.ServiceCall call, $0.AnalyticsMessage request);
}
