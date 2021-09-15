/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

/*

import 'package:multicast_dns/multicast_dns.dart';

Future<void> main() async {
  // Parse the command line arguments.

  var name = '_dartobservatory._tcp.local';
  name = '_gitjournal._tcp';
  name = '_bonsoirdemo._tcp';
  final MDnsClient client = MDnsClient();
  // Start the client with default options.
  await client.start();

  print("Client started");

  //var query = ResourceRecordQuery.serverPointer(name);
  var query = ResourceRecordQuery.serverPointer(name);

  // Get the PTR recod for the service.
  await for (var ptr in client.lookup<PtrResourceRecord>(query)) {
    print("Got ptr $ptr");
    // Use the domainName from the PTR record to get the SRV record,
    // which will have the port and local hostname.
    // Note that duplicate messages may come through, especially if any
    // other mDNS queries are running elsewhere on the machine.
    await for (SrvResourceRecord srv in client.lookup<SrvResourceRecord>(
        ResourceRecordQuery.service(ptr.domainName))) {
      // Domain name will be something like
      // - "io.flutter.example@some-iphone.local._dartobservatory._tcp.local"
      final String bundleId =
          ptr.domainName; //.substring(0, ptr.domainName.indexOf('@'));
      print('Dart observatory instance found at '
          '${srv.target}:${srv.port} for "$bundleId".');
    }
  }
  client.stop();

  print('Done.');
}

// Use connectivity plugin to get ssid info when connected to the wifi network
// https://stackoverflow.com/questions/55716751/flutter-ios-reading-wifi-name-using-the-connectivity-or-wifi-plugin/55732656#55732656

// Use the WorkManager in Android to do the syncing in the background
// -> This should be configurable if we want to be able to sync in the background

// TODO:
// * I don't know if/how I can run an HTTP Server in the Background
//   Is that still possible with current Android Versions?

*/
