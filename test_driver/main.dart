import 'package:flutter_driver/driver_extension.dart';
import 'package:journal/app.dart';

void main() async {
  enableFlutterDriverExtension();
  await JournalApp.main();
}
