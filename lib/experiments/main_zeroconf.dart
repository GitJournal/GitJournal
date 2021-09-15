/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

/*

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:bonsoir/bonsoir.dart';
import 'package:device_info/device_info.dart';
import 'package:provider/provider.dart';
import 'package:universal_io/io.dart';

/// Plugin's main method.
void main() => runApp(BonsoirExampleMainWidget());

/// Allows to get the Bonsoir service corresponding to the current device.
class AppService {
  /// The service type.
  static const String type = '_bonsoirdemo._tcp';

  /// The service port (in this example we're not doing anything on that port but you should).
  static const int port = 4000;

  /// The cached service.
  static BonsoirService? _service;

  /// Returns (and create if needed) the app Bonsoir service.
  static Future<BonsoirService?> getService() async {
    if (_service != null) {
      return _service;
    }

    String name;
    if (Platform.isAndroid) {
      name = (await DeviceInfoPlugin().androidInfo).model;
    } else if (Platform.isIOS) {
      name = (await DeviceInfoPlugin().iosInfo).localizedModel;
    } else {
      name = 'Flutter';
    }
    name += ' Bonsoir Demo';

    _service = BonsoirService(name: name, type: type, port: port);
    return _service;
  }
}

/// Provider model that allows to handle Bonsoir broadcasts.
class BonsoirBroadcastModel extends ChangeNotifier {
  /// The current Bonsoir broadcast object instance.
  BonsoirBroadcast? _bonsoirBroadcast;

  /// Whether Bonsoir is currently broadcasting the app's service.
  bool _isBroadcasting = false;

  /// Returns wether Bonsoir is currently broadcasting the app's service.
  bool get isBroadcasting => _isBroadcasting;

  /// Starts the Bonsoir broadcast.
  Future<void> start({bool notify = true}) async {
    if (_bonsoirBroadcast == null || _bonsoirBroadcast!.isStopped) {
      _bonsoirBroadcast = BonsoirBroadcast(
          service: await (AppService.getService() as FutureOr<BonsoirService>));
      await _bonsoirBroadcast!.ready;
    }

    await _bonsoirBroadcast!.start();
    _isBroadcasting = true;
    if (notify) {
      notifyListeners();
    }
  }

  /// Stops the Bonsoir broadcast.
  void stop({bool notify = true}) {
    _bonsoirBroadcast?.stop();
    _isBroadcasting = false;
    if (notify) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stop(notify: false);
    super.dispose();
  }
}

/// Provider model that allows to handle Bonsoir discoveries.
class BonsoirDiscoveryModel extends ChangeNotifier {
  /// The current Bonsoir discovery object instance.
  BonsoirDiscovery? _bonsoirDiscovery;

  /// Contains all discovered (and resolved) services.
  final List<ResolvedBonsoirService?> _resolvedServices = [];

  /// The subscription object.
  StreamSubscription<BonsoirDiscoveryEvent>? _subscription;

  /// Creates a new Bonsoir discovery model instance.
  BonsoirDiscoveryModel() {
    start();
  }

  /// Returns all discovered (and resolved) services.
  List<ResolvedBonsoirService?> get discoveredServices =>
      List.of(_resolvedServices);

  /// Starts the Bonsoir discovery.
  Future<void> start() async {
    if (_bonsoirDiscovery == null || _bonsoirDiscovery!.isStopped) {
      _bonsoirDiscovery =
          BonsoirDiscovery(type: (await AppService.getService())!.type);
      await _bonsoirDiscovery!.ready;
    }

    await _bonsoirDiscovery!.start();
    _subscription = _bonsoirDiscovery!.eventStream!.listen(_onEventOccurred);
  }

  /// Stops the Bonsoir discovery.
  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _bonsoirDiscovery?.stop();
  }

  /// Triggered when a Bonsoir discovery event occurred.
  void _onEventOccurred(BonsoirDiscoveryEvent event) {
    if (event.service == null || !event.isServiceResolved) {
      return;
    }

    if (event.type == BonsoirDiscoveryEventType.DISCOVERY_SERVICE_RESOLVED) {
      _resolvedServices.add(event.service as ResolvedBonsoirService?);
      notifyListeners();
    } else if (event.type == BonsoirDiscoveryEventType.DISCOVERY_SERVICE_LOST) {
      _resolvedServices.remove(event.service);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

/// Allows to switch the app broadcast state.
class BroadcastSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BonsoirBroadcastModel model = context.watch<BonsoirBroadcastModel>();
    return InkWell(
      onTap: () => _onTap(model),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Broadcast'.toUpperCase()),
          Switch(
            value: model.isBroadcasting,
            onChanged: (value) => _onTap(model),
            activeColor: Colors.white,
            activeTrackColor: Colors.white54,
          ),
        ],
      ),
    );
  }

  /// Triggered when the widget has been tapped on.
  void _onTap(BonsoirBroadcastModel model) {
    if (model.isBroadcasting) {
      model.stop();
    } else {
      model.start();
    }
  }
}

/// Allows to display all discovered services.
class ServiceList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BonsoirDiscoveryModel model = context.watch<BonsoirDiscoveryModel>();
    List<ResolvedBonsoirService?> discoveredServices = model.discoveredServices;
    if (discoveredServices.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Found no service of type "${AppService.type}".',
            style: TextStyle(
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: discoveredServices.length,
      itemBuilder: (context, index) =>
          _ServiceWidget(service: discoveredServices[index]),
    );
  }
}

/// Allows to display a discovered service.
class _ServiceWidget extends StatelessWidget {
  /// The discovered service.
  final ResolvedBonsoirService? service;

  /// Creates a new service widget.
  const _ServiceWidget({
    required this.service,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(service!.name),
        subtitle: Text(
            'Type : ${service!.type}, ip : ${service!.ip}, port : ${service!.port}'),
      );
}

/// Allows to display the app title based on how many services have been discovered.
class TitleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int count =
        context.watch<BonsoirDiscoveryModel>().discoveredServices.length;
    return Text(count == 0 ? 'Bonsoir app demo' : 'Found $count service(s)');
  }
}

/// The main widget.
class BonsoirExampleMainWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<BonsoirBroadcastModel>(
              create: (context) => BonsoirBroadcastModel()),
          ChangeNotifierProvider<BonsoirDiscoveryModel>(
              create: (context) => BonsoirDiscoveryModel()),
        ],
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: TitleWidget(),
              actions: [BroadcastSwitch()],
              centerTitle: false,
            ),
            body: ServiceList(),
          ),
        ),
      );
}

*/
