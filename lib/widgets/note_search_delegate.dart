import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/virtual_notes_folder.dart';
import 'package:gitjournal/folder_views/common.dart';
import 'package:gitjournal/folder_views/standard_view.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/themes.dart';

class NoteSearchDelegate extends SearchDelegate<Note?> {
  final List<Note> notes;
  final FolderViewType viewType;

  NoteSearchDelegate(this.notes, this.viewType);

  // Workaround because of https://github.com/flutter/flutter/issues/32180
  @override
  ThemeData appBarTheme(BuildContext context) {
    var theme = Theme.of(context);
    if (theme.brightness == Brightness.light) {
      return theme;
    }

    return theme.copyWith(
      primaryColor: Themes.dark.primaryColor,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildView(context, query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildView(context, query);
  }

  Widget buildView(BuildContext context, String query) {
    // TODO: This should be made far more efficient
    var q = query.toLowerCase();
    var filteredNotes = notes.where((note) {
      if (note.title.toLowerCase().contains(q)) {
        return true;
      }
      if (note.fileName.toLowerCase().contains(q)) {
        return true;
      }
      return note.body.toLowerCase().contains(q);
    }).toList();

    var settings = Provider.of<Settings>(context);
    var folder = VirtualNotesFolder(filteredNotes, settings);
    var emptyText = tr('widgets.FolderView.searchFailed');

    return buildFolderView(
      viewType: viewType,
      folder: folder,
      emptyText: emptyText,
      header: StandardViewHeader.TitleOrFileName,
      showSummary: true,
      noteTapped: (Note note) => openNoteEditor(context, note, folder),
      noteLongPressed: (Note note) {},
      isNoteSelected: (n) => false,
      searchTerm: query,
    );
  }
}
