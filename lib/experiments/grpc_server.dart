/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitjournal/generated/shared_preferences.pb.dart';
import 'package:gitjournal/generated/shared_preferences.pbgrpc.dart';

class SharedPreferencesService extends SharedPreferencesServiceBase {
  final SharedPreferences pref;

  SharedPreferencesService(this.pref);

  @override
  Future<BoolMessage> containsKey(ServiceCall _, StringMessage message) async {
    return BoolMessage()..value = pref.containsKey(message.value);
  }

  @override
  Future<StringListMessage> getKeys(ServiceCall _, EmptyMessage __) async {
    return StringListMessage(value: pref.getKeys());
  }

  @override
  Future<OptionalBool> getBool(ServiceCall _, StringMessage key) async {
    return OptionalBool(value: pref.getBool(key.value));
  }

  @override
  Future<OptionalInt> getInt(ServiceCall _, StringMessage key) async {
    var ret = pref.getInt(key.value);
    if (ret != null) {
      return OptionalInt(value: Int64(ret));
    }
    return OptionalInt();
  }

  @override
  Future<OptionalDouble> getDouble(ServiceCall _, StringMessage key) async {
    return OptionalDouble(value: pref.getDouble(key.value));
  }

  @override
  Future<OptionalString> getString(ServiceCall _, StringMessage key) async {
    return OptionalString(value: pref.getString(key.value));
  }

  @override
  Future<StringListMessage> getStringList(
      ServiceCall _, StringMessage key) async {
    return StringListMessage(value: pref.getStringList(key.value));
  }

  @override
  Future<BoolMessage> setBool(ServiceCall _, SetBoolRequest req) async {
    return BoolMessage(value: await pref.setBool(req.key, req.value));
  }

  @override
  Future<BoolMessage> setInt(ServiceCall _, SetIntRequest req) async {
    return BoolMessage(value: await pref.setInt(req.key, req.value.toInt()));
  }

  @override
  Future<BoolMessage> setDouble(ServiceCall _, SetDoubleRequest req) async {
    return BoolMessage(value: await pref.setDouble(req.key, req.value));
  }

  @override
  Future<BoolMessage> setString(ServiceCall _, SetStringRequest req) async {
    return BoolMessage(value: await pref.setString(req.key, req.value));
  }

  @override
  Future<BoolMessage> setStringList(
      ServiceCall _, SetStringListRequest req) async {
    return BoolMessage(value: await pref.setStringList(req.key, req.value));
  }

  @override
  Future<BoolMessage> remove(ServiceCall _, StringMessage key) async {
    return BoolMessage(value: await pref.remove(key.value));
  }
}

Future<void> main(List<String> args) async {
  return runApp(MyApp());
}

// todo: Create some kind of QR code for getting the IP and hostname

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    _initAsync();
  }

  Future<void> _initAsync() async {
    var pref = await SharedPreferences.getInstance();
    final server = Server(
      [SharedPreferencesService(pref)],
      const <Interceptor>[],
      CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
    );
    await server.serve(port: 50052);
    print('Server listening on port ${server.port}...');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Flutter'),
        ),
        body: const Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}
