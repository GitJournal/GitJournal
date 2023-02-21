/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/widgets.dart';
import 'package:gitjournal/core/file/file.dart';
import 'package:gitjournal/l10n.dart';

typedef SortingFunction = int Function(File a, File b);

class GjSetting {
  final String _str;
  final Lk _lk;

  const GjSetting(this._lk, this._str);

  String toPublicString(BuildContext context) => context.tr(_lk);
  String toInternalString() => _str;

  @override
  String toString() {
    assert(false, "SortingOrder toString should never be called");
    return "";
  }

  static GjSetting fromInternalString(
    List<GjSetting> options,
    GjSetting def,
    String? str,
  ) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return def;
  }

  static GjSetting fromPublicString(
    BuildContext context,
    List<GjSetting> options,
    GjSetting def,
    String str,
  ) {
    for (var opt in options) {
      if (opt.toPublicString(context) == str) {
        return opt;
      }
    }
    return def;
  }
}

class SortingOrder extends GjSetting {
  static const Ascending = SortingOrder(Lk.settingsSortingOrderAsc, "asc");
  static const Descending = SortingOrder(Lk.settingsSortingOrderDesc, "desc");
  static const Default = Descending;

  const SortingOrder(super.lk, super.str);

  static const options = <SortingOrder>[
    Ascending,
    Descending,
  ];

  static SortingOrder fromInternalString(String? str) =>
      GjSetting.fromInternalString(options, Default, str) as SortingOrder;

  static SortingOrder fromPublicString(BuildContext context, String str) =>
      GjSetting.fromPublicString(context, options, Default, str)
          as SortingOrder;
}

class SortingField extends GjSetting {
  static const Modified = SortingField(
    Lk.settingsSortingFieldModified,
    "Modified",
  );
  static const Created = SortingField(
    Lk.settingsSortingFieldCreated,
    "Created",
  );
  static const FileName = SortingField(
    Lk.settingsSortingFieldFilename,
    "FileName",
  );
  static const Default = Modified;

  const SortingField(super.lk, super.str);

  static const options = <SortingField>[
    Modified,
    Created,
    FileName,
  ];

  static SortingField fromInternalString(String? str) =>
      GjSetting.fromInternalString(options, Default, str) as SortingField;

  static SortingField fromPublicString(BuildContext context, String str) =>
      GjSetting.fromPublicString(context, options, Default, str)
          as SortingField;
}

class SortingMode {
  final SortingField field;
  final SortingOrder order;

  SortingMode(this.field, this.order);

  SortingFunction sortingFunction() {
    switch (field) {
      case SortingField.Created:
        return order == SortingOrder.Descending
            ? _sortCreatedDesc
            : _reverse(_sortCreatedDesc);

      case SortingField.FileName:
        return order == SortingOrder.Descending
            ? _reverse(_sortFileNameAsc)
            : _sortFileNameAsc;

      case SortingField.Modified:
      default:
        return order == SortingOrder.Descending
            ? _sortModifiedDesc
            : _reverse(_sortModifiedDesc);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortingMode && other.field == field && other.order == order;

  @override
  int get hashCode => order.hashCode ^ field.hashCode;
}

int _sortCreatedDesc(File a, File b) {
  if (b.created == a.created) {
    return a.filePath.compareTo(b.filePath);
  }
  return b.created.compareTo(a.created);
}

int _sortModifiedDesc(File a, File b) {
  if (b.modified == a.modified) {
    return a.filePath.compareTo(b.filePath);
  }
  return b.modified.compareTo(a.modified);
}

int _sortFileNameAsc(File a, File b) {
  var aFileName = a.fileName.toLowerCase();
  var bFileName = b.fileName.toLowerCase();
  return aFileName.compareTo(bFileName);
}

SortingFunction _reverse(SortingFunction func) {
  return (File a, File b) {
    int r = func(a, b);

    if (r == 0) return r;
    return r < 0 ? 1 : -1;
  };
}
