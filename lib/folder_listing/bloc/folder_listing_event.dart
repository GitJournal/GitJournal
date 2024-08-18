/*
 * SPDX-FileCopyrightText: 2024 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:equatable/equatable.dart';

sealed class FolderListingEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class FolderListingStarted extends FolderListingEvent {}

final class FolderListingFolderSelected extends FolderListingEvent {
  final String path;

  FolderListingFolderSelected(this.path);

  @override
  List<Object> get props => [path];
}

final class FolderListingFolderUnselected extends FolderListingEvent {}

final class FolderListingFolderRenamed extends FolderListingEvent {
  final String oldPath;
  final String newPath;

  FolderListingFolderRenamed({required this.oldPath, required this.newPath});

  @override
  List<Object> get props => [oldPath, newPath];
}

final class FolderListingFolderDeleted extends FolderListingEvent {
  final String path;

  FolderListingFolderDeleted(this.path);

  @override
  List<Object> get props => [path];
}

final class FolderListingFolderCreated extends FolderListingEvent {
  final String folderName;

  FolderListingFolderCreated(this.folderName);

  @override
  List<Object> get props => [folderName];
}
