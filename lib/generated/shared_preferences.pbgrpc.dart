// SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

///
//  Generated code. Do not modify.
//  source: shared_preferences.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;

import 'shared_preferences.pb.dart' as $0;

export 'shared_preferences.pb.dart';

class SharedPreferencesClient extends $grpc.Client {
  static final _$getKeys =
      $grpc.ClientMethod<$0.EmptyMessage, $0.StringListMessage>(
          '/gitjournal.SharedPreferences/GetKeys',
          ($0.EmptyMessage value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.StringListMessage.fromBuffer(value));
  static final _$getBool =
      $grpc.ClientMethod<$0.StringMessage, $0.OptionalBool>(
          '/gitjournal.SharedPreferences/GetBool',
          ($0.StringMessage value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.OptionalBool.fromBuffer(value));
  static final _$getInt = $grpc.ClientMethod<$0.StringMessage, $0.OptionalInt>(
      '/gitjournal.SharedPreferences/GetInt',
      ($0.StringMessage value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.OptionalInt.fromBuffer(value));
  static final _$getDouble =
      $grpc.ClientMethod<$0.StringMessage, $0.OptionalDouble>(
          '/gitjournal.SharedPreferences/GetDouble',
          ($0.StringMessage value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.OptionalDouble.fromBuffer(value));
  static final _$getString =
      $grpc.ClientMethod<$0.StringMessage, $0.OptionalString>(
          '/gitjournal.SharedPreferences/GetString',
          ($0.StringMessage value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.OptionalString.fromBuffer(value));
  static final _$getStringList =
      $grpc.ClientMethod<$0.StringMessage, $0.StringListMessage>(
          '/gitjournal.SharedPreferences/GetStringList',
          ($0.StringMessage value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.StringListMessage.fromBuffer(value));
  static final _$containsKey =
      $grpc.ClientMethod<$0.StringMessage, $0.BoolMessage>(
          '/gitjournal.SharedPreferences/ContainsKey',
          ($0.StringMessage value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.BoolMessage.fromBuffer(value));
  static final _$setBool =
      $grpc.ClientMethod<$0.SetBoolRequest, $0.BoolMessage>(
          '/gitjournal.SharedPreferences/SetBool',
          ($0.SetBoolRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.BoolMessage.fromBuffer(value));
  static final _$setInt = $grpc.ClientMethod<$0.SetIntRequest, $0.BoolMessage>(
      '/gitjournal.SharedPreferences/SetInt',
      ($0.SetIntRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.BoolMessage.fromBuffer(value));
  static final _$setDouble =
      $grpc.ClientMethod<$0.SetDoubleRequest, $0.BoolMessage>(
          '/gitjournal.SharedPreferences/SetDouble',
          ($0.SetDoubleRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.BoolMessage.fromBuffer(value));
  static final _$setString =
      $grpc.ClientMethod<$0.SetStringRequest, $0.BoolMessage>(
          '/gitjournal.SharedPreferences/SetString',
          ($0.SetStringRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.BoolMessage.fromBuffer(value));
  static final _$setStringList =
      $grpc.ClientMethod<$0.SetStringListRequest, $0.BoolMessage>(
          '/gitjournal.SharedPreferences/SetStringList',
          ($0.SetStringListRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.BoolMessage.fromBuffer(value));
  static final _$remove = $grpc.ClientMethod<$0.StringMessage, $0.BoolMessage>(
      '/gitjournal.SharedPreferences/Remove',
      ($0.StringMessage value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.BoolMessage.fromBuffer(value));

  SharedPreferencesClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.StringListMessage> getKeys($0.EmptyMessage request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getKeys, request, options: options);
  }

  $grpc.ResponseFuture<$0.OptionalBool> getBool($0.StringMessage request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getBool, request, options: options);
  }

  $grpc.ResponseFuture<$0.OptionalInt> getInt($0.StringMessage request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getInt, request, options: options);
  }

  $grpc.ResponseFuture<$0.OptionalDouble> getDouble($0.StringMessage request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getDouble, request, options: options);
  }

  $grpc.ResponseFuture<$0.OptionalString> getString($0.StringMessage request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getString, request, options: options);
  }

  $grpc.ResponseFuture<$0.StringListMessage> getStringList(
      $0.StringMessage request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getStringList, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolMessage> containsKey($0.StringMessage request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$containsKey, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolMessage> setBool($0.SetBoolRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$setBool, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolMessage> setInt($0.SetIntRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$setInt, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolMessage> setDouble($0.SetDoubleRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$setDouble, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolMessage> setString($0.SetStringRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$setString, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolMessage> setStringList(
      $0.SetStringListRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$setStringList, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolMessage> remove($0.StringMessage request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$remove, request, options: options);
  }
}

abstract class SharedPreferencesServiceBase extends $grpc.Service {
  $core.String get $name => 'gitjournal.SharedPreferences';

  SharedPreferencesServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.EmptyMessage, $0.StringListMessage>(
        'GetKeys',
        getKeys_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.EmptyMessage.fromBuffer(value),
        ($0.StringListMessage value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StringMessage, $0.OptionalBool>(
        'GetBool',
        getBool_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.StringMessage.fromBuffer(value),
        ($0.OptionalBool value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StringMessage, $0.OptionalInt>(
        'GetInt',
        getInt_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.StringMessage.fromBuffer(value),
        ($0.OptionalInt value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StringMessage, $0.OptionalDouble>(
        'GetDouble',
        getDouble_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.StringMessage.fromBuffer(value),
        ($0.OptionalDouble value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StringMessage, $0.OptionalString>(
        'GetString',
        getString_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.StringMessage.fromBuffer(value),
        ($0.OptionalString value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StringMessage, $0.StringListMessage>(
        'GetStringList',
        getStringList_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.StringMessage.fromBuffer(value),
        ($0.StringListMessage value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StringMessage, $0.BoolMessage>(
        'ContainsKey',
        containsKey_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.StringMessage.fromBuffer(value),
        ($0.BoolMessage value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetBoolRequest, $0.BoolMessage>(
        'SetBool',
        setBool_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetBoolRequest.fromBuffer(value),
        ($0.BoolMessage value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetIntRequest, $0.BoolMessage>(
        'SetInt',
        setInt_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetIntRequest.fromBuffer(value),
        ($0.BoolMessage value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetDoubleRequest, $0.BoolMessage>(
        'SetDouble',
        setDouble_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetDoubleRequest.fromBuffer(value),
        ($0.BoolMessage value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetStringRequest, $0.BoolMessage>(
        'SetString',
        setString_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetStringRequest.fromBuffer(value),
        ($0.BoolMessage value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetStringListRequest, $0.BoolMessage>(
        'SetStringList',
        setStringList_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetStringListRequest.fromBuffer(value),
        ($0.BoolMessage value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StringMessage, $0.BoolMessage>(
        'Remove',
        remove_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.StringMessage.fromBuffer(value),
        ($0.BoolMessage value) => value.writeToBuffer()));
  }

  $async.Future<$0.StringListMessage> getKeys_Pre(
      $grpc.ServiceCall call, $async.Future<$0.EmptyMessage> request) async {
    return getKeys(call, await request);
  }

  $async.Future<$0.OptionalBool> getBool_Pre(
      $grpc.ServiceCall call, $async.Future<$0.StringMessage> request) async {
    return getBool(call, await request);
  }

  $async.Future<$0.OptionalInt> getInt_Pre(
      $grpc.ServiceCall call, $async.Future<$0.StringMessage> request) async {
    return getInt(call, await request);
  }

  $async.Future<$0.OptionalDouble> getDouble_Pre(
      $grpc.ServiceCall call, $async.Future<$0.StringMessage> request) async {
    return getDouble(call, await request);
  }

  $async.Future<$0.OptionalString> getString_Pre(
      $grpc.ServiceCall call, $async.Future<$0.StringMessage> request) async {
    return getString(call, await request);
  }

  $async.Future<$0.StringListMessage> getStringList_Pre(
      $grpc.ServiceCall call, $async.Future<$0.StringMessage> request) async {
    return getStringList(call, await request);
  }

  $async.Future<$0.BoolMessage> containsKey_Pre(
      $grpc.ServiceCall call, $async.Future<$0.StringMessage> request) async {
    return containsKey(call, await request);
  }

  $async.Future<$0.BoolMessage> setBool_Pre(
      $grpc.ServiceCall call, $async.Future<$0.SetBoolRequest> request) async {
    return setBool(call, await request);
  }

  $async.Future<$0.BoolMessage> setInt_Pre(
      $grpc.ServiceCall call, $async.Future<$0.SetIntRequest> request) async {
    return setInt(call, await request);
  }

  $async.Future<$0.BoolMessage> setDouble_Pre($grpc.ServiceCall call,
      $async.Future<$0.SetDoubleRequest> request) async {
    return setDouble(call, await request);
  }

  $async.Future<$0.BoolMessage> setString_Pre($grpc.ServiceCall call,
      $async.Future<$0.SetStringRequest> request) async {
    return setString(call, await request);
  }

  $async.Future<$0.BoolMessage> setStringList_Pre($grpc.ServiceCall call,
      $async.Future<$0.SetStringListRequest> request) async {
    return setStringList(call, await request);
  }

  $async.Future<$0.BoolMessage> remove_Pre(
      $grpc.ServiceCall call, $async.Future<$0.StringMessage> request) async {
    return remove(call, await request);
  }

  $async.Future<$0.StringListMessage> getKeys(
      $grpc.ServiceCall call, $0.EmptyMessage request);
  $async.Future<$0.OptionalBool> getBool(
      $grpc.ServiceCall call, $0.StringMessage request);
  $async.Future<$0.OptionalInt> getInt(
      $grpc.ServiceCall call, $0.StringMessage request);
  $async.Future<$0.OptionalDouble> getDouble(
      $grpc.ServiceCall call, $0.StringMessage request);
  $async.Future<$0.OptionalString> getString(
      $grpc.ServiceCall call, $0.StringMessage request);
  $async.Future<$0.StringListMessage> getStringList(
      $grpc.ServiceCall call, $0.StringMessage request);
  $async.Future<$0.BoolMessage> containsKey(
      $grpc.ServiceCall call, $0.StringMessage request);
  $async.Future<$0.BoolMessage> setBool(
      $grpc.ServiceCall call, $0.SetBoolRequest request);
  $async.Future<$0.BoolMessage> setInt(
      $grpc.ServiceCall call, $0.SetIntRequest request);
  $async.Future<$0.BoolMessage> setDouble(
      $grpc.ServiceCall call, $0.SetDoubleRequest request);
  $async.Future<$0.BoolMessage> setString(
      $grpc.ServiceCall call, $0.SetStringRequest request);
  $async.Future<$0.BoolMessage> setStringList(
      $grpc.ServiceCall call, $0.SetStringListRequest request);
  $async.Future<$0.BoolMessage> remove(
      $grpc.ServiceCall call, $0.StringMessage request);
}
