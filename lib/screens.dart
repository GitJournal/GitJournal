/*
 * SPDX-FileCopyrightText: 2023 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

// ignore_for_file: depend_on_referenced_packages

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_setup/apis/api_fakes.dart';
import 'package:git_setup/apis/githost_factory.dart';
import 'package:git_setup/autoconfigure.dart';
import 'package:git_setup/clone_url.dart';
import 'package:git_setup/cloning.dart';
import 'package:git_setup/git_transfer_progress.dart';
import 'package:git_setup/loading_error.dart';
import 'package:git_setup/repo_selector.dart';
import 'package:git_setup/screens.dart';
import 'package:git_setup/screens_stories.dart';
import 'package:git_setup/sshkey.dart';
import 'package:gitjournal/core/folder/sorting_mode.dart';
import 'package:gitjournal/core/notes/note.dart';
import 'package:gitjournal/editors/common_types.dart';
import 'package:gitjournal/editors/note_editor_selection_dialog.dart';
import 'package:gitjournal/folder_listing/view/folder_listing.dart';
import 'package:gitjournal/folder_views/common_types.dart';
import 'package:gitjournal/folder_views/folder_view_configuration_dialog.dart';
import 'package:gitjournal/folder_views/folder_view_selection_dialog.dart';
import 'package:gitjournal/folder_views/standard_view.dart';
import 'package:gitjournal/iap/purchase_thankyou_screen.dart';
import 'package:gitjournal/iap/purchase_widget.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/screens/onboarding_screens.dart';
import 'package:gitjournal/settings/settings_git_remote.dart';
import 'package:gitjournal/settings/settings_git_widgets.dart';
import 'package:gitjournal/settings/settings_note_metadata.dart';
import 'package:gitjournal/settings/settings_screen.dart';
import 'package:gitjournal/settings/widgets/settings_list_preference.dart';
import 'package:gitjournal/widgets/app_drawer.dart';
import 'package:gitjournal/widgets/note_delete_dialog.dart';
import 'package:gitjournal/widgets/rename_dialog.dart';
import 'package:gitjournal/widgets/setup.dart';
import 'package:gitjournal/widgets/sorting_mode_selection_dialog.dart';
import 'package:widgetbook/widgetbook.dart';

Future<void> _defaultOnCreate(WidgetTester tester) async {}
typedef BuilderFn = Widget Function(BuildContext);

class TestScreen {
  final String name;
  final BuilderFn builder;

  @Deprecated('Should not be committed')
  final bool solo;
  final bool skipGolden;
  final bool skipWidgetBook;
  final Future<void> Function(WidgetTester tester) onCreate;

  TestScreen({
    required this.name,
    required this.builder,
    this.solo = false,
    this.skipGolden = false,
    this.skipWidgetBook = false,
    this.onCreate = _defaultOnCreate,
  });
}

class TestScreenGroup {
  final String name;
  final List<TestScreen> screens;

  TestScreenGroup({required this.name, required this.screens});

  // ignore: deprecated_member_use_from_same_package
  bool get hasSolo => screens.firstWhereOrNull((s) => s.solo == true) != null;
}

typedef BuildDepsFn = Widget Function(BuildContext, Widget child);

WidgetbookCategory buildWidgetbookCategory(
  String name,
  List<TestScreenGroup> allScreens,
  BuildDepsFn buildDeps,
) {
  return WidgetbookCategory(
    name: name,
    widgets: [
      for (var group in allScreens)
        WidgetbookComponent(
          name: group.name,
          isExpanded: true,
          useCases: [
            for (var screen in group.screens)
              if (!screen.skipWidgetBook)
                WidgetbookUseCase(
                  name: screen.name,
                  builder: (context) => buildDeps(
                    context,
                    Builder(builder: screen.builder),
                  ),
                ),
          ],
        ),
    ],
  );
}

const _publicKey =
    "ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHAzODQAAAAIbmlzdHAzODQAAABhBJ9OSG+YIxqsZiXWisqJIqRStX5wjy9oMrT9gnB85jgR03RjMBWpxXAtrlreo7ljDqhs9g3zdXq/oxcPgzyS+mm33A4WTGGY0u4RbxY14q8V1p/CVu5sd39UYpwYsj0HLw== vishesh@Visheshs-MacBook-Pro.local";

var allScreens = [
  TestScreenGroup(name: "OnBoarding", screens: [
    TestScreen(
      name: "Page 1",
      builder: (context) => const OnBoardingScreen(
        skipPage1: false,
        skipPage2: false,
        skipPage3: false,
      ),
    ),
    TestScreen(
      name: "Page 2",
      builder: (context) => const OnBoardingScreen(
        skipPage1: true,
        skipPage2: false,
        skipPage3: false,
      ),
    ),
    TestScreen(
      name: "Page 3",
      builder: (context) => const OnBoardingScreen(
        skipPage1: true,
        skipPage2: true,
        skipPage3: false,
      ),
    ),
  ]),
  TestScreenGroup(name: "Payment", screens: [
    TestScreen(name: "Thank You", builder: (_) => PurchaseThankYouScreen()),
    TestScreen(
      name: "Purchase Failed",
      builder: (_) => const PurchaseFailedDialog("Foo"),
    ),
  ]),
  TestScreenGroup(name: "Setup", screens: [
    TestScreen(
      name: "Main",
      builder: (_) => GitJournalGitSetupScreen(
        repoFolderName: "foo",
        onCompletedFunction: (_, __) async {},
      ),
    ),
    TestScreen(
      name: "Choice",
      builder: (_) => GitHostChoicePage(
        onCustomGitHost: () {},
        onKnownGitHost: (GitHostType) {},
      ),
    ),
    TestScreen(
      name: "CloneUrl",
      builder: (_) => GitCloneUrlPage(
        doneFunction: (String arg1) {},
        initialValue: '',
      ),
    ),
    TestScreen(
      name: "AutoConfigureChoice",
      builder: (_) => GitHostAutoConfigureChoicePage(
        onDone: (GitHostSetupType) {},
      ),
    ),
    TestScreen(
      name: "KeyChoice",
      builder: (_) => GitHostSetupKeyChoicePage(
        onGenerateKeys: () {},
        onUserProvidedKeys: () {},
      ),
    ),
    TestScreen(
      name: "CloneUrlKnownProvider",
      builder: (_) => GitCloneUrlKnownProviderPage(
        doneFunction: (_) {},
        gitHostType: GitHostType.GitHub,
        initialValue: '',
        launchCreateUrlPage: () {},
      ),
    ),
    TestScreen(
      name: "AutoConfigure",
      builder: (_) => GitHostSetupAutoConfigurePage(
        gitHostType: GitHostType.GitHub,
        onDone: (_, __) {},
        providers: DummyProvider(),
      ),
    ),
    TestScreen(
      name: "SshKeyUnknownProvider",
      builder: (_) => GitHostSetupSshKeyUnknownProviderPage(
        copyKeyFunction: (_) {},
        doneFunction: () {},
        publicKey: _publicKey,
        regenerateFunction: () {},
      ),
    ),
    TestScreen(
      name: "UserProvidedKeys",
      builder: (_) => GitHostUserProvidedKeysPage(
        doneFunction: (a, b, c) {},
      ),
    ),
    TestScreen(
      name: "RepoSelector",
      builder: (_) => GitHostSetupRepoSelector(
        gitHost: GitHubFake(gitHubDataFake),
        userInfo: UserInfo(
          email: 'me@vhanda.in',
          name: 'vhanda',
          username: 'vhanda',
        ),
        onDone: (GitHostRepo arg1) {},
      ),
    ),
    TestScreen(
      name: "RepoSelector New Repo",
      builder: (_) => GitHostSetupRepoSelector(
        gitHost: GitHubFake(gitHubDataFake),
        userInfo: UserInfo(
          email: 'me@vhanda.in',
          name: 'vhanda',
          username: 'vhanda',
        ),
        onDone: (GitHostRepo arg1) {},
        initialSearchText: "dart",
      ),
    ),
    TestScreen(
      name: "Cloning",
      builder: (_) => GitHostCloningPage(
        cloneProgress: GitTransferProgress(),
        errorMessage: null,
      ),
    ),
    TestScreen(
      name: "SshKeyKnownProvider",
      builder: (_) => GitHostSetupSshKeyKnownProviderPage(
        copyKeyFunction: (BuildContext arg1) {},
        doneFunction: () {},
        openDeployKeyPage: () {},
        publicKey: _publicKey,
        regenerateFunction: () {},
      ),
    ),
    TestScreen(
      name: "Error",
      builder: (_) => const GitHostSetupLoadingErrorPage(
        errorMessage: 'Error Message',
        loadingMessage: 'Loading Message',
      ),
    ),
    TestScreen(
      name: "Loading",
      builder: (_) => const GitHostSetupLoadingErrorPage(
        errorMessage: null,
        loadingMessage: 'Loading Message',
      ),
    ),
  ]),
  TestScreenGroup(name: "Settings", screens: [
    TestScreen(name: "Home", builder: (_) => SettingsScreen()),
    TestScreen(
      name: "Irreversible Action Confirmation Dialog",
      builder: (context) => IrreversibleActionConfirmationDialog(
        title: context.loc.settingsDeleteRepo,
        subtitle: context.loc.settingsGitRemoteChangeHostSubtitle,
      ),
    ),
    TestScreen(
      name: "Git Author Email Dialog",
      builder: (_) => const GitAuthorEmailDialog(),
    ),
    TestScreen(
      name: "Custom MetaData Input Dialog",
      builder: (_) => const CustomMetaDataInputDialog(value: ""),
    ),
    TestScreen(
      name: "List Preference Selection Dialog",
      builder: (_) => const ListPreferenceSelectionDialog(
        options: ["A", "B"],
        title: "Title",
        currentOption: "A",
      ),
    )
  ]),
  TestScreenGroup(name: "Folder View", screens: [
    TestScreen(
      name: "Folder View Configuration Dialog",
      builder: (_) => FolderViewConfigurationDialog(
        headerType: StandardViewHeader.TitleOrFileName,
        showSummary: true,
        onHeaderTypeChanged: (_) {},
        onShowSummaryChanged: (_) {},
      ),
    ),
    TestScreen(
      name: "Folder View Selection Dialog",
      builder: (_) => FolderViewSelectionDialog(
        viewType: FolderViewType.Standard,
        onViewChange: (_) {},
      ),
    ),
  ]),
  TestScreenGroup(name: "Folder Listing", screens: [
    TestScreen(
      name: "Create Folder Alert Dialog",
      builder: (_) => CreateFolderAlertDialog(),
    ),
    TestScreen(
      name: "Delete Folder Alert Dialog",
      builder: (_) => DeleteFolderErrorDialog(),
    ),
  ]),
  TestScreenGroup(name: "Editor", screens: [
    TestScreen(
      name: "Selection Dialog",
      builder: (_) => const NoteEditorSelectionDialog(
        EditorType.Markdown,
        NoteFileFormat.Markdown,
      ),
    ),
    TestScreen(
      name: "Rename Dialog",
      builder: (context) => RenameDialog(
        oldPath: "oldPath",
        inputDecoration: context.loc.widgetsNoteEditorFileName,
        dialogTitle: context.loc.widgetsNoteEditorRenameFile,
      ),
    ),
    TestScreen(
      name: "Delete Dialog - 1",
      builder: (context) => const NoteDeleteDialog(num: 1),
    ),
    TestScreen(
      name: "Delete Dialog - 2",
      builder: (context) => const NoteDeleteDialog(num: 2),
    ),
  ]),
  TestScreenGroup(name: "Misc", screens: [
    TestScreen(name: "AppDrawer", builder: (_) => AppDrawer()),
    TestScreen(
      name: "Sorting Mode Selection Dialog",
      builder: (_) => SortingModeSelectionDialog(
        SortingMode(SortingField.Default, SortingOrder.Default),
      ),
    ),
  ]),
];
