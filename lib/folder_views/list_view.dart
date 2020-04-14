import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/widgets/icon_dismissable.dart';

typedef void NoteSelectedFunction(Note note);
typedef Widget NoteTileBuilder(BuildContext context, Note note);

class FolderListView extends StatefulWidget {
  final NoteTileBuilder noteTileBuilder;
  final NotesFolder folder;
  final String emptyText;

  FolderListView({
    @required this.folder,
    @required this.noteTileBuilder,
    @required this.emptyText,
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

    widget.folder.addNoteAddedListener(_noteAdded);
    widget.folder.addNoteRemovedListener(_noteRemoved);
    widget.folder.addListener(_folderChanged);
  }

  @override
  void dispose() {
    widget.folder.removeNoteAddedListener(_noteAdded);
    widget.folder.removeNoteRemovedListener(_noteRemoved);
    widget.folder.removeListener(_folderChanged);

    super.dispose();
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
        return _buildNote(context, note, animation);
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
    );
  }

  Widget _buildItem(BuildContext context, int i, Animation<double> animation) {
    // vHanda FIXME: Why does this method get called with i >= length ?
    if (i >= widget.folder.notes.length) {
      return Container();
    }

    var note = widget.folder.notes[i];
    return _buildNote(context, note, animation);
  }

  Widget _buildNote(
    BuildContext context,
    Note note,
    Animation<double> animation,
  ) {
    var viewItem = IconDismissable(
      key: ValueKey("FolderListView_" + note.filePath),
      child: Hero(
        tag: note.filePath,
        child: widget.noteTileBuilder(context, note),
        flightShuttleBuilder: (BuildContext flightContext,
                Animation<double> animation,
                HeroFlightDirection flightDirection,
                BuildContext fromHeroContext,
                BuildContext toHeroContext) =>
            Material(child: toHeroContext.widget),
      ),
      backgroundColor: Colors.red[800],
      iconData: Icons.delete,
      onDismissed: (direction) {
        deletedViaDismissed.add(note.filePath);

        var stateContainer =
            Provider.of<StateContainer>(context, listen: false);
        stateContainer.removeNote(note);

        var snackBar = buildUndoDeleteSnackbar(context, note);
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(snackBar);
      },
    );

    return SizeTransition(
      key: ValueKey("FolderListView_tr_" + note.filePath),
      axis: Axis.vertical,
      sizeFactor: animation,
      child: viewItem,
    );
  }
}
