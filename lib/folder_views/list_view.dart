import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/widgets/icon_dismissable.dart';

typedef Widget NoteTileBuilder(BuildContext context, Note note);

class FolderListView extends StatefulWidget {
  final NoteTileBuilder noteTileBuilder;
  final NoteBoolPropertyFunction isNoteSelected;
  final NotesFolder folder;
  final String emptyText;
  final String searchTerm;

  FolderListView({
    @required this.folder,
    @required this.noteTileBuilder,
    @required this.emptyText,
    @required this.isNoteSelected,
    @required this.searchTerm,
  });

  @override
  _FolderListViewState createState() => _FolderListViewState();
}

class _FolderListViewState extends State<FolderListView> {
  var _listKey = GlobalKey<AnimatedListState>();
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
    if (_listKey.currentState == null) {
      return;
    }
    _listKey.currentState.insertItem(index);
  }

  void _noteRemoved(int index, Note note) {
    if (_listKey.currentState == null) {
      return;
    }
    _listKey.currentState.removeItem(index, (context, animation) {
      var i = deletedViaDismissed.indexWhere((path) => path == note.filePath);
      if (i == -1) {
        return _buildNote(note, widget.isNoteSelected(note), animation);
      } else {
        deletedViaDismissed.removeAt(i);
        return Container();
      }
    });
  }

  void _folderChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.folder.notes.isEmpty) {
      return Center(
        child: Text(
          widget.emptyText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.w300,
            color: Colors.grey[350],
          ),
        ),
      );
    }

    return AnimatedList(
      key: _listKey,
      itemBuilder: _buildItem,
      initialItemCount: widget.folder.notes.length,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 48),
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
      child: widget.noteTileBuilder(context, note),
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
        backgroundColor: Colors.red[800],
        iconData: Icons.delete,
        onDismissed: (direction) {
          deletedViaDismissed.add(note.filePath);

          var stateContainer = context.read<GitJournalRepo>();
          stateContainer.removeNote(note);

          var snackBar = buildUndoDeleteSnackbar(stateContainer, note);
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(snackBar);
        },
      );
    }

    if (selected) {
      var borderColor = Theme.of(context).accentColor;
      viewItem = Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: selected ? 2.0 : 1.0),
        ),
        child: viewItem,
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
