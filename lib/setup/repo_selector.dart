/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:function_types/function_types.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:time/time.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:gitjournal/analytics/analytics.dart';
import 'package:gitjournal/apis/githost_factory.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/setup/button.dart';
import 'package:gitjournal/setup/error.dart';
import 'package:gitjournal/setup/loading.dart';
import 'package:gitjournal/widgets/highlighted_text.dart';

//import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GitHostSetupRepoSelector extends StatefulWidget {
  final GitHost gitHost;
  final UserInfo userInfo;
  final Func1<GitHostRepo, void> onDone;

  const GitHostSetupRepoSelector({
    Key? key,
    required this.gitHost,
    required this.userInfo,
    required this.onDone,
  }) : super(key: key);

  @override
  GitHostSetupRepoSelectorState createState() {
    return GitHostSetupRepoSelectorState();
  }
}

class GitHostSetupRepoSelectorState extends State<GitHostSetupRepoSelector> {
  String errorMessage = "";

  List<GitHostRepo> repos = [];
  var fetchedRepos = false;
  bool createRepo = false;

  GitHostRepo? selectedRepo;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController();
    _textController.addListener(() {
      var q = _textController.text.toLowerCase();
      if (q.isEmpty) {
        setState(() {
          selectedRepo = null;
          createRepo = false;
        });
        return;
      }
      var repoIndex = repos.indexWhere((r) =>
          r.name.toLowerCase() == q && r.username == widget.userInfo.username);
      if (repoIndex == -1) {
        setState(() {
          selectedRepo = null;
          createRepo = false;
        });
      } else {
        setState(() {
          selectedRepo = repos[repoIndex];
          createRepo = false;
        });
      }
    });
    _initStateAysnc();
  }

  Future<void> _initStateAysnc() async {
    Log.d("Starting RepoSelector");

    try {
      var allRepos = await widget.gitHost.listRepos().getOrThrow();
      allRepos.sort((GitHostRepo a, GitHostRepo b) {
        if (a.updatedAt != null && b.updatedAt != null) {
          return a.updatedAt!.compareTo(b.updatedAt!);
        }
        if (a.updatedAt == null && b.updatedAt == null) {
          return a.fullName.compareTo(b.fullName);
        }
        if (a.updatedAt == null) {
          return 1;
        }
        return -1;
      });

      if (!mounted) return;
      setState(() {
        repos = allRepos.reversed.toList();
        fetchedRepos = true;
      });
    } on Exception catch (e, stacktrace) {
      _handleGitHostException(e, stacktrace);
      return;
    }
  }

  void _handleGitHostException(Exception e, StackTrace stacktrace) {
    Log.d("GitHostSetupAutoConfigure: " + e.toString());

    if (mounted) {
      setState(() {
        errorMessage = e.toString();
      });
    } else {
      Log.e("Ignore error as not mounted", ex: e, stacktrace: stacktrace);
    }

    logEvent(Event.GitHostSetupError, parameters: {
      'errorMessage': errorMessage,
    });
    logException(e, stacktrace);
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage.isNotEmpty) {
      return GitHostSetupErrorPage(errorMessage);
    }
    if (!fetchedRepos) {
      return GitHostSetupLoadingPage(tr(LocaleKeys.setup_repoSelector_loading));
    }

    var q = _textController.text.toLowerCase();
    var filteredRepos = filterList(repos, q);

    var repoExists = filteredRepos.indexWhere((r) =>
            r.name.toLowerCase() == q &&
            r.username == widget.userInfo.username) !=
        -1;

    var createRepoTile = _textController.text.isNotEmpty && !repoExists;

    Widget repoBuilder = ListView(
      children: <Widget>[
        if (createRepoTile) _buildCreateRepoTile(),
        for (var repo in filteredRepos)
          _RepoTile(
            repo: repo,
            searchText: q,
            onTap: () {
              setState(() {
                selectedRepo = repo;
                createRepo = false;
              });
            },
            selected: repo == selectedRepo,
          ),
      ],
      padding: const EdgeInsets.all(0.0),
    );

    // Remove Overflow animation
    repoBuilder = NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (OverscrollIndicatorNotification overScroll) {
        overScroll.disallowGlow();
        return false;
      },
      child: repoBuilder,
    );

    // Add a Filtering bar
    // text: Type to search or create
    var textField = TextField(
      controller: _textController,
      maxLines: 1,
      decoration: InputDecoration(
        hintText: tr(LocaleKeys.setup_repoSelector_hint),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          onPressed: () => _textController.clear(),
          icon: const Icon(Icons.clear),
        ),
      ),
    );

    bool canContinue = selectedRepo != null || createRepo;
    var columns = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          tr(LocaleKeys.setup_repoSelector_title),
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 16.0),
        textField,
        const SizedBox(height: 8.0),
        Expanded(child: repoBuilder),
        const SizedBox(height: 8.0),
        GitHostSetupButton(
          text: tr(LocaleKeys.setup_next),
          enabled: canContinue,
          onPressed: () async {
            if (selectedRepo != null) {
              widget.onDone(selectedRepo!);
              return;
            }

            try {
              var repoName = _textController.text.trim();
              var repo = await widget.gitHost.createRepo(repoName).getOrThrow();
              widget.onDone(repo);
              return;
            } catch (e, stacktrace) {
              _handleGitHostException(e as Exception, stacktrace);
            }
          },
        ),
        const SizedBox(height: 32.0),
      ],
    );

    return Center(child: columns);
  }

  Widget _buildCreateRepoTile() {
    var repoName = _textController.text.trim();
    var fullRepoName = p.join(widget.userInfo.username, repoName);

    return ListTile(
      leading: const Icon(Icons.add),
      title: Align(
        child: Text(
          tr(LocaleKeys.setup_repoSelector_create, args: [fullRepoName]),
        ),
        alignment: const Alignment(-1.3, 0),
      ),
      contentPadding: const EdgeInsets.all(0.0),
      onTap: () {
        setState(() {
          createRepo = true;
          selectedRepo = null;
        });
      },
      selected: createRepo,
    );
  }
}

