/*
 * SPDX-FileCopyrightText: 2024 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:equatable/equatable.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';

class FolderListingFolder extends Equatable {
  final String path;
  final bool hasSubFolders;
  final int noteCount;
  final String publicName;

  final FolderListingFolder? parent;
  final List<FolderListingFolder> subFolders;

  const FolderListingFolder({
    required this.path,
    required this.hasSubFolders,
    required this.noteCount,
    required this.publicName,
    required this.parent,
    required this.subFolders,
  });

  @override
  List<Object> get props =>
      [path, hasSubFolders, noteCount, publicName, parent ?? "", subFolders];

  FolderListingFolder copyWith({
    String? path,
    bool? hasSubFolders,
    int? noteCount,
    String? publicName,
    FolderListingFolder? parent,
    List<FolderListingFolder>? subFolders,
  }) {
    return FolderListingFolder(
      path: path ?? this.path,
      hasSubFolders: hasSubFolders ?? this.hasSubFolders,
      noteCount: noteCount ?? this.noteCount,
      publicName: publicName ?? this.publicName,
      parent: parent ?? this.parent,
      subFolders: subFolders ?? this.subFolders,
    );
  }
}

FolderListingFolder convertNotesFolderFS(
  FolderListingFolder? parent,
  NotesFolderFS fsFolder,
) {
  final root = FolderListingFolder(
    path: fsFolder.folderPath,
    hasSubFolders: fsFolder.subFolders.isNotEmpty,
    noteCount: fsFolder.notes.length,
    publicName: fsFolder.name,
    parent: parent,
    subFolders: const [],
  );
  if (fsFolder.subFolders.isEmpty) {
    return root;
  }

  var subFolders = fsFolder.subFolders
      .map((f) => convertNotesFolderFS(root, f.fsFolder as NotesFolderFS))
      .toList();

  return root.copyWith(subFolders: subFolders);
}
