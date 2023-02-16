/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gitjournal/l10n.dart';
import 'package:gitjournal/utils/utils.dart';

class VersionNumberTile extends StatefulWidget {
  const VersionNumberTile({super.key});

  @override
  VersionNumberTileState createState() {
    return VersionNumberTileState();
  }
}

class VersionNumberTileState extends State<VersionNumberTile> {
  String versionText = "";

  @override
  void initState() {
    super.initState();

    () async {
      var str = await getVersionString(includeAppName: false);
      if (!mounted) return;
      setState(() {
        versionText = str;
      });
    }();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return ListTile(
      leading: FaIcon(
        FontAwesomeIcons.stamp,
        color: textTheme.titleMedium!.color,
      ),
      title: Text(context.loc.settingsVersionInfo, style: textTheme.titleMedium),
      subtitle: Text(versionText),
      onTap: () {
        Clipboard.setData(ClipboardData(text: versionText));
        showSnackbar(context, context.loc.settingsVersionCopied);
      },
    );
  }
}
