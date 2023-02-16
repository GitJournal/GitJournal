/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:git_bindings/git_bindings.dart';
import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/app_router.dart';
import 'package:gitjournal/core/folder/filtered_notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/folder/sorted_notes_folder.dart';
import 'package:gitjournal/core/folder/sorting_mode.dart';
import 'package:gitjournal/core/markdown/md_yaml_doc_codec.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/editors/common_types.dart';
import 'package:gitjournal/editors/note_editor.dart';
import 'package:gitjournal/folder_views/common.dart';
import 'package:gitjournal/folder_views/standard_view.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/repository.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/settings/widgets/settings_header.dart';
import 'package:gitjournal/utils/utils.dart';
import 'package:gitjournal/widgets/app_bar_menu_button.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:gitjournal/widgets/folder_selection_dialog.dart';
import 'package:gitjournal/widgets/new_note_nav_bar.dart';
import 'package:gitjournal/widgets/note_delete_dialog.dart';
import 'package:gitjournal/widgets/note_search_delegate.dart';
import 'package:gitjournal/widgets/sorting_mode_selector.dart';
import 'package:gitjournal/widgets/sync_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum DropDownChoices {
  SortingOptions,
  ViewOptions,
}

enum NoteSelectedExtraActions {
  MoveToFolder,
}

class FolderView extends StatefulWidget {
  final NotesFolder notesFolder;
  final Map<String, dynamic> newNoteExtraProps;

  const FolderView({
    required this.notesFolder,
    this.newNoteExtraProps = const {},
  });

  @override
  _FolderViewState createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  SortedNotesFolder? _sortedNotesFolder;
  SortedNotesFolder? _pinnedNotesFolder;
  FolderViewType _viewType = FolderViewType.Standard;

  var _headerType = StandardViewHeader.TitleGenerated;
  bool _showSummary = true;

  var _selectedNotes = <Note>[];
  bool get inSelectionMode => _selectedNotes.isNotEmpty;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    _viewType = widget.notesFolder.config.defaultView.toFolderViewType();
    _showSummary = widget.notesFolder.config.showNoteSummary;
    _headerType = widget.notesFolder.config.viewHeader;

    var otherNotesFolder = SortedNotesFolder(
      folder: await FilteredNotesFolder.load(
        widget.notesFolder,
        title: context.loc.widgetsFolderViewPinned,
        filter: (Note note) async => !note.pinned,
      ),
      sortingMode: widget.notesFolder.config.sortingMode,
    );

    var pinnedFolder = SortedNotesFolder(
      folder: await FilteredNotesFolder.load(
        widget.notesFolder,
        title: context.loc.widgetsFolderViewPinned,
        filter: (Note note) async => note.pinned,
      ),
      sortingMode: widget.notesFolder.config.sortingMode,
    );

