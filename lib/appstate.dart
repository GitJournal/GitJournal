import 'package:shared_preferences/shared_preferences.dart';
import 'package:fimber/fimber.dart';
import 'package:gitjournal/note.dart';

class AppState {
  //
  // Saved on Disk
  //
  // FIXME: Make these 2 final
  String localGitRepoPath = "";
  bool localGitRepoConfigured = false;

  // FIXME: Rename from 'path' to folderName
  String remoteGitRepoFolderName = "";
  String remoteGitRepoSubFolder = "";
  bool remoteGitRepoConfigured = false;

  bool onBoardingCompleted = false;

  //
  // Temporary
  //
  /// This is the directory where all the git repos are stored
  String gitBaseDirectory = "";

  bool get hasJournalEntries {
    return notes.isNotEmpty;
  }

  List<Note> notes = [];

  AppState(SharedPreferences pref) {
    localGitRepoConfigured = pref.getBool("localGitRepoConfigured") ?? false;
    remoteGitRepoConfigured = pref.getBool("remoteGitRepoConfigured") ?? false;
    localGitRepoPath = pref.getString("localGitRepoPath") ?? "";
    remoteGitRepoFolderName = pref.getString("remoteGitRepoPath") ?? "";
    remoteGitRepoSubFolder = pref.getString("remoteGitRepoSubFolder") ?? "";
    onBoardingCompleted = pref.getBool("onBoardingCompleted") ?? false;
  }

  void dumpToLog() {
    Fimber.d(" ---- Settings ---- ");
    Fimber.d("localGitRepoConfigured: $localGitRepoConfigured");
    Fimber.d("remoteGitRepoConfigured: $remoteGitRepoConfigured");
    Fimber.d("localGitRepoPath: $localGitRepoPath");
    Fimber.d("remoteGitRepoFolderName: $remoteGitRepoFolderName");
    Fimber.d("remoteGitRepoSubFolder: $remoteGitRepoSubFolder");
    Fimber.d("onBoardingCompleted: $onBoardingCompleted");
    Fimber.d(" ------------------ ");
  }

  Future save(SharedPreferences pref) async {
    await pref.setBool("localGitRepoConfigured", localGitRepoConfigured);
    await pref.setBool("remoteGitRepoConfigured", remoteGitRepoConfigured);
    await pref.setString("localGitRepoPath", localGitRepoPath);
    await pref.setString("remoteGitRepoPath", remoteGitRepoFolderName);
    await pref.setString("remoteGitRepoSubFolder", remoteGitRepoSubFolder);
    await pref.setBool("onBoardingCompleted", onBoardingCompleted);
  }
}
