import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final config = {
    'sentryApiKey': Platform.environment['TEST'],
    'credentials': Platform.environment['APP_CREDENTIALS'],
  };

  final filename = 'lib/.env.dart';
  File(filename).writeAsString('final environment = ${json.encode(config)};');
}
