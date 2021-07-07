import 'package:easy_localization/easy_localization.dart';

import 'package:gitjournal/core/note.dart';

typedef NoteSortingFunction = int Function(Note a, Note b);

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
  static const Title = SortingField(
    "settings.sortingField.title",
    "Title",
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
    Title,
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

  NoteSortingFunction sortingFunction() {
    switch (field) {
      case SortingField.Created:
        return order == SortingOrder.Descending
            ? _sortCreatedDesc
            : _reverse(_sortCreatedDesc);

      case SortingField.Title:
        return order == SortingOrder.Descending
            ? _reverse(_sortTitleAsc)
            : _sortTitleAsc;

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

int _sortCreatedDesc(Note a, Note b) {
  var aDt = a.created;
  var bDt = b.created;
  if (aDt == null && bDt != null) {
    return 1;
  }
  if (aDt != null && bDt == null) {
    return -1;
  }
  if (bDt == null && aDt == null) {
    return a.fileName.compareTo(b.fileName);
  }
  return bDt!.compareTo(aDt!);
}

int _sortModifiedDesc(Note a, Note b) {
  var aDt = a.modified;
  var bDt = b.modified;
  if (aDt == null && bDt != null) {
    return 1;
  }
  if (aDt != null && bDt == null) {
    return -1;
  }
  if (bDt == null && aDt == null) {
    if (a.fileLastModified != null && b.fileLastModified != null) {
      return a.fileLastModified!.compareTo(b.fileLastModified!);
    } else {
      return a.fileName.compareTo(b.fileName);
    }
  }
  return bDt!.compareTo(aDt!);
}

int _sortTitleAsc(Note a, Note b) {
  var aTitleExists = a.title.isNotEmpty;
  var bTitleExists = b.title.isNotEmpty;

  if (!aTitleExists && bTitleExists) {
    return 1;
  }
  if (aTitleExists && !bTitleExists) {
    return -1;
  }
  if (!aTitleExists && !bTitleExists) {
    return _sortFileNameAsc(a, b);
  }
  var aTitle = a.title.toLowerCase();
  var bTitle = b.title.toLowerCase();
  return aTitle.compareTo(bTitle);
}

int _sortFileNameAsc(Note a, Note b) {
  var aFileName = a.fileName.toLowerCase();
  var bFileName = b.fileName.toLowerCase();
  return aFileName.compareTo(bFileName);
}

NoteSortingFunction _reverse(NoteSortingFunction func) {
  return (Note a, Note b) {
    int r = func(a, b);
    if (r == 0) {
      return r;
    }
    if (r < 0) {
      return 1;
    } else {
      return -1;
    }
  };
}
