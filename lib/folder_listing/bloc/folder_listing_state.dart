/*
 * SPDX-FileCopyrightText: 2024 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:equatable/equatable.dart';
import 'package:gitjournal/folder_listing/model/folder_listing_model.dart';

sealed class FolderListingState extends Equatable {
  const FolderListingState();

  @override
  List<Object> get props => [];
}

final class FolderListingLoading extends FolderListingState {}

final class FolderListingLoaded extends FolderListingState {
  final FolderListingFolder folder;
  final String? selectedFolderPath;
  final String? errorMessage;

  final bool canRename;
  final bool canCreate;
  final bool canDelete;

  const FolderListingLoaded(
    this.folder, {
    this.selectedFolderPath,
    this.errorMessage,
    this.canRename = false,
    this.canCreate = false,
    this.canDelete = false,
  });

  @override
  List<Object> get props => [
        folder,
        selectedFolderPath ?? "",
        errorMessage ?? "",
        canRename,
        canCreate,
        canDelete,
      ];

  FolderListingLoaded copyWith({
    FolderListingFolder? folder,
    String? selectedFolderPath,
    String? errorMessage,
    bool? canRename,
    bool? canCreate,
    bool? canDelete,
  }) {
    return FolderListingLoaded(
      folder ?? this.folder,
      selectedFolderPath: selectedFolderPath ?? this.selectedFolderPath,
      errorMessage: errorMessage ?? this.errorMessage,
      canRename: canRename ?? this.canRename,
      canCreate: canCreate ?? this.canCreate,
      canDelete: canDelete ?? this.canDelete,
    );
  }

  FolderListingLoaded resetSelectedPath() {
    return FolderListingLoaded(
      folder,
      selectedFolderPath: null,
      errorMessage: errorMessage,
      canRename: canRename,
      canCreate: canCreate,
      canDelete: canDelete,
    );
  }
}

final class FolderListingError extends FolderListingState {
  final String message;

  const FolderListingError(this.message);

  @override
  List<Object> get props => [message];
}
