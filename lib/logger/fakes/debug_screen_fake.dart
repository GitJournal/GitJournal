/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart';

import 'package:gitjournal/logger/debug_screen.dart';
import 'package:gitjournal/logger/logger.dart';

class DebugScreenFake extends StatefulWidget {
  const DebugScreenFake({Key? key}) : super(key: key);

  @override
  _DebugScreenFakeState createState() => _DebugScreenFakeState();
}

class _DebugScreenFakeState extends State<DebugScreenFake> {
  @override
  void initState() {
    var yesterday = DateTime.now()..add(const Duration(days: -1));
    var yesterdayStr = yesterday.toIso8601String().substring(0, 10);
    var filePath = p.join(Log.logFolderPath, '$yesterdayStr.jsonl');
    File(filePath).writeAsStringSync(_loggerData);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const DebugScreen();
  }
}

var _loggerData =
    '''{"t":1627057086501,"l":"i","msg":"--------------------------------"}
{"t":1627057086501,"l":"i","msg":"--------------------------------"}
{"t":1627057086501,"l":"i","msg":"--------------------------------"}
{"t":1627057086501,"l":"i","msg":"--------- App Launched ---------"}
{"t":1627057086501,"l":"i","msg":"--------------------------------"}
{"t":1627057086501,"l":"i","msg":"--------------------------------"}
{"t":1627057086501,"l":"i","msg":"--------------------------------"}
{"t":1627057086501,"l":"i","msg":"AppSetting {onBoardingCompleted: true, collectUsageStatistics: true, collectCrashReports: true, version: 0, proMode: true, validateProMode: true, proExpirationDate: 2022-06-30T10:25:59.316Z, pseudoId: 3b21f58f-15e4-4b5b-a5fa-1ff3954968bf, debugLogLevel: v, experimentalFs: false, experimentalMarkdownToolbar: true, experimentalGraphView: false, experimentalZeroConf: false, experimentalAccounts: false, experimentalGitMerge: false, experimentalGitOps: false}"}
{"t":1627057086505,"l":"i","msg":"Running on Android","p":{"id":"HUAWEISNE-L21","host":"cn-central-1b-2d99f2d101595983260308-672168572-32bbf","tags":"release-keys","type":"user","model":"SNE-LX1","board":"SNE","brand":"HUAWEI","device":"HWSNE","product":"SNE-LX1","display":"SNE-LX1 10.0.0.245(C432E10R1P1)","hardware":"kirin710","androidId":"7e4053c59bad609e","bootloader":"unknown","version":{"baseOS":"HUAWEI/SNE-LX1/HWSNE:10/HUAWEISNE-L21/10.0.0.212C432:user/release-keys","sdkInt":29,"release":"10","codename":"REL","incremental":"10.0.0.245C432","previewSdkInt":0,"securityPatch":"2020-08-01"},"fingerprint":"HUAWEI/SNE-LX1/HWSNE:10/HUAWEISNE-L21/10.0.0.245C432:user/release-keys","manufacturer":"HUAWEI","supportedAbis":["arm64-v8a","armeabi-v7a","armeabi"],"systemFeatures":["android.hardware.sensor.proximity","android.hardware.sensor.accelerometer","android.hardware.faketouch","android.hardware.usb.accessory","android.software.backup","android.hardware.touchscreen","android.hardware.touchscreen.multitouch","android.software.print","com.huawei.software.features.full","android.software.activities_on_secondary_displays","android.software.voice_recognizers","android.software.picture_in_picture","android.hardware.fingerprint","android.hardware.sensor.gyroscope","android.hardware.audio.low_latency","android.software.cant_save_state","android.hardware.opengles.aep","android.hardware.bluetooth","android.hardware.camera.autofocus","android.hardware.telephony.gsm","android.hardware.telephony.ims","android.software.sip.voip","android.hardware.usb.host","android.hardware.audio.output","android.software.verified_boot","android.hardware.camera.flash","android.hardware.camera.front","android.hardware.screen.portrait","android.hardware.nfc","android.software.home_screen","com.huawei.system.feature","android.hardware.microphone","com.huawei.software.features.oversea","android.software.autofill","android.software.securely_removes_users","android.hardware.bluetooth_le","android.hardware.sensor.compass","android.hardware.touchscreen.multitouch.jazzhand","android.software.app_widgets","android.software.input_methods","android.hardware.sensor.light","android.hardware.vulkan.version","android.software.companion_device_setup","android.software.device_admin","android.hardware.camera","com.google.android.feature.ZERO_TOUCH","android.hardware.screen.landscape","android.hardware.ram.normal","android.software.managed_users","android.software.webview","android.hardware.sensor.stepcounter","android.hardware.camera.capability.manual_post_processing","android.hardware.camera.any","android.hardware.camera.capability.raw","android.hardware.vulkan.compute","android.software.connectionservice","android.hardware.touchscreen.multitouch.distinct","android.hardware.location.network","android.software.cts","android.software.sip","android.hardware.wifi.direct","android.software.live_wallpaper","android.software.ipsec_tunnels","android.software.freeform_window_management","android.hardware.nfc.hcef","android.hardware.nfc.uicc","android.hardware.location.gps","android.sofware.nfc.beam","android.software.midi","android.hardware.nfc.any","android.hardware.nfc.hce","android.hardware.wifi","android.hardware.location","android.hardware.vulkan.level","android.software.secure_lock_screen","android.hardware.telephony","android.software.file_based_encryption",null],"isPhysicalDevice":true,"supported32BitAbis":["armeabi-v7a","armeabi"],"supported64BitAbis":["arm64-v8a"]}}
{"t":1627057086507,"l":"i","msg":"App Version: 1.78.1"}
{"t":1627057086507,"l":"i","msg":"App Build Number: 2640"}
{"t":1627057086518,"l":"d","msg":"Analytics Collection: true"}
{"t":1627057086521,"l":"i","msg":"Repo Ids [0]"}
{"t":1627057086521,"l":"i","msg":"Current Id 0"}
{"t":1627057086522,"l":"d","msg":"Event.Settings","p":{"gitAuthor":"true","gitAuthorEmail":"true","noteFileNameFormat":"FromTitle","journalNoteFileNameFormat":"FromTitle","yamlModifiedKey":"modified","yamlCreatedKey":"created","yamlTagsKey":"tags","customMetaData":"","yamlHeaderEnabled":"true","defaultNewNoteFolderSpec":"false","journalEditordefaultNewNoteFolderSpec":"","journalEditorSingleNote":"false","defaultEditor":"Markdown","defaultView":"Journal","sortingField":"Modified","sortingOrder":"desc","remoteSyncFrequency":"automatic","showNoteSummary":"true","folderViewHeaderType":"TitleGenerated","version":"3","markdownDefaultView":"Last Used","markdownLastUsedView":"Edit","homeScreen":"all_notes","theme":"dark","rotateImageGestures":"false","maxImageZoom":"10.0","themeRasterGraphics":"false","themeOverrideTagLocation":"alt_and_tooltip","doNotThemeTags":"notheme, !nt","doThemeTags":"dotheme, !dt","themeVectorGraphics":"on","themeSvgWithBackground":"false","matchCanvasColor":"true","vectorGraphicsAdjustColors":"all","overlayCaption":"true","transparentCaption":"true","blurBehindCaption":"true","tooltipFirst":"false","useAsCaption":"alt_and_tooltip","doNotCaptionTag":"nocaption, !nc","doCaptionTag":"docaption, !dc","imageLocationSpec":"media","zenMode":"false","titleSettings":"h1","swipeToDelete":"true","inlineTagPrefixes":"#","emojiParser":"true","folderName":"obsidian-vault","bottomMenuBar":"true","confirmDelete":"true","storeInternally":"true","storageLocation":"","sshPublicKey":"true","sshPrivateKey":"true"}}
{"t":1627057086522,"l":"i","msg":"Setting {gitAuthor: true, gitAuthorEmail: true, noteFileNameFormat: FromTitle, journalNoteFileNameFormat: FromTitle, yamlModifiedKey: modified, yamlCreatedKey: created, yamlTagsKey: tags, customMetaData: , yamlHeaderEnabled: true, defaultNewNoteFolderSpec: false, journalEditordefaultNewNoteFolderSpec: , journalEditorSingleNote: false, defaultEditor: Markdown, defaultView: Journal, sortingField: Modified, sortingOrder: desc, remoteSyncFrequency: automatic, showNoteSummary: true, folderViewHeaderType: TitleGenerated, version: 3, markdownDefaultView: Last Used, markdownLastUsedView: Edit, homeScreen: all_notes, theme: dark, rotateImageGestures: false, maxImageZoom: 10.0, themeRasterGraphics: false, themeOverrideTagLocation: alt_and_tooltip, doNotThemeTags: notheme, !nt, doThemeTags: dotheme, !dt, themeVectorGraphics: on, themeSvgWithBackground: false, matchCanvasColor: true, vectorGraphicsAdjustColors: all, overlayCaption: true, transparentCaption: true, blurBehindCaption: true, tooltipFirst: false, useAsCaption: alt_and_tooltip, doNotCaptionTag: nocaption, !nc, doCaptionTag: docaption, !dc, imageLocationSpec: media, zenMode: false, titleSettings: h1, swipeToDelete: true, inlineTagPrefixes: #, emojiParser: true, folderName: obsidian-vault, bottomMenuBar: true, confirmDelete: true, storeInternally: true, storageLocation: , sshPublicKey: true, sshPrivateKey: true}"}
{"t":1627057086523,"l":"i","msg":"Loading Repo at path /data/user/0/io.gitjournal.gitjournal/app_flutter/obsidian-vault"}
{"t":1627057086540,"l":"i","msg":"Branch master"}
{"t":1627057086540,"l":"d","msg":"Not syncing because RemoteRepo not configured"}
{"t":1627057086543,"l":"i","msg":"Checking if ProMode should be enabled. Exp: 2022-06-30T10:25:59.316Z"}
{"t":1627057086543,"l":"i","msg":"Not checking PurchaseInfo as exp = 2022-06-30T10:25:59.316Z and cur = 2021-07-23T16:18:06.543166Z"}
{"t":1627057086568,"l":"d","msg":"Received Share with App (media): []"}
{"t":1627057086634,"l":"i","msg":"Notes Cache Loaded: 20 items"}
{"t":1627057086647,"l":"i","msg":"Finished loading the notes cache"}
{"t":1627057088667,"l":"i","msg":"Notes Cache saving: 20 items"}
{"t":1627057088677,"l":"i","msg":"Finished loading all the notes"}
{"t":1627057096534,"l":"i","msg":"Switching to repo with id: 0"}
{"t":1627057096535,"l":"d","msg":"Event.Settings","p":{"gitAuthor":"true","gitAuthorEmail":"true","noteFileNameFormat":"FromTitle","journalNoteFileNameFormat":"FromTitle","yamlModifiedKey":"modified","yamlCreatedKey":"created","yamlTagsKey":"tags","customMetaData":"","yamlHeaderEnabled":"true","defaultNewNoteFolderSpec":"false","journalEditordefaultNewNoteFolderSpec":"","journalEditorSingleNote":"false","defaultEditor":"Markdown","defaultView":"Journal","sortingField":"Modified","sortingOrder":"desc","remoteSyncFrequency":"automatic","showNoteSummary":"true","folderViewHeaderType":"TitleGenerated","version":"3","markdownDefaultView":"Last Used","markdownLastUsedView":"Edit","homeScreen":"all_notes","theme":"dark","rotateImageGestures":"false","maxImageZoom":"10.0","themeRasterGraphics":"false","themeOverrideTagLocation":"alt_and_tooltip","doNotThemeTags":"notheme, !nt","doThemeTags":"dotheme, !dt","themeVectorGraphics":"on","themeSvgWithBackground":"false","matchCanvasColor":"true","vectorGraphicsAdjustColors":"all","overlayCaption":"true","transparentCaption":"true","blurBehindCaption":"true","tooltipFirst":"false","useAsCaption":"alt_and_tooltip","doNotCaptionTag":"nocaption, !nc","doCaptionTag":"docaption, !dc","imageLocationSpec":"media","zenMode":"false","titleSettings":"h1","swipeToDelete":"true","inlineTagPrefixes":"#","emojiParser":"true","folderName":"obsidian-vault","bottomMenuBar":"true","confirmDelete":"true","storeInternally":"true","storageLocation":"","sshPublicKey":"true","sshPrivateKey":"true"}}
{"t":1627057096536,"l":"i","msg":"Setting {gitAuthor: true, gitAuthorEmail: true, noteFileNameFormat: FromTitle, journalNoteFileNameFormat: FromTitle, yamlModifiedKey: modified, yamlCreatedKey: created, yamlTagsKey: tags, customMetaData: , yamlHeaderEnabled: true, defaultNewNoteFolderSpec: false, journalEditordefaultNewNoteFolderSpec: , journalEditorSingleNote: false, defaultEditor: Markdown, defaultView: Journal, sortingField: Modified, sortingOrder: desc, remoteSyncFrequency: automatic, showNoteSummary: true, folderViewHeaderType: TitleGenerated, version: 3, markdownDefaultView: Last Used, markdownLastUsedView: Edit, homeScreen: all_notes, theme: dark, rotateImageGestures: false, maxImageZoom: 10.0, themeRasterGraphics: false, themeOverrideTagLocation: alt_and_tooltip, doNotThemeTags: notheme, !nt, doThemeTags: dotheme, !dt, themeVectorGraphics: on, themeSvgWithBackground: false, matchCanvasColor: true, vectorGraphicsAdjustColors: all, overlayCaption: true, transparentCaption: true, blurBehindCaption: true, tooltipFirst: false, useAsCaption: alt_and_tooltip, doNotCaptionTag: nocaption, !nc, doCaptionTag: docaption, !dc, imageLocationSpec: media, zenMode: false, titleSettings: h1, swipeToDelete: true, inlineTagPrefixes: #, emojiParser: true, folderName: obsidian-vault, bottomMenuBar: true, confirmDelete: true, storeInternally: true, storageLocation: , sshPublicKey: true, sshPrivateKey: true}"}
{"t":1627057096536,"l":"i","msg":"Loading Repo at path /data/user/0/io.gitjournal.gitjournal/app_flutter/obsidian-vault"}
{"t":1627057096555,"l":"i","msg":"Branch master"}
{"t":1627057096555,"l":"d","msg":"Not syncing because RemoteRepo not configured"}
{"t":1627057096558,"l":"i","msg":"Notes Cache Loaded: 20 items"}
{"t":1627057096559,"l":"i","msg":"Finished loading the notes cache"}
{"t":1627057098386,"l":"i","msg":"Notes Cache saving: 20 items"}
{"t":1627057098420,"l":"i","msg":"Finished loading all the notes"}
{"t":1627057102497,"l":"d","msg":"Event.DrawerSetupGitHost"}
{"t":1627057105368,"l":"d","msg":"githostsetup_button_click Custom"}
{"t":1627057105368,"l":"d","msg":"Event.GitHostSetupButtonClick","p":{"text":"Custom","icon_url":""}}
{"t":1627057328024,"l":"d","msg":"githostsetup_button_click Custom"}
{"t":1627057328024,"l":"d","msg":"Event.GitHostSetupButtonClick","p":{"text":"Custom","icon_url":""}}
{"t":1627057338987,"l":"d","msg":"githostsetup_button_click Next"}
{"t":1627057338987,"l":"d","msg":"Event.GitHostSetupButtonClick","p":{"text":"Next","icon_url":""}}
{"t":1627057344755,"l":"d","msg":"githostsetup_button_click Provide Custom SSH Keys"}
{"t":1627057344755,"l":"d","msg":"Event.GitHostSetupButtonClick","p":{"text":"Provide Custom SSH Keys","icon_url":""}}
{"t":1627057395229,"l":"d","msg":"githostsetup_button_click Generate new keys"}
{"t":1627057395229,"l":"d","msg":"Event.GitHostSetupButtonClick","p":{"text":"Generate new keys","icon_url":""}}
{"t":1627057399348,"l":"i","msg":"Generating KeyPair took: 0:00:04.118483"}
{"t":1627057399349,"l":"d","msg":"Keys Dir: [/data/user/0/io.gitjournal.gitjournal/code_cache/keysNWVBLR/id_rsa, /data/user/0/io.gitjournal.gitjournal/code_cache/keysNWVBLR/id_rsa.pub]"}
{"t":1627057399355,"l":"d","msg":"PublicKey: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDLxHLsMFqDHgh6QoIlqXvgI8V6CDDWrK9b8HsWj9fIziV8Ty1cd3N8/0oyXxilfAKRjQiP7cQ682iZm+t67hDxV5mfCQ/xNEgLknkkgNIQvXEj7zvRk6B121UQQQo55pzSyTxNtrKGIHcJS9UsWY2TjA+Vk4WLLHKobjfg2oJVq/nWM7HoTNlK2CtFsz4XlFmMQppANkQ7YyUj2+HolueAahlx2RJHgj04psiKhx/MGSfZA06rc2a/Lm6vtVnDHhSqLs6SXVRm8+jeVHqHd17/nvsFOhS+lEXjJCKWb1vqWHsQ1SWFr4AU3CJPZ6bgCpIjGgRsxGCgywaGmOKic3t71AaObMWaRmCpc2L97QESQ0oCPq3jnVRYYHdRdl2rQKiFuOaZoDFE3w3TzbkV0FDatn7DgRh6N4wBNF13JRlMi0kNn4MYQDNeaRnUkJd5ANbprIHB6rHPxnTM9vISCdjtYG3l8qbgwTiGz6Mae+v0PHkw05/YqfJWNUVuhybzf3NyL9SSBcjWjLVIvkuFtKFtuk9SoQ2j6Id3r/AlyZJ+dA618Hjx41SG0sDWZenIzkOs4XVj4z16jOb3j4bgWk2Na95r3x2+p4TlwF4tn0ypORprWnWLXjAyTFo/OFvfrDG3K/vnDMe322G5TN7tIgBLJX1JTBMGp4FY8kHgLXz8pw== GitJournal-android-2021-07-23 "}
{"t":1627057402715,"l":"d","msg":"githostsetup_button_click Copy Key"}
{"t":1627057402715,"l":"d","msg":"Event.GitHostSetupButtonClick","p":{"text":"Copy Key","icon_url":""}}
{"t":1627057427782,"l":"d","msg":"githostsetup_button_click GitLab"}
{"t":1627057427782,"l":"d","msg":"Event.GitHostSetupButtonClick","p":{"text":"GitLab","icon_url":"assets/icon/gitlab-icon.png"}}
{"t":1627057429130,"l":"d","msg":"githostsetup_button_click Setup Automatically"}
{"t":1627057429130,"l":"d","msg":"Event.GitHostSetupButtonClick","p":{"text":"Setup Automatically","icon_url":""}}
{"t":1627057430730,"l":"d","msg":"githostsetup_button_click Let me do it manually"}
{"t":1627057430730,"l":"d","msg":"Event.GitHostSetupButtonClick","p":{"text":"Let me do it manually","icon_url":""}}
{"t":1627057434543,"l":"d","msg":"githostsetup_button_click Next"}
{"t":1627057434543,"l":"d","msg":"Event.GitHostSetupButtonClick","p":{"text":"Next","icon_url":""}}
{"t":1627057436969,"l":"d","msg":"githostsetup_button_click Generate new keys"}
{"t":1627057436969,"l":"d","msg":"Event.GitHostSetupButtonClick","p":{"text":"Generate new keys","icon_url":""}}
{"t":1627057438618,"l":"d","msg":"githostsetup_button_click Copy Key"}
{"t":1627057438618,"l":"d","msg":"Event.GitHostSetupButtonClick","p":{"text":"Copy Key","icon_url":""}}
{"t":1627057569635,"l":"d","msg":"githostsetup_button_click Clone Repo"}
{"t":1627057569635,"l":"d","msg":"Event.GitHostSetupButtonClick","p":{"text":"Clone Repo","icon_url":""}}
{"t":1627057569636,"l":"i","msg":"RepoPath: /data/user/0/io.gitjournal.gitjournal/app_flutter/obsidian-vault"}
{"t":1627057569949,"l":"e","msg":"Failed to clone","ex":"GitException: Invalid Credentials","stack":[{"uri":"package:git_bindings/git_bindings.dart","line":38,"member":"GitRepo.fetch","isCore":false,"library":"package:git_bindings/git_bindings.dart","location":"package:git_bindings/git_bindings.dart 38","package":"git_bindings"},{"uri":"package:gitjournal/setup/clone.dart","line":28,"member":"cloneRemote","isCore":false,"library":"package:gitjournal/setup/clone.dart","location":"package:gitjournal/setup/clone.dart 28","package":"gitjournal"},{"uri":"package:gitjournal/setup/screens.dart","line":553,"member":"GitHostSetupScreenState._startGitClone","isCore":false,"library":"package:gitjournal/setup/screens.dart","location":"package:gitjournal/setup/screens.dart 553","package":"gitjournal"}]}
{"t":1627057569956,"l":"i","msg":"Not completing gitClone because of error"}
{"t":1627057569956,"l":"d","msg":"Event.GitHostSetupGitCloneError","p":{"error":"GitException: Invalid Credentials"}}
{"t":1627057579878,"l":"d","msg":"githostsetup_button_click Provide Custom SSH Keys"}
{"t":1627057579879,"l":"d","msg":"Event.GitHostSetupButtonClick","p":{"text":"Provide Custom SSH Keys","icon_url":""}}
{"t":1627057587334,"l":"d","msg":"Not syncing because RemoteRepo not configured"}
{"t":1627057589555,"l":"d","msg":"Event.DrawerSetupGitHost"}
{"t":1627057591362,"l":"d","msg":"githostsetup_button_click Custom"}
{"t":1627057591363,"l":"d","msg":"Event.GitHostSetupButtonClick","p":{"text":"Custom","icon_url":""}}
{"t":1627057617943,"l":"d","msg":"githostsetup_button_click Custom"}
{"t":1627057617943,"l":"d","msg":"Event.GitHostSetupButtonClick","p":{"text":"Custom","icon_url":""}}
{"t":1627057625913,"l":"d","msg":"githostsetup_button_click Next"}
{"t":1627057625913,"l":"d","msg":"Event.GitHostSetupButtonClick","p":{"text":"Next","icon_url":""}}
{"t":1627057630011,"l":"d","msg":"githostsetup_button_click Generate new keys"}
{"t":1627057630011,"l":"d","msg":"Event.GitHostSetupButtonClick","p":{"text":"Generate new keys","icon_url":""}}
{"t":1627057631239,"l":"i","msg":"Generating KeyPair took: 0:00:01.226766"}
{"t":1627057631240,"l":"d","msg":"Keys Dir: [/data/user/0/io.gitjournal.gitjournal/code_cache/keysLPMENL/id_rsa, /data/user/0/io.gitjournal.gitjournal/code_cache/keysLPMENL/id_rsa.pub]"}
{"t":1627057631245,"l":"d","msg":"PublicKey: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCiVKxCkSSA/E2tUMh1wRN7HVN3J0w/TQYXVS4IKE8m8k71vaZFN9u/JQ4nJlJ1Y4fOxVb9LVA7t57GlqY8/q/1ykqKs12G+wrZM8so1Rh2NABtx+zcTfSX/ugxK8ilkkmHpeY7AVLgUmj6ihXqdwX/0t1JEEl8C3CPczAw5jDBjpQDQLb+O9e+BhjHpPex3AUNtWG0vGsdmZbc08AWYNB226Nn2+WJwaJO2klMrobSlM7w59K6JqeHD1nwbKD9Bms/U32Nw4EDeaoZTa69A+qG6kGBBKCe15wNWibdQ0bcXkDJXSvvJFD+qEaREGse5eQ8uqpw+MdPRG9imZK4jDvdN8G6NMDEFT0MvmBTA9FbXB3qbKJSLXBVlzE5n7p1bT/Y3/BfgGFaoiolh+psnVc0zH8ZVflnjx8A+RqUV08ESsK3Nwpzcs8OPgy6YI+QjJwWzwi80XmsJges8f3tsgjWHoA1iQ0proQixT/99MBOGoDm7VU2E+6466j0/ijuvbugV0/fMitcbBPUX/QkM4RHo1+5jqmQtQECnzK3Dp3P0I3nMT4t8vzHi6H1qagYG2CCenkp/80h1b0iq2iVTTpy8uwhIa10KmmATLpZBgHIfcE8IZPumtuaurr6m1janjxs8e3yQKGK9Q12Y6fp/K+y1Nzm9hC0I22JGVWfHv53rw== GitJournal-android-2021-07-23 "}
{"t":1627057640171,"l":"d","msg":"githostsetup_button_click Copy Key"}
{"t":1627057640171,"l":"d","msg":"Event.GitHostSetupButtonClick","p":{"text":"Copy Key","icon_url":""}}
{"t":1627057689272,"l":"d","msg":"githostsetup_button_click Clone Repo"}
{"t":1627057689272,"l":"d","msg":"Event.GitHostSetupButtonClick","p":{"text":"Clone Repo","icon_url":""}}
{"t":1627057689273,"l":"i","msg":"RepoPath: /data/user/0/io.gitjournal.gitjournal/app_flutter/obsidian-vault"}
{"t":1627057689626,"l":"e","msg":"Failed to clone","ex":"GitException: Invalid Credentials","stack":[{"uri":"package:git_bindings/git_bindings.dart","line":38,"member":"GitRepo.fetch","isCore":false,"library":"package:git_bindings/git_bindings.dart","location":"package:git_bindings/git_bindings.dart 38","package":"git_bindings"},{"uri":"package:gitjournal/setup/clone.dart","line":28,"member":"cloneRemote","isCore":false,"library":"package:gitjournal/setup/clone.dart","location":"package:gitjournal/setup/clone.dart 28","package":"gitjournal"},{"uri":"package:gitjournal/setup/screens.dart","line":553,"member":"GitHostSetupScreenState._startGitClone","isCore":false,"library":"package:gitjournal/setup/screens.dart","location":"package:gitjournal/setup/screens.dart 553","package":"gitjournal"}]}
{"t":1627057689628,"l":"i","msg":"Not completing gitClone because of error"}
{"t":1627057689628,"l":"d","msg":"Event.GitHostSetupGitCloneError","p":{"error":"GitException: Invalid Credentials"}}
{"t":1627057702941,"l":"d","msg":"Event.NoteDeleted"}
{"t":1627057702942,"l":"d","msg":"Got removeNote lock"}
{"t":1627057704321,"l":"d","msg":"Undoing delete"}
{"t":1627057704321,"l":"d","msg":"Event.NoteUndoDeleted"}
{"t":1627057704321,"l":"d","msg":"Got undoRemoveNote lock"}
{"t":1627057704498,"l":"d","msg":"Not syncing because RemoteRepo not configured"}
{"t":1627057707155,"l":"d","msg":"Not syncing because RemoteRepo not configured"}
{"t":1627057711890,"l":"i","msg":"Switching to repo with id: 0"}
{"t":1627057711890,"l":"d","msg":"Event.Settings","p":{"gitAuthor":"true","gitAuthorEmail":"true","noteFileNameFormat":"FromTitle","journalNoteFileNameFormat":"FromTitle","yamlModifiedKey":"modified","yamlCreatedKey":"created","yamlTagsKey":"tags","customMetaData":"","yamlHeaderEnabled":"true","defaultNewNoteFolderSpec":"false","journalEditordefaultNewNoteFolderSpec":"","journalEditorSingleNote":"false","defaultEditor":"Markdown","defaultView":"Journal","sortingField":"Modified","sortingOrder":"desc","remoteSyncFrequency":"automatic","showNoteSummary":"true","folderViewHeaderType":"TitleGenerated","version":"3","markdownDefaultView":"Last Used","markdownLastUsedView":"Edit","homeScreen":"all_notes","theme":"dark","rotateImageGestures":"false","maxImageZoom":"10.0","themeRasterGraphics":"false","themeOverrideTagLocation":"alt_and_tooltip","doNotThemeTags":"notheme, !nt","doThemeTags":"dotheme, !dt","themeVectorGraphics":"on","themeSvgWithBackground":"false","matchCanvasColor":"true","vectorGraphicsAdjustColors":"all","overlayCaption":"true","transparentCaption":"true","blurBehindCaption":"true","tooltipFirst":"false","useAsCaption":"alt_and_tooltip","doNotCaptionTag":"nocaption, !nc","doCaptionTag":"docaption, !dc","imageLocationSpec":"media","zenMode":"false","titleSettings":"h1","swipeToDelete":"true","inlineTagPrefixes":"#","emojiParser":"true","folderName":"obsidian-vault","bottomMenuBar":"true","confirmDelete":"true","storeInternally":"true","storageLocation":"","sshPublicKey":"true","sshPrivateKey":"true"}}
{"t":1627057711891,"l":"i","msg":"Setting {gitAuthor: true, gitAuthorEmail: true, noteFileNameFormat: FromTitle, journalNoteFileNameFormat: FromTitle, yamlModifiedKey: modified, yamlCreatedKey: created, yamlTagsKey: tags, customMetaData: , yamlHeaderEnabled: true, defaultNewNoteFolderSpec: false, journalEditordefaultNewNoteFolderSpec: , journalEditorSingleNote: false, defaultEditor: Markdown, defaultView: Journal, sortingField: Modified, sortingOrder: desc, remoteSyncFrequency: automatic, showNoteSummary: true, folderViewHeaderType: TitleGenerated, version: 3, markdownDefaultView: Last Used, markdownLastUsedView: Edit, homeScreen: all_notes, theme: dark, rotateImageGestures: false, maxImageZoom: 10.0, themeRasterGraphics: false, themeOverrideTagLocation: alt_and_tooltip, doNotThemeTags: notheme, !nt, doThemeTags: dotheme, !dt, themeVectorGraphics: on, themeSvgWithBackground: false, matchCanvasColor: true, vectorGraphicsAdjustColors: all, overlayCaption: true, transparentCaption: true, blurBehindCaption: true, tooltipFirst: false, useAsCaption: alt_and_tooltip, doNotCaptionTag: nocaption, !nc, doCaptionTag: docaption, !dc, imageLocationSpec: media, zenMode: false, titleSettings: h1, swipeToDelete: true, inlineTagPrefixes: #, emojiParser: true, folderName: obsidian-vault, bottomMenuBar: true, confirmDelete: true, storeInternally: true, storageLocation: , sshPublicKey: true, sshPrivateKey: true}"}
{"t":1627057711891,"l":"i","msg":"Loading Repo at path /data/user/0/io.gitjournal.gitjournal/app_flutter/obsidian-vault"}
{"t":1627057711932,"l":"i","msg":"Branch master"}
{"t":1627057711933,"l":"d","msg":"Not syncing because RemoteRepo not configured"}
{"t":1627057711940,"l":"i","msg":"Notes Cache Loaded: 20 items"}
{"t":1627057711941,"l":"i","msg":"Finished loading the notes cache"}
{"t":1627057713756,"l":"i","msg":"Notes Cache saving: 20 items"}
{"t":1627057713810,"l":"i","msg":"Finished loading all the notes"}
{"t":1627057718987,"l":"d","msg":"Event.DrawerSettings"}
{"t":1627057764495,"l":"d","msg":"Event.DrawerSetupGitHost"}
{"t":1627057769082,"l":"d","msg":"githostsetup_button_click Custom"}
{"t":1627057769083,"l":"d","msg":"Event.GitHostSetupButtonClick","p":{"text":"Custom","icon_url":""}}
''';
