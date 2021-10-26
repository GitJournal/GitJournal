/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:easy_localization/easy_localization.dart';

import 'package:gitjournal/core/file/file.dart';

typedef SortingFunction = int Function(File a, File b);

class SortingOrder {
  static const Ascending = SortingOrder("settings.sortingOrder.asc", "asc");
  static const Descending = SortingOrder("settings.sortingOrder.desc", "desc");
  static const Default = Descending;

  final String _str;
  final String _publicString;
  const SortingOrder(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicString);
  }

  static const options = <SortingOrder>[
    Ascending,
    Descending,
  ];

  static SortingOrder fromInternalString(String? str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static SortingOrder fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }

  @override
  String toString() {
    assert(false, "SortingOrder toString should never be called");
    return "";
  }
}

class SortingField {
  static const Modified = SortingField(
    "settings.sortingField.modified",
    "Modified",
  );
  static const Created = SortingField(
    "settings.sortingField.created",
    "Created",
  );
  static const FileName = SortingField(
    "settings.sortingField.filename",
    "FileName",
  );

  static const Default = Modified;

  final String _str;
  final String _publicString;
  const SortingField(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return tr(_publicString);
  }

  static const options = <SortingField>[
    Modified,
    Created,
    FileName,
  ];

  static SortingField fromInternalString(String? str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  @override
  String toString() {
    assert(false, "SortingField toString should never be called");
    return "";
  }
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

int _sortCreatedDesc(File a, File b) => b.created.compareTo(a.created);
int _sortModifiedDesc(File a, File b) => b.modified.compareTo(a.modified);

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