/// If we have "blahFlutter" and "Flutter" searching for "flu" should put
/// "Flutter" higher up in the list.
List<GitHostRepo> filterList(List<GitHostRepo> repos, String q) {
  if (q.isEmpty) return repos;

  var l = repos.where((r) => r.name.toLowerCase().contains(q)).toList();
  l.sort((r1, r2) {
    var r1StartsWith = r1.name.startsWith(q);
    var r2StartsWith = r2.name.startsWith(q);

    if (r1StartsWith == r2StartsWith) {
      return r1.name.compareTo(r2.name);
    } else if (r1StartsWith) {
      return -1;
    } else {
      return 1;
    }
  });

  return l;
}

class _RepoTile extends StatelessWidget {
  final GitHostRepo repo;
  final String searchText;
  final void Function() onTap;
  final bool selected;

  const _RepoTile({
    required this.repo,
    required this.searchText,
    required this.onTap,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;

    /*
    var iconsRow = Row(
      children: [
        if (repo.license != null)
          _IconText(repo.license, FontAwesomeIcons.balanceScale),
        if (repo.license != null) const SizedBox(width: 8.0),
        _IconText(repo.forks.toString(), FontAwesomeIcons.codeBranch),
        const SizedBox(width: 8.0),
        _IconText(repo.stars.toString(), FontAwesomeIcons.star),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );

    return Card(
      margin: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
      elevation: 0.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              repo.fullName,
              style:
                  textTheme.headline6.copyWith(color: theme.primaryColorDark),
            ),
            if (repo.description != null) const SizedBox(height: 8.0),
            if (repo.description != null) Text(repo.description),
            const SizedBox(height: 16.0),
            iconsRow,
          ],
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ),
    ); */

    var style = Theme.of(context).textTheme.subtitle1;

    Widget title = Text(repo.fullName, style: style);
    if (searchText.isNotEmpty) {
      title = title = RichText(
        text: TextSpan(
          children: [
            TextSpan(text: repo.username + '/', style: style),
            ...HighlightTextSpan(
              text: repo.name,
              highlightText: searchText,
              highlightTextLowerCase: searchText,
              style: style!,
              highlightStyle: style.copyWith(fontWeight: FontWeight.bold),
            ).build(context),
          ],
        ),
      );
    }

    var tile = ListTile(
      title: title,
      trailing: _SmartDateTime(repo.updatedAt, textTheme.caption),
      selected: selected,
      contentPadding: const EdgeInsets.all(0.0),
      onTap: onTap,
    );

    return Ink(
      color: selected ? Theme.of(context).highlightColor : Colors.transparent,
      child: tile,
    );
  }
}

/*
class _IconText extends StatelessWidget {
  final String text;
  final IconData iconData;

  _IconText(this.text, this.iconData);

  @override
  Widget build(BuildContext context) {
    var iconTheme = Theme.of(context).iconTheme;
    var iconColor = iconTheme.color.withAlpha(150);
    var textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        FaIcon(iconData, size: 16, color: iconColor),
        const SizedBox(width: 4.0),
        Text(text, style: textTheme.caption),
      ],
      textBaseline: TextBaseline.alphabetic,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      mainAxisSize: MainAxisSize.min,
    );
  }
}
*/

class _SmartDateTime extends StatelessWidget {
  final DateTime? dt;
  final TextStyle? style;

