/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

// import 'dart:async';

// import 'package:flutter/material.dart';

// import 'package:background_fetch/background_fetch.dart';

// [Android-only] This "Headless Task" is run when the Android app
// is terminated with enableHeadless: true
// void backgroundFetchHeadlessTask(HeadlessTask task) async {
//   String taskId = task.taskId;
//   bool isTimeout = task.timeout;
//   if (isTimeout) {
//     // This task has exceeded its allowed running-time.
//     // You must stop what you're doing and immediately .finish(taskId)
//     print("[BackgroundFetch] Headless task timed-out: $taskId");
//     BackgroundFetch.finish(taskId);
//     return;
//   }
//   print('[BackgroundFetch] Headless event received.');
//   // Do your work here...
//   BackgroundFetch.finish(taskId);
// }

// void main() {
//   // Enable integration testing with the Flutter Driver extension.
//   // See https://flutter.io/testing/ for more info.
//   runApp(MyApp());

//   // Register to receive BackgroundFetch events after app is terminated.
//   // Requires {stopOnTerminate: false, enableHeadless: true}
//   BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   bool _enabled = true;
//   int _status = 0;
//   final List<DateTime> _events = [];

//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlatformState() async {
//     // Configure BackgroundFetch.
//     int status = await BackgroundFetch.configure(
//         BackgroundFetchConfig(
//             minimumFetchInterval: 15,
//             stopOnTerminate: false,
//             enableHeadless: true,
//             requiresBatteryNotLow: false,
//             requiresCharging: false,
//             requiresStorageNotLow: false,
//             requiresDeviceIdle: false,
//             requiredNetworkType: NetworkType.NONE), (String taskId) async {
//       // <-- Event handler
//       // This is the fetch-event callback.
//       print("[BackgroundFetch] Event received $taskId");
//       setState(() {
//         _events.insert(0, DateTime.now());
//       });
//       // IMPORTANT:  You must signal completion of your task or the OS can punish your app
//       // for taking too long in the background.
//       BackgroundFetch.finish(taskId);
//     }, (String taskId) async {
//       // <-- Task timeout handler.
//       // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
//       print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
//       BackgroundFetch.finish(taskId);
//     });
//     print('[BackgroundFetch] configure success: $status');
//     setState(() {
//       _status = status;
//     });

//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;
//   }

//   void _onClickEnable(enabled) {
//     setState(() {
//       _enabled = enabled;
//     });
//     if (enabled) {
//       BackgroundFetch.start().then((int status) {
//         print('[BackgroundFetch] start success: $status');
//       }).catchError((e) {
//         print('[BackgroundFetch] start FAILURE: $e');
//       });
//     } else {
//       BackgroundFetch.stop().then((int status) {
//         print('[BackgroundFetch] stop success: $status');
//       });
//     }
//   }

//   void _onClickStatus() async {
//     int status = await BackgroundFetch.status;
//     print('[BackgroundFetch] status: $status');
//     setState(() {
//       _status = status;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//             title: const Text('BackgroundFetch Example',
//                 style: TextStyle(color: Colors.black)),
//             backgroundColor: Colors.amberAccent,
//             actions: <Widget>[
//               Switch(value: _enabled, onChanged: _onClickEnable),
//             ]),
//         body: Container(
//           color: Colors.black,
//           child: ListView.builder(
//               itemCount: _events.length,
//               itemBuilder: (BuildContext context, int index) {
//                 DateTime timestamp = _events[index];
//                 return InputDecorator(
//                     decoration: const InputDecoration(
//                         contentPadding:
//                             EdgeInsets.only(left: 10.0, top: 10.0, bottom: 0.0),
//                         labelStyle: TextStyle(
//                             color: Colors.amberAccent, fontSize: 20.0),
//                         labelText: "[background fetch event]"),
//                     child: Text(timestamp.toString(),
//                         style: const TextStyle(
//                             color: Colors.white, fontSize: 16.0)));
//               }),
//         ),
//         bottomNavigationBar: BottomAppBar(
//             child: Row(children: <Widget>[
//           ElevatedButton(
//               onPressed: _onClickStatus, child: const Text('Status')),
//           Container(
//               child: Text("$_status"),
//               margin: const EdgeInsets.only(left: 20.0))
//         ])),
//       ),
//     );
//   }
// }

// Stuff to be saved -
// (gitRepo, remoteName, lastSyncedWhen, lastError)
