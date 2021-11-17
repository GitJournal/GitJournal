/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:grpc/grpc.dart';

import 'package:gitjournal/generated/shared_preferences.pb.dart';
import 'package:gitjournal/generated/shared_preferences.pbgrpc.dart';

Future<void> main(List<String> args) async {
  return runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var text = "Empty";

  @override
  void initState() {
    _initAsync();
    super.initState();
  }

  Future<void> _initAsync() async {
    final channel = ClientChannel(
      'localhost',
      port: 50052,
      options: ChannelOptions(
        credentials: const ChannelCredentials.insecure(),
        codecRegistry:
            CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
      ),
    );
    final stub = SharedPreferencesClient(channel);
    var keysResp = await stub.getKeys(EmptyMessage());
    setState(() {
      text = keysResp.value.toString();
    });
    await channel.shutdown();
    // todo: Catch exceptions!
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        body: Center(
          child: Text(text),
        ),
      ),
    );
  }
}