  const _SmartDateTime(this.dt, this.style);

  static final _dateFormat = DateFormat('d MMM yyyy');
  static final _dateFormatWithoutYear = DateFormat('d MMM');
  static final thirtyDaysAgo = DateTime.now().subtract(30.days);

  @override
  Widget build(BuildContext context) {
    if (this.dt == null) {
      return Container();
    }

    String text;

    var dt = this.dt!;
    if (dt.isAfter(thirtyDaysAgo)) {
      Locale locale = Localizations.localeOf(context);
      text = timeago.format(dt, locale: locale.languageCode);
    } else if (dt.year == DateTime.now().year) {
      text = _dateFormatWithoutYear.format(dt);
    } else {
      text = _dateFormat.format(dt);
    }

    return Text(text, style: style);
  }
}

/*
const _langColors = {
  "Mercury": "#ff2b2b",
  "TypeScript": "#2b7489",
  "PureBasic": "#5a6986",
  "Objective-C++": "#6866fb",
  "Self": "#0579aa",
  "NewLisp": "#87AED7",
  "Fortran": "#4d41b1",
  "Ceylon": "#dfa535",
  "Rebol": "#358a5b",
  "Frege": "#00cafe",
  "AspectJ": "#a957b0",
  "Omgrofl": "#cabbff",
  "HolyC": "#ffefaf",
  "Shell": "#89e051",
  "HiveQL": "#dce200",
  "AppleScript": "#101F1F",
  "Eiffel": "#946d57",
  "XQuery": "#5232e7",
  "RUNOFF": "#665a4e",
  "RAML": "#77d9fb",
  "MTML": "#b7e1f4",
  "Elixir": "#6e4a7e",
  "SAS": "#B34936",
  "MQL4": "#62A8D6",
  "MQL5": "#4A76B8",
  "Agda": "#315665",
  "wisp": "#7582D1",
  "Dockerfile": "#384d54",
  "SRecode Template": "#348a34",
  "D": "#ba595e",
  "PowerBuilder": "#8f0f8d",
  "Kotlin": "#F18E33",
  "Opal": "#f7ede0",
  "TI Program": "#A0AA87",
  "Crystal": "#000100",
  "Objective-C": "#438eff",
  "Batchfile": "#C1F12E",
  "Oz": "#fab738",
  "Mirah": "#c7a938",
  "ZIL": "#dc75e5",
  "Objective-J": "#ff0c5a",
  "ANTLR": "#9DC3FF",
  "Roff": "#ecdebe",
  "Ragel": "#9d5200",
  "FreeMarker": "#0050b2",
  "Gosu": "#82937f",
  "Zig": "#ec915c",
  "Ruby": "#701516",
  "Nemerle": "#3d3c6e",
  "Jupyter Notebook": "#DA5B0B",
  "Component Pascal": "#B0CE4E",
  "Nextflow": "#3ac486",
  "Brainfuck": "#2F2530",
  "SystemVerilog": "#DAE1C2",
  "APL": "#5A8164",
  "Hack": "#878787",
  "Go": "#00ADD8",
  "Ring": "#2D54CB",
  "PHP": "#4F5D95",
  "Cirru": "#ccccff",
  "SQF": "#3F3F3F",
  "ZAP": "#0d665e",
  "Glyph": "#c1ac7f",
  "1C Enterprise": "#814CCC",
  "WebAssembly": "#04133b",
  "Java": "#b07219",
  "MAXScript": "#00a6a6",
  "Scala": "#c22d40",
  "Makefile": "#427819",
  "Perl": "#0298c3",
  "Jsonnet": "#0064bd",
  "Arc": "#aa2afe",
  "LLVM": "#185619",
  "GDScript": "#355570",
  "Verilog": "#b2b7f8",
  "Factor": "#636746",
  "Haxe": "#df7900",
  "Forth": "#341708",
  "Red": "#f50000",
  "YARA": "#220000",
  "Hy": "#7790B2",
  "mcfunction": "#E22837",
  "Volt": "#1F1F1F",
  "AngelScript": "#C7D7DC",
  "LSL": "#3d9970",
  "eC": "#913960",
  "Terra": "#00004c",
  "CoffeeScript": "#244776",
  "HTML": "#e34c26",
  "Lex": "#DBCA00",
  "UnrealScript": "#a54c4d",
  "Idris": "#b30000",
  "Swift": "#ffac45",
  "Modula-3": "#223388",
  "C": "#555555",
  "AutoHotkey": "#6594b9",
  "P4": "#7055b5",
  "Isabelle": "#FEFE00",
  "G-code": "#D08CF2",
  "Metal": "#8f14e9",
  "Clarion": "#db901e",
  "Vue": "#2c3e50",
  "JSONiq": "#40d47e",
  "Boo": "#d4bec1",
  "AutoIt": "#1C3552",
  "Genie": "#fb855d",
  "Clojure": "#db5855",
  "EQ": "#a78649",
  "Visual Basic": "#945db7",
  "CSS": "#563d7c",
  "Prolog": "#74283c",
  "SourcePawn": "#5c7611",
  "AMPL": "#E6EFBB",
  "Shen": "#120F14",
  "wdl": "#42f1f4",
  "Harbour": "#0e60e3",
  "Yacc": "#4B6C4B",
  "Tcl": "#e4cc98",
  "Quake": "#882233",
  "BlitzMax": "#cd6400",
  "PigLatin": "#fcd7de",
  "xBase": "#403a40",
  "Lasso": "#999999",
  "Processing": "#0096D8",
  "VHDL": "#adb2cb",
  "Elm": "#60B5CC",
  "Dhall": "#dfafff",
  "Propeller Spin": "#7fa2a7",
  "Rascal": "#fffaa0",
  "Alloy": "#64C800",
  "IDL": "#a3522f",
  "Slice": "#003fa2",
  "YASnippet": "#32AB90",
  "ATS": "#1ac620",
  "Ada": "#02f88c",
  "Nu": "#c9df40",
  "LFE": "#4C3023",
  "SuperCollider": "#46390b",
  "Oxygene": "#cdd0e3",
  "ASP": "#6a40fd",
  "Assembly": "#6E4C13",
  "Gnuplot": "#f0a9f0",
  "FLUX": "#88ccff",
  "C#": "#178600",
  "Turing": "#cf142b",
  "Vala": "#fbe5cd",
  "ECL": "#8a1267",
  "ObjectScript": "#424893",
  "NetLinx": "#0aa0ff",
  "Perl 6": "#0000fb",
  "MATLAB": "#e16737",
  "Emacs Lisp": "#c065db",
  "Stan": "#b2011d",
  "SaltStack": "#646464",
  "Gherkin": "#5B2063",
  "QML": "#44a51c",
  "Pike": "#005390",
  "DataWeave": "#003a52",
  "LOLCODE": "#cc9900",
  "ooc": "#b0b77e",
  "XSLT": "#EB8CEB",
  "XC": "#99DA07",
  "J": "#9EEDFF",
  "Mask": "#f97732",
  "EmberScript": "#FFF4F3",
  "TeX": "#3D6117",
  "Pep8": "#C76F5B",
  "R": "#198CE7",
  "Cuda": "#3A4E3A",
  "KRL": "#28430A",
  "Vim script": "#199f4b",
  "Lua": "#000080",
  "Asymptote": "#4a0c0c",
  "Ren'Py": "#ff7f7f",
  "Golo": "#88562A",
  "PostScript": "#da291c",
  "Fancy": "#7b9db4",
  "OCaml": "#3be133",
  "ColdFusion": "#ed2cd6",
  "Pascal": "#E3F171",
  "F#": "#b845fc",
  "API Blueprint": "#2ACCA8",
  "ActionScript": "#882B0F",
  "F*": "#572e30",
  "Fantom": "#14253c",
  "Zephir": "#118f9e",
  "Click": "#E4E6F3",
  "Smalltalk": "#596706",
  "Ballerina": "#FF5000",
  "DM": "#447265",
  "Ioke": "#078193",
  "PogoScript": "#d80074",
  "LiveScript": "#499886",
  "JavaScript": "#f1e05a",
  "Wollok": "#a23738",
  "Rust": "#dea584",
  "ABAP": "#E8274B",
  "ZenScript": "#00BCD1",
  "Slash": "#007eff",
  "Erlang": "#B83998",
  "Pan": "#cc0000",
  "LookML": "#652B81",
  "Scheme": "#1e4aec",
  "Squirrel": "#800000",
  "Nim": "#37775b",
  "Python": "#3572A5",
  "Max": "#c4a79c",
  "Solidity": "#AA6746",
  "Common Lisp": "#3fb68b",
  "Dart": "#00B4AB",
  "Nix": "#7e7eff",
  "Nearley": "#990000",
  "Nit": "#009917",
  "Chapel": "#8dc63f",
  "Groovy": "#e69f56",
  "Dylan": "#6c616e",
  "E": "#ccce35",
  "Parrot": "#f3ca0a",
  "Grammatical Framework": "#79aa7a",
  "Game Maker Language": "#71b417",
  "VCL": "#148AA8",
  "Papyrus": "#6600cc",
  "C++": "#f34b7d",
  "NetLinx+ERB": "#747faa",
  "Common Workflow Language": "#B5314C",
  "Clean": "#3F85AF",
  "X10": "#4B6BEF",
  "Puppet": "#302B6D",
  "Jolie": "#843179",
  "PLSQL": "#dad8d8",
  "sed": "#64b970",
  "Pawn": "#dbb284",
  "Standard ML": "#dc566d",
  "PureScript": "#1D222D",
  "Julia": "#a270ba",
  "nesC": "#94B0C7",
  "q": "#0040cd",
  "Haskell": "#5e5086",
  "NCL": "#28431f",
  "Io": "#a9188d",
  "Rouge": "#cc0088",
  "Racket": "#3c5caa",
  "NetLogo": "#ff6375",
  "AGS Script": "#B9D9FF",
  "Meson": "#007800",
  "Dogescript": "#cca760",
  "PowerShell": "#012456"
};
*/
