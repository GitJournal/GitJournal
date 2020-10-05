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

  @override
  void initState() {
    super.initState();

    initializeDateFormatting();
    Future.delayed(Duration.zero, _initFolder);
  }

  // This is nto done inside build as we want to avoid rebuilding the
  // FlattenedNotesFolder as much as possible. It's very expensive, since
  // it sorts all the notes.
  void _initFolder() async {
    if (!mounted) return;

    final rootFolder = Provider.of<NotesFolderFS>(context, listen: false);
    setState(() {
      notesFolder = FlattenedNotesFolder(
        rootFolder,
        title: tr('screens.home.allNotes'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (notesFolder == null) {
      return Container();
    }

    return FolderView(notesFolder: notesFolder);
  }
}
