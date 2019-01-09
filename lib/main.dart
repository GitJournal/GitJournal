import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;

import 'package:journal/app.dart';
import 'package:journal/gitapp.dart';
import 'package:journal/state_container.dart';

void main() {
  runApp(new StateContainer(
    child: JournalApp(),
    //child: GitApp(),
  ));
}
