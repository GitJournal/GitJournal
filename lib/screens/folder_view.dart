import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:git_bindings/git_bindings.dart';
import 'package:provider/provider.dart';

import 'package:gitjournal/app.dart';
import 'package:gitjournal/core/md_yaml_doc_codec.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/core/sorted_notes_folder.dart';
import 'package:gitjournal/core/sorting_mode.dart';
import 'package:gitjournal/editors/common_types.dart';
import 'package:gitjournal/folder_views/common.dart';
import 'package:gitjournal/folder_views/standard_view.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/screens/note_editor.dart';
import 'package:gitjournal/screens/settings_screen.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils.dart';
import 'package:gitjournal/widgets/app_bar_menu_button.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:gitjournal/widgets/new_note_nav_bar.dart';
import 'package:gitjournal/widgets/note_delete_dialog.dart';
import 'package:gitjournal/widgets/note_search_delegate.dart';
import 'package:gitjournal/widgets/sorting_mode_selector.dart';
import 'package:gitjournal/widgets/sync_button.dart';

enum DropDownChoices {
  SortingOptions,
  ViewOptions,
}

class FolderView extends StatefulWidget {
  final NotesFolder notesFolder;
  final Map<String, dynamic> newNoteExtraProps;

  FolderView({
    required this.notesFolder,
    this.newNoteExtraProps = const {},
  });

  @override
  _FolderViewState createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  late SortedNotesFolder sortedNotesFolder;
  FolderViewType _viewType = FolderViewType.Standard;

  var _headerType = StandardViewHeader.TitleGenerated;
  bool _showSummary = true;

  bool inSelectionMode = false;
  Note? selectedNote;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    sortedNotesFolder = SortedNotesFolder(
      folder: widget.notesFolder,
      sortingMode: widget.notesFolder.config.sortingMode,
    );

