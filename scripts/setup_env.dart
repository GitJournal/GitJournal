import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final config = {
    'sentry': Platform.environment['SENTRY_DSN'],
  };

  final filename = 'lib/.env.dart';
  await File(filename)
      .writeAsString('final environment = ${json.encode(config)};');
}
