import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:journal/gitapp.dart';
//import 'package:journal/apis/git.dart';

void main() {
  // This line enables the extension
  enableFlutterDriverExtension();

  runApp(GitApp());
}