    _viewType = widget.notesFolder.config.defaultView;
    _showSummary = widget.notesFolder.config.showNoteSummary;
    _headerType = widget.notesFolder.config.viewHeader;
  }

  @override
  void didUpdateWidget(FolderView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.notesFolder != widget.notesFolder) {
      _init();
    }
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
      title = NumberFormat.compact().format(1);
    }

    Widget folderView = Builder(
      builder: (BuildContext context) {
        return buildFolderView(
          viewType: _viewType,
          folder: sortedNotesFolder,
          emptyText: tr('screens.folder_view.empty'),
          header: _headerType,
          showSummary: _showSummary,
          noteTapped: (Note note) {
            if (!inSelectionMode) {
              openNoteEditor(context, note, widget.notesFolder);
            } else {
              _resetSelection();
            }
          },
          noteLongPressed: (Note note) {
            setState(() {
              inSelectionMode = true;
              selectedNote = note;
            });
          },
          isNoteSelected: (n) => n == selectedNote,
          searchTerm: "",
        );
      },
    );

    var settings = Provider.of<Settings>(context);
    final showButtomMenuBar = settings.bottomMenuBar;

    // So the FAB doesn't hide parts of the last entry
    if (!showButtomMenuBar) {
      folderView = Padding(
        child: folderView,
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 48.0),
      );
    }

    var backButton = IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: _resetSelection,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: inSelectionMode ? backButton : GJAppBarMenuButton(),
        actions: inSelectionMode
            ? _buildInSelectionNoteActions()
            : _buildNoteActions(),
      ),
      body: Center(
        child: Builder(
          builder: (context) {
            var child = Scrollbar(child: folderView);
            if (settings.remoteSyncFrequency == RemoteSyncFrequency.Manual) {
              return child;
            }
            return RefreshIndicator(
              child: child,
              onRefresh: () async => _syncRepo(context),
            );
          },
        ),
      ),
      extendBody: true,
      drawer: AppDrawer(),
      floatingActionButton: createButton,
      floatingActionButtonLocation:
          showButtomMenuBar ? FloatingActionButtonLocation.endDocked : null,
      bottomNavigationBar:
          showButtomMenuBar ? NewNoteNavBar(onPressed: _newPost) : null,
    );
  }

  void _syncRepo(BuildContext context) async {
    try {
      var container = context.read<GitJournalRepo>();
      await container.syncNotes();
    } on GitException catch (e) {
      showSnackbar(
        context,
        tr('widgets.FolderView.syncError', args: [e.cause]),
      );
    } catch (e) {
      showSnackbar(context, e.toString());
    }
  }

  void _newPost(EditorType editorType) async {
    var folder = widget.notesFolder;
    var fsFolder = folder.fsFolder as NotesFolderFS;
    var isVirtualFolder = folder.name != folder.fsFolder!.name;
    if (isVirtualFolder) {
      var rootFolder = Provider.of<NotesFolderFS>(context, listen: false);
      var settings = Provider.of<Settings>(context, listen: false);

      fsFolder = getFolderForEditor(settings, rootFolder, editorType);
    }

    var settings = Provider.of<Settings>(context, listen: false);

    if (editorType == EditorType.Journal && settings.journalEditorSingleNote) {
      var note = await getTodayJournalEntry(fsFolder.rootFolder);
      if (note != null) {
        return openNoteEditor(
          context,
          note,
          widget.notesFolder,
          editMode: true,
        );
      }
    }
    var routeType =
        SettingsEditorType.fromEditorType(editorType).toInternalString();

    var extraProps = Map<String, dynamic>.from(widget.newNoteExtraProps);
    if (settings.customMetaData.isNotEmpty) {
      var map = MarkdownYAMLCodec.parseYamlText(settings.customMetaData);
      map.forEach((key, val) {
        extraProps[key] = val;
      });
    }
    var route = MaterialPageRoute(
      builder: (context) => NoteEditor.newNote(
        fsFolder,
        widget.notesFolder,
        editorType,
        newNoteExtraProps: extraProps,
        existingText: "",
        existingImages: [],
      ),
      settings: RouteSettings(name: '/newNote/$routeType'),
    );
    await Navigator.of(context).push(route);
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }

  void _sortButtonPressed() async {
    var newSortingMode = await showDialog<SortingMode>(
      context: context,
      builder: (BuildContext context) =>
          SortingModeSelector(sortedNotesFolder.sortingMode),
    );

    if (newSortingMode != null) {
      var config = sortedNotesFolder.config.copyWith(
        sortingMode: newSortingMode,
      );

      var settings = Provider.of<Settings>(context, listen: false);
      config.saveToSettings(settings);

      var container = context.read<GitJournalRepo>();
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
        var headerTypeChanged = (StandardViewHeader? newHeader) {
          if (newHeader == null) {
            return;
          }
          setState(() {
            _headerType = newHeader;
          });

          var config = sortedNotesFolder.config.copyWith(
            viewHeader: _headerType,
          );

          var settings = Provider.of<Settings>(context, listen: false);
          config.saveToSettings(settings);

          var container = context.read<GitJournalRepo>();
          container.saveFolderConfig(sortedNotesFolder.config);
        };

        var summaryChanged = (bool newVal) {
          setState(() {
            _showSummary = newVal;
          });

          var config = sortedNotesFolder.config.copyWith(
            showNoteSummary: newVal,
          );

          var settings = Provider.of<Settings>(context, listen: false);
          config.saveToSettings(settings);

          var container = context.read<GitJournalRepo>();
          container.saveFolderConfig(sortedNotesFolder.config);
        };

        return StatefulBuilder(
          builder: (BuildContext context, Function setState) {
            var children = <Widget>[
              SettingsHeader(tr('widgets.FolderView.headerOptions.heading')),
              RadioListTile<StandardViewHeader>(
                title:
                    Text(tr('widgets.FolderView.headerOptions.titleFileName')),
                value: StandardViewHeader.TitleOrFileName,
                groupValue: _headerType,
                onChanged: (newVal) {
                  headerTypeChanged(newVal);
                  setState(() {});
                },
              ),
              RadioListTile<StandardViewHeader>(
                title: Text(tr('widgets.FolderView.headerOptions.auto')),
                value: StandardViewHeader.TitleGenerated,
                groupValue: _headerType,
                onChanged: (newVal) {
                  headerTypeChanged(newVal);
                  setState(() {});
                },
              ),
              RadioListTile<StandardViewHeader>(
                key: const ValueKey("ShowFileNameOnly"),
                title: Text(tr('widgets.FolderView.headerOptions.fileName')),
                value: StandardViewHeader.FileName,
                groupValue: _headerType,
                onChanged: (newVal) {
                  headerTypeChanged(newVal);
                  setState(() {});
                },
              ),
              SwitchListTile(
                key: const ValueKey("SummaryToggle"),
                title: Text(tr('widgets.FolderView.headerOptions.summary')),
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
              title: GestureDetector(
                key: const ValueKey("Hack_Back"),
                child: Text(tr('widgets.FolderView.headerOptions.customize')),
                onTap: () {
                  // Hack to get out of the dialog in the tests
                  // driver.findByType('ModalBarrier') doesn't seem to be working
                  if (JournalApp.isInDebugMode) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              key: const ValueKey("ViewOptionsDialog"),
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
    var onViewChange = (FolderViewType? vt) => Navigator.of(context).pop(vt);

    var newViewType = await showDialog<FolderViewType>(
      context: context,
      builder: (BuildContext context) {
        var children = <Widget>[
          RadioListTile<FolderViewType>(
            title: Text(tr('widgets.FolderView.views.standard')),
            value: FolderViewType.Standard,
            groupValue: _viewType,
            onChanged: onViewChange,
          ),
          RadioListTile<FolderViewType>(
            title: Text(tr('widgets.FolderView.views.journal')),
            value: FolderViewType.Journal,
            groupValue: _viewType,
            onChanged: onViewChange,
          ),
          RadioListTile<FolderViewType>(
            title: Text(tr('widgets.FolderView.views.grid')),
            value: FolderViewType.Grid,
            groupValue: _viewType,
            onChanged: onViewChange,
          ),
          RadioListTile<FolderViewType>(
            title: Text(tr('widgets.FolderView.views.card')),
            value: FolderViewType.Card,
            groupValue: _viewType,
            onChanged: onViewChange,
          ),
        ];

        return AlertDialog(
          title: Text(tr('widgets.FolderView.views.select')),
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

      var config = widget.notesFolder.config.copyWith(
        defaultView: newViewType,
      );

      var settings = Provider.of<Settings>(context, listen: false);
      config.saveToSettings(settings);

      var container = context.read<GitJournalRepo>();
      container.saveFolderConfig(widget.notesFolder.config);
    }
  }

  List<Widget> _buildNoteActions() {
    final repo = Provider.of<GitJournalRepo>(context);

    var extraActions = PopupMenuButton<DropDownChoices>(
      key: const ValueKey("PopupMenu"),
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
        PopupMenuItem<DropDownChoices>(
          key: const ValueKey("SortingOptions"),
          value: DropDownChoices.SortingOptions,
          child: Text(tr('widgets.FolderView.sortingOptions')),
        ),
        if (_viewType == FolderViewType.Standard)
          PopupMenuItem<DropDownChoices>(
            key: const ValueKey("ViewOptions"),
            value: DropDownChoices.ViewOptions,
            child: Text(tr('widgets.FolderView.viewOptions')),
          ),
      ],
    );

    return <Widget>[
      IconButton(
        icon: const Icon(Icons.library_books),
        onPressed: _folderViewChooserSelected,
        key: const ValueKey("FolderViewSelector"),
      ),
      if (repo.remoteGitRepoConfigured) SyncButton(),
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
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.share),
        onPressed: () async {
          await shareNote(selectedNote!);
          _resetSelection();
        },
      ),
      IconButton(
        icon: const Icon(Icons.delete),
        onPressed: _deleteNote,
      ),
    ];
  }

  void _deleteNote() async {
    var note = selectedNote;

    var settings = Provider.of<Settings>(context, listen: false);
    var shouldDelete = true;
    if (settings.confirmDelete) {
      shouldDelete = await showDialog(
        context: context,
        builder: (context) => NoteDeleteDialog(),
      );
    }
    if (shouldDelete == true) {
      var stateContainer = context.read<GitJournalRepo>();
      stateContainer.removeNote(note!);
    }

    _resetSelection();
  }

  void _resetSelection() {
    setState(() {
      selectedNote = null;
      inSelectionMode = false;
    });
  }
}
