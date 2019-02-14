import 'package:journal/note.dart';

class AppState {
  // FIXME: Make these 2 final
  String localGitRepoPath = "";
  bool localGitRepoConfigured = false;

  // FIXME: Rename from 'path' to folderName
  String remoteGitRepoPath = "";
  bool remoteGitRepoConfigured = false;

  bool hasJournalEntries = false;

  // FIXME: Make final
  String gitBaseDirectory = "";

  bool isLoadingFromDisk;
  List<Note> notes;

  AppState({
    this.isLoadingFromDisk = false,
    this.notes = const [],
  });
}
