/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import 'package:gitjournal/core/file/file.dart';
import 'package:gitjournal/core/folder/notes_folder.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/repository.dart';

class NoteFileTypesSettings extends StatefulWidget {
  static const routePath = '/settings/fileTypes';

  const NoteFileTypesSettings({Key? key}) : super(key: key);

  @override
  State<NoteFileTypesSettings> createState() => _NoteFileTypesSettingsState();
}

class _FileTypeInfo {
  final String ext;
  int count;
  bool enabled;

  _FileTypeInfo(this.ext, this.count, this.enabled);
}

class _NoteFileTypesSettingsState extends State<NoteFileTypesSettings> {
  List<_FileTypeInfo>? _info;

  @override
  void initState() {
    super.initState();
  }

  List<_FileTypeInfo> _loadInfo() {
    var root = Provider.of<NotesFolderFS>(context);
    var config = Provider.of<NotesFolderConfig>(context);

    var types = <String, int>{};
    root.visit((File f) {
      // Ignore Hidden files
      if (f.fileName.startsWith('.')) {
        return;
      }
      var ext = p.extension(f.fileName).toLowerCase();
      if (types.containsKey(ext)) {
        types[ext] = types[ext]! + 1;
      } else {
        types[ext] = 1;
      }
    });

    var finalInfo = <_FileTypeInfo>[];
    types.forEach((key, value) {
      var enabled = config.allowedFileExts.contains(key);
      finalInfo.add(_FileTypeInfo(key, value, enabled));
    });
    finalInfo.sort((a, b) => b.count.compareTo(a.count));
    return finalInfo;
  }

  @override
  Widget build(BuildContext context) {
    _info ??= _loadInfo();

    // I need some text on the top to say what this does
    var body = ListView(
      children: _info!.map(_buildTile).toList(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(LocaleKeys.settings_fileTypes_title)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: body,
    );
  }

  Widget _buildTile(_FileTypeInfo info) {
    var textTheme = Theme.of(context).textTheme;
    var title = info.ext;
    if (title.isEmpty) {
      title = LocaleKeys.settings_fileTypes_noExt.tr();
    }

    return CheckboxListTile(
      value: info.enabled,
      title: Text(
        title,
        style: textTheme.subtitle1!.copyWith(fontFamily: "Roboto Mono"),
      ),
      secondary: Text(
        LocaleKeys.settings_fileTypes_numFiles.plural(info.count),
        style: textTheme.subtitle2,
      ),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (newVal) {
        setState(() {
          info.enabled = !info.enabled;
        });

        var config = context.read<NotesFolderConfig>();
        if (!info.enabled) {
          var _ = config.allowedFileExts.remove(info.ext);
        } else {
          var _ = config.allowedFileExts.add(info.ext);
        }
        config.save();

        var repo = context.read<GitJournalRepo>();
        repo.reloadNotes();
      },
    );
  }
}

// FIXME: No matching editor found
// FIXME: Draw a kind of histogram of the number of files
