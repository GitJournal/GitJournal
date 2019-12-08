import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/notes_folder.dart';

import 'journal_listing.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notesFolder = Provider.of<NotesFolder>(context);
    return JournalListingScreen(notesFolder: notesFolder);
  }
}
