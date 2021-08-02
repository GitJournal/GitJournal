import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/logger/logger.dart';

enum Event {
  NoteAdded,
  NoteUpdated,
  NoteDeleted,
  NoteUndoDeleted,
  NoteRenamed,
  NoteMoved,
  FileRenamed,
  FolderAdded,
  FolderDeleted,
  FolderRenamed,
  FolderConfigUpdated,
  RepoSynced,

  DrawerSetupGitHost,
  DrawerShare,
  DrawerRate,
  DrawerFeedback,
  DrawerBugReport,
  DrawerSettings,

  PurchaseScreenOpen,
  PurchaseScreenClose,
  PurchaseScreenThankYou,

  GitHostSetupError,
  GitHostSetupComplete,
  GitHostSetupGitCloneError,
  GitHostSetupButtonClick,

  Settings,
  FeatureTimelineGithubClicked,

  AppFirstOpen,
  AppUpdate,

  // FIXME: Add os_update

  /*
  Firebase Automatic Events:
    app_update:
      previous_app_version

    first_open
    in_app_purchase
    screen_view
    session_start
    user_engagement

  */
}

String _eventToString(Event e) {
  switch (e) {
    case Event.NoteAdded:
      return "note_added";
    case Event.NoteUpdated:
      return "note_updated";
    case Event.NoteDeleted:
      return "note_deleted";
    case Event.NoteUndoDeleted:
      return "note_undo_deleted";
    case Event.NoteRenamed:
      return "note_renamed";
    case Event.NoteMoved:
      return "note_moved";

    case Event.FileRenamed:
      return "file_renamed";

    case Event.FolderAdded:
      return "folder_added";
    case Event.FolderDeleted:
      return "folder_deleted";
    case Event.FolderRenamed:
      return "folder_renamed";
    case Event.FolderConfigUpdated:
      return "folder_config_updated";

    case Event.RepoSynced:
      return "repo_synced";

    case Event.DrawerSetupGitHost:
      return "drawer_setupGitHost";
    case Event.DrawerShare:
      return "drawer_share";
    case Event.DrawerRate:
      return "drawer_rate";
    case Event.DrawerFeedback:
      return "drawer_feedback";
    case Event.DrawerBugReport:
      return "drawer_bugreport";
    case Event.DrawerSettings:
      return "drawer_settings";

    case Event.PurchaseScreenOpen:
      return "purchase_screen_open";
    case Event.PurchaseScreenClose:
      return "purchase_screen_close";
    case Event.PurchaseScreenThankYou:
      return "purchase_screen_thank_you";

    case Event.GitHostSetupError:
      return "githostsetup_error";
    case Event.GitHostSetupComplete:
      return "onboarding_complete";
    case Event.GitHostSetupGitCloneError:
      return "onboarding_gitClone_error";
    case Event.GitHostSetupButtonClick:
      return "githostsetup_button_click";

    case Event.Settings:
      return "settings";

    case Event.FeatureTimelineGithubClicked:
      return "feature_timeline_github_clicked";

    case Event.AppFirstOpen:
      return "gj_first_open";
    case Event.AppUpdate:
      return "gj_app_update";
  }
}

class Analytics {
  bool enabled = false;

  static Analytics? _global;
  static Analytics init({required bool enable}) {
    _global = Analytics();
    _global!.enabled = enable;

    return _global!;
  }

  static Analytics get instance => _global!;

  Future<void> log({
    required Event e,
    Map<String, String> parameters = const {},
  }) async {
    String name = _eventToString(e);
    if (enabled) {
      // await firebase.logEvent(name: name, parameters: parameters);
    }
    captureErrorBreadcrumb(name: name, parameters: parameters);
  }

  Future<void> setCurrentScreen({required String screenName}) async {
    if (!enabled) {
      return;
    }
    // await firebase.setCurrentScreen(screenName: screenName);
  }

  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    if (!enabled) {
      return;
    }
    // await firebase.setUserProperty(name: name, value: value);
  }
}

void logEvent(Event event, {Map<String, String> parameters = const {}}) {
  Analytics.instance.log(e: event, parameters: parameters);
  Log.d("$event", props: parameters);
}
