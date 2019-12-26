import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

const _platform = MethodChannel('gitjournal.io/git');

///
/// This gives us the directory where all the git repos will be stored
///
Future<Directory> getGitBaseDirectory() async {
  final String path = await _platform.invokeMethod('getBaseDirectory');
  if (path == null) {
    return null;
  }
  return Directory(path);
}
