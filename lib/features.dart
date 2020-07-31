import 'package:easy_localization/easy_localization.dart';

class Features {
  static bool perFolderConfig = false;

  static final all = <Feature>[
    Feature(DateTime(2019, 09, 25), tr("feature.darkMode"), "", false),
    Feature(DateTime(2019, 10, 07), tr("feature.rawEditor"), "", false),
    Feature(DateTime(2019, 12, 04), tr("feature.folderSupport"), "", false),
    Feature(DateTime(2019, 12, 20), tr("feature.fileNameCustomize"), "", false),
    Feature(
      DateTime(2019, 12, 20),
      tr("feature.noteMetaDataCustomize.title"),
      tr("feature.noteMetaDataCustomize.subtitle"),
      true,
    ),
    Feature(DateTime(2019, 12, 28), tr("feature.autoMergeConflict"), "", false),
    Feature(DateTime(2020, 02, 09), tr("feature.noteSorting"), "", false),
    Feature(DateTime(2020, 02, 09), tr("feature.noteSorting"), "", false),
    Feature(DateTime(2020, 02, 09), tr("feature.gitPushFreq"), "", false),
    Feature(DateTime(2020, 02, 15), tr("feature.checklistEditor"), "", false),
    Feature(DateTime(2020, 03, 01), tr("feature.journalEditor"), "", false),
    Feature(DateTime(2020, 04, 01), tr("feature.diffViews"), "", false),
    Feature(DateTime(2020, 05, 08), tr("feature.imageSupport"), "", false),
    Feature(DateTime(2020, 05, 14), tr("feature.tags"), "", true),
    Feature(DateTime(2020, 05, 14), tr("feature.appShortcuts"), "", false),
    Feature(DateTime(2020, 05, 18), tr("feature.createRepo"), "", false),
    Feature(DateTime(2020, 05, 27), tr("feature.backlinks"), "", true),
    Feature(DateTime(2020, 06, 03), tr("feature.txtFiles"), "", false),
    Feature(DateTime(2020, 07, 09), tr("feature.wikiLinks"), "", false),
    Feature(DateTime(2020, 07, 28), tr("feature.zenMode"), "", true),
    Feature(DateTime(2020, 07, 30), tr("feature.metaDataTitle"), "", true),
  ];
}

class Feature {
  final DateTime date;
  final String title;
  final String subtitle;
  final bool pro;

  Feature(this.date, this.title, this.subtitle, this.pro);
}
