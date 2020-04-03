import 'package:flutter_driver/driver_extension.dart';
import 'package:gitjournal/app.dart';
import 'package:gitjournal/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  enableFlutterDriverExtension();

  var pref = await SharedPreferences.getInstance();
  Settings.instance.load(pref);

  await JournalApp.main(pref);
}
