/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

class CommitMessageBuilder {
  String addNote(String spec) => "Added Note $spec";
  String addFolder(String spec) => "Added Folder $spec";

  String renameFolder(String oldSpec, String newSpec) =>
      "Renamed Folder $oldSpec -> $newSpec";
  String renameNote(String oldSpec, String newSpec) =>
      "Renamed Note $oldSpec -> $newSpec";
  String renameFile(String oldSpec, String newSpec) =>
      "Renamed File $oldSpec -> $newSpec";

  String moveNote(String oldSpec, String newSpec) =>
      "Moved Note $oldSpec -> $newSpec";

  String removeNote(String spec) => "Removed Note $spec";
  String removeFolder(String spec) => "Removed Folder $spec";

  String updateNote(String spec) => "Updated Note $spec";
}
