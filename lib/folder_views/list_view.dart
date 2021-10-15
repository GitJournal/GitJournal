/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/utils/utils.dart';
import 'package:gitjournal/widgets/icon_dismissable.dart';
import 'empty_text_sliver.dart';

typedef NoteTileBuilder = Widget Function(
  BuildContext context,
  Note note,
  bool isSelected,
);

class FolderListView extends StatefulWidget {
  final NoteTileBuilder noteTileBuilder;
  final NoteBoolPropertyFunction isNoteSelected;
  final NotesFolder folder;
  final String? emptyText;
  final String searchTerm;

  const FolderListView({
    required this.folder,
    required this.noteTileBuilder,
    required this.emptyText,
    required this.isNoteSelected,
    required this.searchTerm,
    Key? key,
  }) : super(key: key);

  @override
  _FolderListViewState createState() => _FolderListViewState();
}

class _FolderListViewState extends State<FolderListView> {
  final _listKey = GlobalKey<SliverAnimatedListState>();
  var deletedViaDismissed = <String>[];

  @override
  void initState() {
    super.initState();
    _addListeners(widget.folder, this);
  }

  @override
  void dispose() {
    _removeListeners(widget.folder, this);
    super.dispose();
  }

  static void _addListeners(NotesFolder folder, _FolderListViewState st) {
    folder.addNoteAddedListener(st._noteAdded);
    folder.addNoteRemovedListener(st._noteRemoved);
    folder.addListener(st._folderChanged);
  }

  static void _removeListeners(NotesFolder folder, _FolderListViewState st) {
    folder.removeNoteAddedListener(st._noteAdded);
    folder.removeNoteRemovedListener(st._noteRemoved);
    folder.removeListener(st._folderChanged);
  }

  @override
  void didUpdateWidget(FolderListView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.folder != widget.folder) {
      _removeListeners(oldWidget.folder, this);
      _addListeners(widget.folder, this);
    }
  }

  void _noteAdded(int index, Note _) {
    assert(index != -1);
    if (_listKey.currentState == null) {
      return;
    }
    _listKey.currentState!.insertItem(index);
  }

  void _noteRemoved(int index, Note note) {
    assert(index != -1);
    if (_listKey.currentState == null) {
      return;
    }
    _listKey.currentState!.removeItem(index, (context, animation) {
      var i = deletedViaDismissed.indexWhere((path) => path == note.filePath);
      if (i == -1) {
        return _buildNote(note, widget.isNoteSelected(note), animation);
      } else {
        var _ = deletedViaDismissed.removeAt(i);
        return Container();
      }
    });
  }

  void _folderChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.folder.isEmpty) {
      if (widget.emptyText != null) {
        return EmptyTextSliver(emptyText: widget.emptyText!);
      } else {
        return const SliverToBoxAdapter(child: SizedBox());
      }
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 12.0 + 48.0),
      sliver: SliverAnimatedList(
        key: _listKey,
        itemBuilder: _buildItem,
        initialItemCount: widget.folder.notes.length,
      ),
    );
  }

  Widget _buildItem(BuildContext context, int i, Animation<double> animation) {
    // vHanda FIXME: Why does this method get called with i >= length ?
    if (i >= widget.folder.notes.length) {
      return Container();
    }

    var note = widget.folder.notes[i];
    return _buildNote(note, widget.isNoteSelected(note), animation);
  }

  Widget _buildNote(
    Note note,
    bool selected,
    Animation<double> animation,
  ) {
    var settings = Provider.of<Settings>(context);
    Widget viewItem = Hero(
      tag: note.filePath,
      child: widget.noteTileBuilder(context, note, selected),
      flightShuttleBuilder: (BuildContext flightContext,
              Animation<double> animation,
              HeroFlightDirection flightDirection,
              BuildContext fromHeroContext,
              BuildContext toHeroContext) =>
          Material(child: toHeroContext.widget),
    );

    if (settings.swipeToDelete) {
      viewItem = IconDismissable(
        key: ValueKey("FolderListView_" + note.filePath),
        child: viewItem,
        backgroundColor: Colors.red[800]!,
        iconData: Icons.delete,
        onDismissed: (direction) {
          deletedViaDismissed.add(note.filePath);

          var stateContainer = context.read<GitJournalRepo>();
          stateContainer.removeNote(note);

          var snackBar = buildUndoDeleteSnackbar(stateContainer, note);
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(snackBar);
        },
      );
    }

    return SizeTransition(
      key: ValueKey("FolderListView_tr_" + note.filePath),
      axis: Axis.vertical,
      sizeFactor: animation,
      child: viewItem,
    );
  }
}