    setState(() {
      _sortedNotesFolder = otherNotesFolder;
      _pinnedNotesFolder = pinnedFolder;
    });
  }

  @override
  void dispose() {
    _sortedNotesFolder?.dispose();
    _pinnedNotesFolder?.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(FolderView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.notesFolder != widget.notesFolder) {
      _init();
    }
  }

  Widget _buildBody(BuildContext context) {
    if (_sortedNotesFolder == null) {
      return Container();
    }
    var title = widget.notesFolder.publicName(context);
    if (inSelectionMode) {
      title = NumberFormat.compact().format(_selectedNotes.length);
    }

    var folderView = buildFolderView(
      viewType: _viewType,
      folder: _sortedNotesFolder!,
      emptyText: context.loc.screensFolderViewEmpty,
      header: _headerType,
      showSummary: _showSummary,
      noteTapped: _noteTapped,
      noteLongPressed: _noteLongPress,
      isNoteSelected: (n) => _selectedNotes.contains(n),
    );

    Widget pinnedFolderView = const SizedBox();
    if (_pinnedNotesFolder != null) {
      pinnedFolderView = buildFolderView(
        viewType: _viewType,
        folder: _pinnedNotesFolder!,
        emptyText: null,
        header: _headerType,
        showSummary: _showSummary,
        noteTapped: _noteTapped,
        noteLongPressed: _noteLongPress,
        isNoteSelected: (n) => _selectedNotes.contains(n),
      );
    }

    var settings = Provider.of<Settings>(context);
    final showButtomMenuBar = settings.bottomMenuBar;

    // So the FAB doesn't hide parts of the last entry
    if (!showButtomMenuBar) {
      folderView = SliverPadding(
        sliver: folderView,
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 48.0),
      );
    }

    var backButton = IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: _resetSelection,
    );

    var havePinnedNotes =
        _pinnedNotesFolder != null ? !_pinnedNotesFolder!.isEmpty : false;

    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverAppBar(
            title: Text(title),
            leading: inSelectionMode ? backButton : GJAppBarMenuButton(),
            actions: inSelectionMode
                ? _buildInSelectionNoteActions()
                : _buildNoteActions(),
            forceElevated: true,
          ),
        ];
      },
      floatHeaderSlivers: true,
      // Stupid scrollbar has a top padding otherwise
      // - from : https://stackoverflow.com/questions/64404873/remove-the-top-padding-from-scrollbar-when-wrapping-listview
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Scrollbar(
          child: Builder(builder: (context) {
            var view = CustomScrollView(slivers: [
              if (havePinnedNotes)
                _SliverHeader(text: context.loc.widgetsFolderViewPinned),
              if (havePinnedNotes) pinnedFolderView,
              if (havePinnedNotes)
                _SliverHeader(text: context.loc.widgetsFolderViewOthers),
              folderView,
            ]);
            if (settings.remoteSyncFrequency == RemoteSyncFrequency.Manual) {
              return view;
            }
            return RefreshIndicator(
              onRefresh: () => syncRepo(context),
              child: view,
            );
          }),
        ),
      ),
    );
  }

  void _noteLongPress(Note note) {
    var i = _selectedNotes.indexOf(note);
    if (i != -1) {
      setState(() {
        var _ = _selectedNotes.removeAt(i);
      });
    } else {
      setState(() {
        _selectedNotes.add(note);
      });
    }
  }

  void _noteTapped(Note note) {
    if (!inSelectionMode) {
      openNoteEditor(context, note, widget.notesFolder);
      return;
    }

    var i = _selectedNotes.indexOf(note);
    if (i != -1) {
      setState(() {
        var _ = _selectedNotes.removeAt(i);
      });
    } else {
      setState(() {
        _selectedNotes.add(note);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var createButton = FloatingActionButton(
      key: const ValueKey("FAB"),
      onPressed: () =>
          _newPost(widget.notesFolder.config.defaultEditor.toEditorType()),
      child: const Icon(Icons.add),
    );

    var settings = Provider.of<Settings>(context);
    final showButtomMenuBar = settings.bottomMenuBar;

    return Scaffold(
      body: Builder(builder: _buildBody),
      extendBody: true,
      drawer: AppDrawer(),
      floatingActionButton: createButton,
      floatingActionButtonLocation:
          showButtomMenuBar ? FloatingActionButtonLocation.endDocked : null,
      bottomNavigationBar:
          showButtomMenuBar ? NewNoteNavBar(onPressed: _newPost) : null,
    );
  }

  Future<void> _newPost(EditorType editorType) async {
    var settings = Provider.of<Settings>(context, listen: false);
    var rootFolder = Provider.of<NotesFolderFS>(context, listen: false);

    var folder = widget.notesFolder;
    var fsFolder = folder.fsFolder as NotesFolderFS;
    var isVirtualFolder = folder.name != folder.fsFolder!.name;

    if (isVirtualFolder) {
      fsFolder = getFolderForEditor(settings, rootFolder, editorType);
    }

    if (editorType == EditorType.Journal) {
      if (settings.journalEditordefaultNewNoteFolderSpec.isNotEmpty) {
        var spec = settings.journalEditordefaultNewNoteFolderSpec;
        fsFolder = rootFolder.getFolderWithSpec(spec) ?? rootFolder;

        if (!isVirtualFolder) {
          showSnackbar(
            context,
            context.loc.settingsEditorsJournalDefaultFolderSelect(spec),
          );
        }
      }

      if (settings.journalEditorSingleNote) {
        var note = await getTodayJournalEntry(fsFolder.rootFolder);
        if (note != null) {
          return openNoteEditor(
            context,
            note,
            fsFolder,
            editMode: true,
          );
        }
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
    var route = newNoteRoute(
      NoteEditor.newNote(
        fsFolder,
        widget.notesFolder,
        editorType,
        newNoteExtraProps: extraProps,
        existingText: "",
        existingImages: const [],
      ),
      AppRoute.NewNotePrefix + routeType,
    );
    var _ = await Navigator.push(context, route);
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }

  Future<void> _sortButtonPressed() async {
    if (_sortedNotesFolder == null) {
      return;
    }
    var newSortingMode = await showDialog<SortingMode>(
      context: context,
      builder: (BuildContext context) =>
          SortingModeSelector(_sortedNotesFolder!.sortingMode),
    );

    if (newSortingMode != null) {
      var folderConfig = _sortedNotesFolder!.config;
      folderConfig.sortingField = newSortingMode.field;
      folderConfig.sortingOrder = newSortingMode.order;
      folderConfig.save();

      setState(() {
        _sortedNotesFolder!.changeSortingMode(newSortingMode);
      });
    }
  }

  Future<void> _configureViewButtonPressed() async {
    var _ = await showDialog<SortingMode>(
      context: context,
      builder: (BuildContext context) {
        void headerTypeChanged(StandardViewHeader? newHeader) {
          if (newHeader == null) {
            return;
          }
          setState(() {
            _headerType = newHeader;
          });

          var folderConfig = _sortedNotesFolder!.config;
          folderConfig.viewHeader = _headerType;
          folderConfig.save();
        }

        void summaryChanged(bool newVal) {
          setState(() {
            _showSummary = newVal;
          });

          var folderConfig = _sortedNotesFolder!.config;
          folderConfig.showNoteSummary = newVal;
          folderConfig.save();
        }

        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            var children = <Widget>[
              SettingsHeader(context.loc.widgetsFolderViewHeaderOptionsHeading),
              RadioListTile<StandardViewHeader>(
                title: Text(
                    context.loc.widgetsFolderViewHeaderOptionsTitleFileName),
                value: StandardViewHeader.TitleOrFileName,
                groupValue: _headerType,
                onChanged: (newVal) {
                  headerTypeChanged(newVal);
                  setState(() {});
                },
              ),
              RadioListTile<StandardViewHeader>(
                title: Text(context.loc.widgetsFolderViewHeaderOptionsAuto),
                value: StandardViewHeader.TitleGenerated,
                groupValue: _headerType,
                onChanged: (newVal) {
                  headerTypeChanged(newVal);
                  setState(() {});
                },
              ),
              RadioListTile<StandardViewHeader>(
                key: const ValueKey("ShowFileNameOnly"),
                title: Text(context.loc.widgetsFolderViewHeaderOptionsFileName),
                value: StandardViewHeader.FileName,
                groupValue: _headerType,
                onChanged: (newVal) {
                  headerTypeChanged(newVal);
                  setState(() {});
                },
              ),
              SwitchListTile(
                key: const ValueKey("SummaryToggle"),
                title: Text(context.loc.widgetsFolderViewHeaderOptionsSummary),
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
                child:
                    Text(context.loc.widgetsFolderViewHeaderOptionsCustomize),
                onTap: () {
                  // Hack to get out of the dialog in the tests
                  // driver.findByType('ModalBarrier') doesn't seem to be working
                  if (foundation.kDebugMode) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              key: const ValueKey("ViewOptionsDialog"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            );
          },
        );
      },
    );

    setState(() {});
  }

  Future<void> _folderViewChooserSelected() async {
    void onViewChange(FolderViewType? vt) => Navigator.of(context).pop(vt);

    var newViewType = await showDialog<FolderViewType>(
      context: context,
      builder: (BuildContext context) {
        var children = <Widget>[
          RadioListTile<FolderViewType>(
            title: Text(context.loc.widgetsFolderViewViewsStandard),
            value: FolderViewType.Standard,
            groupValue: _viewType,
            onChanged: onViewChange,
          ),
          RadioListTile<FolderViewType>(
            title: Text(context.loc.widgetsFolderViewViewsJournal),
            value: FolderViewType.Journal,
            groupValue: _viewType,
            onChanged: onViewChange,
          ),
          RadioListTile<FolderViewType>(
            title: Text(context.loc.widgetsFolderViewViewsGrid),
            value: FolderViewType.Grid,
            groupValue: _viewType,
            onChanged: onViewChange,
          ),
          RadioListTile<FolderViewType>(
            title: Text(context.loc.widgetsFolderViewViewsCard),
            value: FolderViewType.Card,
            groupValue: _viewType,
            onChanged: onViewChange,
          ),
          // RadioListTile<FolderViewType>(
          //   title: Text(context.loc.widgetsFolderViewViewsCalendar),
          //   value: FolderViewType.Calendar,
          //   groupValue: _viewType,
          //   onChanged: onViewChange,
          // ),
        ];

        return AlertDialog(
          title: Text(context.loc.widgetsFolderViewViewsSelect),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        );
      },
    );

    if (newViewType != null) {
      setState(() {
        _viewType = newViewType;
      });

      var folderConfig = widget.notesFolder.config;
      folderConfig.defaultView =
          SettingsFolderViewType.fromFolderViewType(newViewType);
      folderConfig.save();
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
          child: Text(context.loc.widgetsFolderViewSortingOptions),
        ),
        if (_viewType == FolderViewType.Standard)
          PopupMenuItem<DropDownChoices>(
            key: const ValueKey("ViewOptions"),
            value: DropDownChoices.ViewOptions,
            child: Text(context.loc.widgetsFolderViewViewOptions),
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
          logEvent(Event.SearchButtonPressed);
          var _ = showSearch(
            context: context,
            delegate: NoteSearchDelegate(
              _sortedNotesFolder!.notes,
              _viewType,
            ),
          );
        },
      ),
      extraActions,
    ];
  }

  List<Widget> _buildInSelectionNoteActions() {
    var extraActions = PopupMenuButton<NoteSelectedExtraActions>(
      key: const ValueKey("PopupMenu"),
      onSelected: (NoteSelectedExtraActions choice) {
        switch (choice) {
          case NoteSelectedExtraActions.MoveToFolder:
            _moveSelectedNotesToFolder();
            break;
        }
      },
      itemBuilder: (BuildContext context) =>
          <PopupMenuEntry<NoteSelectedExtraActions>>[
        PopupMenuItem<NoteSelectedExtraActions>(
          value: NoteSelectedExtraActions.MoveToFolder,
          child: Text(context.loc.widgetsFolderViewActionsMoveToFolder),
        ),
      ],
    );

    return <Widget>[
      if (_selectedNotes.length == 1)
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () async {
            await shareNote(_selectedNotes.first);
            _resetSelection();
          },
        ),
      IconButton(
        icon: const Icon(Icons.delete),
        onPressed: _deleteSelectedNotes,
      ),
      extraActions,
    ];
  }

  Future<void> _deleteSelectedNotes() async {
    var settings = Provider.of<Settings>(context, listen: false);
    var shouldDelete = true;
    if (settings.confirmDelete) {
      shouldDelete = (await showDialog(
            context: context,
            builder: (context) => NoteDeleteDialog(num: _selectedNotes.length),
          )) ==
          true;
    }
    if (shouldDelete == true) {
      var repo = context.read<GitJournalRepo>();
      repo.removeNotes(_selectedNotes);
    }

    _resetSelection();
  }

  Future<void> _moveSelectedNotesToFolder() async {
    var destFolder = await showDialog<NotesFolderFS>(
      context: context,
      builder: (context) => FolderSelectionDialog(),
    );
    if (destFolder != null) {
      var repo = context.read<GitJournalRepo>();
      var r = await repo.moveNotes(_selectedNotes, destFolder);
      showResultError(context, r);
    }

    _resetSelection();
  }

  void _resetSelection() {
    setState(() {
      _selectedNotes = [];
    });
  }
}

class _SliverHeader extends StatelessWidget {
  final String text;
  const _SliverHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Text(text, style: textTheme.titleSmall),
      ),
    );
  }
}

Future<void> syncRepo(BuildContext context) async {
  try {
    var container = context.read<GitJournalRepo>();
    await container.syncNotes();
  } on GitException catch (e) {
    showErrorMessageSnackbar(
      context,
      context.loc.widgetsFolderViewSyncError(e.cause),
    );
  } catch (e) {
    showErrorSnackbar(context, e);
  }
}
