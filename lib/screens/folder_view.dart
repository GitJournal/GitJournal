import 'package:flutter/material.dart';

import 'package:git_bindings/git_bindings.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/core/sorted_notes_folder.dart';
import 'package:gitjournal/core/sorting_mode.dart';
import 'package:gitjournal/folder_views/common.dart';
import 'package:gitjournal/folder_views/standard_view.dart';
import 'package:gitjournal/screens/note_editor.dart';
import 'package:gitjournal/screens/settings_screen.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/state_container.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/widgets/app_bar_menu_button.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:gitjournal/widgets/new_note_nav_bar.dart';
import 'package:gitjournal/widgets/note_search_delegate.dart';
import 'package:gitjournal/widgets/sorting_order_selector.dart';
import 'package:gitjournal/widgets/sync_button.dart';

enum DropDownChoices {
  SortingOptions,
  ViewOptions,
}

class FolderView extends StatefulWidget {
  final NotesFolder notesFolder;
  final Map<String, dynamic> newNoteExtraProps;

  FolderView({
    @required this.notesFolder,
    this.newNoteExtraProps = const {},
  });

  @override
  _FolderViewState createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  SortedNotesFolder sortedNotesFolder;
  FolderViewType _viewType = FolderViewType.Standard;

  StandardViewHeader _headerType = StandardViewHeader.TitleGenerated;
  bool _showSummary = true;

  bool inSelectionMode = false;
  Note selectedNote;

  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    sortedNotesFolder = SortedNotesFolder(
      folder: widget.notesFolder,
      sortingMode: widget.notesFolder.config.sortingMode,
    );

    _viewType = widget.notesFolder.config.defaultView;
    _showSummary = widget.notesFolder.config.showNoteSummary;
    _headerType = widget.notesFolder.config.viewHeader;
  }

  @override
  Widget build(BuildContext context) {
    var createButton = FloatingActionButton(
      key: const ValueKey("FAB"),
      onPressed: () => _newPost(widget.notesFolder.config.defaultEditor),
      child: const Icon(Icons.add),
    );

    var title = widget.notesFolder.publicName;
    if (inSelectionMode) {
      title = "Note Selected";
    }

    Widget folderView = Builder(
      builder: (BuildContext context) {
        const emptyText = "Let's add some notes?";
        return buildFolderView(
          viewType: _viewType,
          folder: sortedNotesFolder,
          emptyText: emptyText,
          header: _headerType,
          showSummary: _showSummary,
          noteTapped: (Note note) {
            if (!inSelectionMode) {
              openNoteEditor(context, note);
            } else {
              setState(() {
                inSelectionMode = false;
                selectedNote = null;
              });
            }
          },
          noteLongPressed: (Note note) {
            // Disabled for now, until I figure out how to render
            // the selected note differently
            /*
            setState(() {
              inSelectionMode = true;
              selectedNote = note;
            });
            */
          },
        );
      },
    );

    // So the FAB doesn't hide parts of the last entry
    folderView = Padding(
      child: folderView,
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 48.0),
    );

    var backButton = IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        setState(() {
          inSelectionMode = false;
          selectedNote = null;
        });
      },
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(title),
        leading: inSelectionMode ? backButton : GJAppBarMenuButton(),
        actions: inSelectionMode
            ? _buildInSelectionNoteActions()
            : _buildNoteActions(),
      ),
      body: Center(
        child: Builder(
          builder: (context) => RefreshIndicator(
            child: Scrollbar(child: folderView),
            onRefresh: () async => _syncRepo(context),
          ),
        ),
      ),
      extendBody: true,
      drawer: AppDrawer(),
      floatingActionButton: createButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: NewNoteNavBar(onPressed: _newPost),
    );
  }

  void _syncRepo(BuildContext context) async {
    try {
      var container = Provider.of<StateContainer>(context, listen: false);
      await container.syncNotes();
    } on GitException catch (e) {
      showSnackbar(context, "Sync Error: ${e.cause}");
    } catch (e) {
      showSnackbar(context, e.toString());
    }
  }

  void _newPost(EditorType editorType) async {
    var folder = widget.notesFolder;
    NotesFolderFS fsFolder = folder.fsFolder;
    var isVirtualFolder = folder.name != folder.fsFolder.name;
    if (isVirtualFolder) {
      var rootFolder = Provider.of<NotesFolderFS>(context);
      fsFolder = getFolderForEditor(rootFolder, editorType);
    }

    var routeType =
        SettingsEditorType.fromEditorType(editorType).toInternalString();
    var route = MaterialPageRoute(
      builder: (context) => NoteEditor.newNote(
        fsFolder,
        editorType,
        newNoteExtraProps: widget.newNoteExtraProps,
      ),
      settings: RouteSettings(name: '/newNote/$routeType'),
    );
    await Navigator.of(context).push(route);
    _scaffoldKey.currentState.removeCurrentSnackBar();
  }

  void _sortButtonPressed() async {
    var newSortingMode = await showDialog<SortingMode>(
      context: context,
      builder: (BuildContext context) =>
          SortingOrderSelector(sortedNotesFolder.sortingMode),
    );

    if (newSortingMode != null) {
      sortedNotesFolder.config = sortedNotesFolder.config.copyWith(
        sortingMode: newSortingMode,
      );

      var container = Provider.of<StateContainer>(context, listen: false);
      container.saveFolderConfig(sortedNotesFolder.config);

      setState(() {
        sortedNotesFolder.changeSortingMode(newSortingMode);
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

          sortedNotesFolder.config = sortedNotesFolder.config.copyWith(
            viewHeader: _headerType,
          );
          var container = Provider.of<StateContainer>(context, listen: false);
          container.saveFolderConfig(sortedNotesFolder.config);
        };

        var summaryChanged = (bool newVal) {
          setState(() {
            _showSummary = newVal;
          });

          sortedNotesFolder.config = sortedNotesFolder.config.copyWith(
            showNoteSummary: newVal,
          );
          var container = Provider.of<StateContainer>(context, listen: false);
          container.saveFolderConfig(sortedNotesFolder.config);
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
            title: const Text("Grid View"),
            value: FolderViewType.Grid,
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
      });

      widget.notesFolder.config = widget.notesFolder.config.copyWith(
        defaultView: newViewType,
      );

      var container = Provider.of<StateContainer>(context, listen: false);
      container.saveFolderConfig(widget.notesFolder.config);
    }
  }

  List<Widget> _buildNoteActions() {
    final appState = Provider.of<StateContainer>(context).appState;

    var extraActions = PopupMenuButton<DropDownChoices>(
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

    return <Widget>[
      IconButton(
        icon: const Icon(Icons.library_books),
        onPressed: _folderViewChooserSelected,
        key: const ValueKey("FolderViewSelector"),
      ),
      if (appState.remoteGitRepoConfigured) SyncButton(),
      IconButton(
        icon: const Icon(Icons.search),
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
      extraActions,
    ];
  }

  List<Widget> _buildInSelectionNoteActions() {
    return [];
  }
}
