import 'package:flutter_driver/driver_extension.dart';
import 'package:gitjournal/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  enableFlutterDriverExtension();
  var pref = await SharedPreferences.getInstance();
  await JournalApp.main(pref);
}
