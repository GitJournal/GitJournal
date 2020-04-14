import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final config = {
    'sentry': Platform.environment['SENTRY_DSN'],
    'revenueCat': Platform.environment['REVENUE_CAT_API_KEY'],
  };

  final filename = 'lib/.env.dart';
  File(filename).writeAsString('final environment = ${json.encode(config)};');
}
