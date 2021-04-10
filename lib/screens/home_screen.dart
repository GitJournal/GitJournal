// @dart=2.9

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/flattened_notes_folder.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'folder_view.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NotesFolder notesFolder;
  NotesFolderFS rootFolder;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  void _initFolder() async {
    if (!mounted) return;

    var root = Provider.of<NotesFolderFS>(context);
    if (root != rootFolder) {
      rootFolder = root;
      notesFolder = FlattenedNotesFolder(
        rootFolder,
        title: tr('screens.home.allNotes'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _initFolder();
    if (notesFolder == null) {
      return Container();
    }

    return FolderView(notesFolder: notesFolder);
  }
}
