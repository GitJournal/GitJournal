import 'package:journal/note.dart';

class AppState {
  // FIXME: Make these 2 final
  String localGitRepoPath = "";
  bool localGitRepoConfigured = false;

  // FIXME: Rename from 'path' to folderName
  String remoteGitRepoFolderName = "";
  String remoteGitRepoSubFolder = "";
  bool remoteGitRepoConfigured = false;

  bool hasJournalEntries = false;
  bool onBoardingCompleted = false;

  // FIXME: Make final
  /// This is the directory where all the git repos are stored
  String gitBaseDirectory = "";

  bool isLoadingFromDisk;
  List<Note> notes = [];

  AppState({
    this.isLoadingFromDisk = false,
  });
}
