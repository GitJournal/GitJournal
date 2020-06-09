import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:function_types/function_types.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/widgets/rename_dialog.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/widgets/app_drawer.dart';

class FileSystemScreen extends StatefulWidget {
  @override
  _FileSystemScreenState createState() => _FileSystemScreenState();
}

class _FileSystemScreenState extends State<FileSystemScreen> {
  @override
  Widget build(BuildContext context) {
    final rootFolder = Provider.of<NotesFolderFS>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(rootFolder.publicName),
      ),
      body: Scrollbar(
        child: FileSystemView(
          rootFolder,
          onFolderSelected: _onFolderSelected,
          onNoteSelected: _onNoteSelected,
          onIgnoredFileSelected: _onIgnoredFileSelected,
        ),
      ),
      drawer: AppDrawer(),
    );
  }

  void _onFolderSelected(NotesFolderFS folder) {}
  void _onNoteSelected(Note note) {}

  void _onIgnoredFileSelected(IgnoredFile ignoredFile) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tr("screens.filesystem.ignoredFile.title")),
          content: Text(ignoredFile.reason),
          actions: <Widget>[
            FlatButton(
              onPressed: () async {
                Navigator.of(context).pop(false);
                _renameFile(ignoredFile.filePath);
              },
              child: Text(tr('screens.filesystem.ignoredFile.rename')),
            ),
            FlatButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(tr('screens.filesystem.ignoredFile.ok')),
            ),
          ],
        );
      },
    );
  }

  void _renameFile(String oldPath) async {
    var newFileName = await showDialog(
      context: context,
      builder: (_) => RenameDialog(
        oldPath: oldPath,
        inputDecoration: tr("screens.filesystem.rename.decoration"),
        dialogTitle: tr("screens.filesystem.rename.title"),
      ),
    );
    if (newFileName is String) {
      var container = Provider.of<StateContainer>(context, listen: false);
      container.renameFile(oldPath, newFileName);
    }
  }
}

class FileSystemView extends StatelessWidget {
  final NotesFolderFS folder;

  final Func1<NotesFolderFS, void> onFolderSelected;
  final Func1<Note, void> onNoteSelected;
  final Func1<IgnoredFile, void> onIgnoredFileSelected;

  FileSystemView(
    this.folder, {
    @required this.onFolderSelected,
    @required this.onNoteSelected,
    @required this.onIgnoredFileSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        for (var folder in folder.subFolders)
          _buildFolderTile(folder.fsFolder as NotesFolderFS),
        for (var note in folder.notes) _buildNoteTile(note),
        for (var ignoredFile in folder.ignoredFiles)
          _buildIgnoredFileTile(ignoredFile),
      ],
    );
  }

  Widget _buildFolderTile(NotesFolderFS folder) {
    return ListTile(
      leading: Icon(Icons.folder),
      title: Text(folder.name),
      dense: true,
      onTap: () => onFolderSelected(folder),
    );
  }

  Widget _buildNoteTile(Note note) {
    return ListTile(
      leading: Icon(Icons.note),
      title: Text(note.fileName),
      dense: true,
      onTap: () => onNoteSelected(note),
    );
  }

  Widget _buildIgnoredFileTile(IgnoredFile ignoredFile) {
    // FIXME: Paint with Ignored colours
    return ListTile(
      leading: Icon(Icons.broken_image),
      title: Text(ignoredFile.fileName),
      dense: true,
      enabled: true,
      onTap: () => onIgnoredFileSelected(ignoredFile),
    );
  }
}
