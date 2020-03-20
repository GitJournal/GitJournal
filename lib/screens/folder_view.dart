import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/core/sorted_notes_folder.dart';
import 'package:gitjournal/core/sorting_mode.dart';
import 'package:gitjournal/folder_views/standard_view.dart';
import 'package:gitjournal/screens/note_editor.dart';
import 'package:gitjournal/screens/settings_screen.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:gitjournal/widgets/app_bar_menu_button.dart';
import 'package:gitjournal/widgets/note_search_delegate.dart';
import 'package:gitjournal/widgets/sync_button.dart';
import 'package:gitjournal/folder_views/common.dart';

import 'package:provider/provider.dart';

enum DropDownChoices {
  SortingOptions,
  ViewOptions,
}

class FolderView extends StatefulWidget {
  final NotesFolder notesFolder;

  FolderView({@required this.notesFolder});

  @override
  _FolderViewState createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  SortedNotesFolder sortedNotesFolder;
  FolderViewType _viewType = FolderViewType.Standard;

  StandardViewHeader _headerType = StandardViewHeader.TitleGenerated;
  bool _showSummary = true;

  @override
  void initState() {
    super.initState();
    sortedNotesFolder = SortedNotesFolder(
      folder: widget.notesFolder,
      sortingMode: Settings.instance.sortingMode,
    );

    switch (Settings.instance.defaultView) {
      case SettingsFolderViewType.Standard:
        _viewType = FolderViewType.Standard;
        break;
      case SettingsFolderViewType.Journal:
        _viewType = FolderViewType.Journal;
        break;
      case SettingsFolderViewType.Card:
        _viewType = FolderViewType.Card;
        break;
    }

    _showSummary = Settings.instance.showNoteSummary;

    switch (Settings.instance.folderViewHeaderType) {
      case "TitleGenerated":
        _headerType = StandardViewHeader.TitleGenerated;
        break;
      case "FileName":
        _headerType = StandardViewHeader.FileName;
        break;
      case "TitleOrFileName":
        _headerType = StandardViewHeader.TitleOrFileName;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var container = Provider.of<StateContainer>(context);
    final appState = container.appState;

    var createButton = FloatingActionButton(
      key: const ValueKey("FAB"),
      onPressed: () =>
          _newPost(context, Settings.instance.defaultEditor.toEditorType()),
      child: Icon(Icons.add),
    );

    // If this is a Virtual folder which doesn't overwrite the FS folder's name
    // then we should use it's given name as the title
    String title = widget.notesFolder.name;
    var fsFolder = widget.notesFolder.fsFolder;
    if (fsFolder.name == widget.notesFolder.name) {
      title = widget.notesFolder.parent == null
          ? "Root Folder"
          : widget.notesFolder.pathSpec();
    }

    var folderView = Builder(
      builder: (BuildContext context) {
        const emptyText = "Let's add some notes?";
        return buildFolderView(
          context,
          _viewType,
          sortedNotesFolder,
          emptyText,
          _headerType,
          _showSummary,
        );
      },
    );

    var extraAction = PopupMenuButton<DropDownChoices>(
      onSelected: (DropDownChoices choice) {
        switch (choice) {
          case DropDownChoices.SortingOptions:
            _sortButtonPressed();
            break;

          case DropDownChoices.ViewOptions:
            _configureViewButtonPressed();
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<DropDownChoices>>[
        const PopupMenuItem<DropDownChoices>(
          value: DropDownChoices.SortingOptions,
          child: Text('Sorting Options'),
        ),
        if (_viewType == FolderViewType.Standard)
          const PopupMenuItem<DropDownChoices>(
            value: DropDownChoices.ViewOptions,
            child: Text('View Options'),
          ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: GJAppBarMenuButton(),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.library_books),
            onPressed: _folderViewChooserSelected,
          ),
          if (appState.remoteGitRepoConfigured) SyncButton(),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NoteSearchDelegate(
                  sortedNotesFolder.notes,
                  _viewType,
                ),
              );
            },
          ),
          extraAction,
        ],
      ),
      body: Center(
        child: Builder(
          builder: (context) => RefreshIndicator(
            child: Scrollbar(child: folderView),
            onRefresh: () async => _syncRepo(context),
          ),
        ),
      ),
      drawer: AppDrawer(),
      floatingActionButton: createButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).bottomAppBarColor,
        shape: const CircularNotchedRectangle(),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: IconButton(
                icon: const FaIcon(FontAwesomeIcons.tasks),
                onPressed: () => _newPost(context, EditorType.Checklist),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: IconButton(
                icon: const FaIcon(FontAwesomeIcons.markdown),
                onPressed: () => _newPost(context, EditorType.Markdown),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: IconButton(
                icon: const FaIcon(FontAwesomeIcons.book),
                onPressed: () => _newPost(context, EditorType.Journal),
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
        ),
      ),
    );
  }

  void _syncRepo(BuildContext context) async {
    try {
      var container = Provider.of<StateContainer>(context, listen: false);
      await container.syncNotes();
    } catch (e) {
      showSnackbar(context, e.toString());
    }
  }

  void _newPost(BuildContext context, EditorType editorType) {
    NotesFolderFS fsFolder = widget.notesFolder.fsFolder;
    if (widget.notesFolder.name != fsFolder.name) {
      var spec = Settings.instance.defaultNewNoteFolderSpec;
      fsFolder = fsFolder.getFolderWithSpec(spec);
    }

    var route = MaterialPageRoute(
      builder: (context) => NoteEditor.newNote(fsFolder, editorType),
    );
    Navigator.of(context).push(route);
  }

  void _sortButtonPressed() async {
    var newSortingMode = await showDialog<SortingMode>(
      context: context,
      builder: (BuildContext context) {
        var children = <Widget>[
          RadioListTile<SortingMode>(
            title: const Text("Last Modified"),
            value: SortingMode.Modified,
            groupValue: sortedNotesFolder.sortingMode,
            onChanged: (SortingMode sm) => Navigator.of(context).pop(sm),
          ),
          RadioListTile<SortingMode>(
            title: const Text("Created"),
            value: SortingMode.Created,
            groupValue: sortedNotesFolder.sortingMode,
            onChanged: (SortingMode sm) => Navigator.of(context).pop(sm),
          ),
        ];

        return AlertDialog(
          title: const Text("Sorting Criteria"),
          content: Column(
            children: children,
            mainAxisSize: MainAxisSize.min,
          ),
        );
      },
    );

    if (newSortingMode != null) {
      setState(() {
        sortedNotesFolder.changeSortingMode(newSortingMode);
        Settings.instance.sortingMode = newSortingMode;
        Settings.instance.save();
      });
    }
  }

  void _configureViewButtonPressed() async {
    await showDialog<SortingMode>(
      context: context,
      builder: (BuildContext context) {
        var headerTypeChanged = (StandardViewHeader newHeader) {
          setState(() {
            _headerType = newHeader;
          });

          String ht;
          switch (newHeader) {
            case StandardViewHeader.FileName:
              ht = "FileName";
              break;
            case StandardViewHeader.TitleGenerated:
              ht = "TitleGenerated";
              break;
            case StandardViewHeader.TitleOrFileName:
              ht = "TitleOrFileName";
              break;
          }

          Settings.instance.folderViewHeaderType = ht;
          Settings.instance.save();
        };

        var summaryChanged = (bool newVal) {
          setState(() {
            _showSummary = newVal;
          });
          Settings.instance.showNoteSummary = newVal;
          Settings.instance.save();
        };

        return StatefulBuilder(
          builder: (BuildContext context, Function setState) {
            var children = <Widget>[
              SettingsHeader("Header Options"),
              RadioListTile<StandardViewHeader>(
                title: const Text("Title or FileName"),
                value: StandardViewHeader.TitleOrFileName,
                groupValue: _headerType,
                onChanged: (newVal) {
                  headerTypeChanged(newVal);
                  setState(() {});
                },
              ),
              RadioListTile<StandardViewHeader>(
                title: const Text("Auto Generated Title"),
                value: StandardViewHeader.TitleGenerated,
                groupValue: _headerType,
                onChanged: (newVal) {
                  headerTypeChanged(newVal);
                  setState(() {});
                },
              ),
              RadioListTile<StandardViewHeader>(
                title: const Text("FileName"),
                value: StandardViewHeader.FileName,
                groupValue: _headerType,
                onChanged: (newVal) {
                  headerTypeChanged(newVal);
                  setState(() {});
                },
              ),
              SwitchListTile(
                title: const Text("Show Summary"),
                value: _showSummary,
                onChanged: (bool newVal) {
                  setState(() {
                    _showSummary = newVal;
                  });
                  summaryChanged(newVal);
                },
              ),
            ];

            return AlertDialog(
              title: const Text("Customize View"),
              content: Column(
                children: children,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            );
          },
        );
      },
    );

    setState(() {});
  }

  void _folderViewChooserSelected() async {
    var onViewChange = (FolderViewType vt) => Navigator.of(context).pop(vt);

    var newViewType = await showDialog<FolderViewType>(
      context: context,
      builder: (BuildContext context) {
        var children = <Widget>[
          RadioListTile<FolderViewType>(
            title: const Text("Standard View"),
            value: FolderViewType.Standard,
            groupValue: _viewType,
            onChanged: onViewChange,
          ),
          RadioListTile<FolderViewType>(
            title: const Text("Journal View"),
            value: FolderViewType.Journal,
            groupValue: _viewType,
            onChanged: onViewChange,
          ),
          RadioListTile<FolderViewType>(
            title: const Text("Card View (Experimental)"),
            value: FolderViewType.Card,
            groupValue: _viewType,
            onChanged: onViewChange,
          ),
        ];

        return AlertDialog(
          title: const Text("Select View"),
          content: Column(
            children: children,
            mainAxisSize: MainAxisSize.min,
          ),
        );
      },
    );

    if (newViewType != null) {
      setState(() {
        _viewType = newViewType;

        switch (_viewType) {
          case FolderViewType.Standard:
            Settings.instance.defaultView = SettingsFolderViewType.Standard;
            break;
          case FolderViewType.Journal:
            Settings.instance.defaultView = SettingsFolderViewType.Journal;
            break;
          case FolderViewType.Card:
            Settings.instance.defaultView = SettingsFolderViewType.Card;
            break;
        }
        Settings.instance.save();
      });
    }
  }
}
