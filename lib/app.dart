import 'package:flutter/material.dart';
import 'package:journal/screens/home_screen.dart';

class JournalApp extends StatelessWidget {
  JournalApp();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Journal',
      home: new HomeScreen(),
      theme: new ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.lightBlue[800],
        accentColor: Colors.cyan[600],
      ),
    );
  }
}
