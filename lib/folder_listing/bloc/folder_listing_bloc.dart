/*
 * SPDX-FileCopyrightText: 2024 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:gitjournal/folder_listing/model/folder_listing_model.dart';
import 'package:gitjournal/repository.dart';

import 'folder_listing_event.dart';
import 'folder_listing_state.dart';

class FolderListingBloc extends Bloc<FolderListingEvent, FolderListingState> {
  final GitJournalRepo repo;

  FolderListingBloc(this.repo) : super(FolderListingLoading()) {
    on<FolderListingStarted>(_onFolderListingStarted);
    on<FolderListingFolderSelected>(_onFolderSelected);
    on<FolderListingFolderUnselected>(_onFolderUnselected);
    on<FolderListingFolderRenamed>(_onFolderRenamed);
    on<FolderListingFolderDeleted>(_onFolderDeleted);
    on<FolderListingFolderCreated>(_onFolderCreated);
  }

  Future<void> _onFolderListingStarted(
    FolderListingStarted event,
    Emitter<FolderListingState> emit,
  ) async {
    try {
      var rootFolder = convertNotesFolderFS(null, repo.rootFolder);
      emit(FolderListingLoaded(rootFolder));
    } catch (e) {
      emit(FolderListingError(e.toString()));
    }
  }

  Future<void> _onFolderSelected(
    FolderListingFolderSelected event,
    Emitter<FolderListingState> emit,
  ) async {
    assert(state is FolderListingLoaded);

    var folder = (state as FolderListingLoaded).folder;
    var selectedFolder = repo.rootFolder.getFolderWithSpec(event.path);
    if (selectedFolder == null) {
      throw Exception("Folder not found");
    }

    var newState = FolderListingLoaded(
      folder,
      selectedFolderPath: selectedFolder.folderPath,
      canRename: event.path.isNotEmpty,
      canCreate: true,
      canDelete: !selectedFolder.hasNotesRecursive,
    );
    emit(newState);
  }

  Future<void> _onFolderUnselected(
    FolderListingFolderUnselected event,
    Emitter<FolderListingState> emit,
  ) async {
    assert(state is FolderListingLoaded);

    var folder = (state as FolderListingLoaded).folder;
    emit(FolderListingLoaded(folder));
  }

  Future<void> _onFolderRenamed(
    FolderListingFolderRenamed event,
    Emitter<FolderListingState> emit,
  ) async {
    assert(state is FolderListingLoaded);

    try {
      var folder = repo.rootFolder.getFolderWithSpec(event.oldPath);
      if (folder == null) {
        throw Exception("Source Folder not found");
      }
      await repo.renameFolder(folder, event.newPath);

      var rootFolder = convertNotesFolderFS(null, repo.rootFolder);
      emit(FolderListingLoaded(rootFolder));
    } catch (e) {
      var newState = (state as FolderListingLoaded)
          .copyWith(errorMessage: e.toString())
          .resetSelectedPath();
      emit(newState);
      return;
    }
  }

  Future<void> _onFolderDeleted(
    FolderListingFolderDeleted event,
    Emitter<FolderListingState> emit,
  ) async {
    assert(state is FolderListingLoaded);

    try {
      var folder = repo.rootFolder.getFolderWithSpec(event.path);
      if (folder == null) {
        throw Exception("Source Folder not found");
      }
      await repo.removeFolder(folder);

      var rootFolder = convertNotesFolderFS(null, repo.rootFolder);
      emit(FolderListingLoaded(rootFolder));
    } catch (e) {
      var newState = (state as FolderListingLoaded)
          .copyWith(errorMessage: e.toString())
          .resetSelectedPath();
      emit(newState);
    }
  }

  Future<void> _onFolderCreated(
    FolderListingFolderCreated event,
    Emitter<FolderListingState> emit,
  ) async {
    assert(state is FolderListingLoaded);

    var selectedFolder = (state as FolderListingLoaded).selectedFolderPath;
    try {
      var parentFolder = selectedFolder == null
          ? repo.rootFolder
          : repo.rootFolder.getFolderWithSpec(selectedFolder);
      if (parentFolder == null) {
        throw Exception("Parent Folder not found");
      }
      await repo.createFolder(parentFolder, event.folderName);

      var rootFolder = convertNotesFolderFS(null, repo.rootFolder);
      emit(FolderListingLoaded(rootFolder));
    } catch (e) {
      var newState = (state as FolderListingLoaded)
          .copyWith(errorMessage: e.toString())
          .resetSelectedPath();
      emit(newState);
    }
  }
}
