import 'package:gitjournal/core/note.dart';

typedef NoteSortingFunction = int Function(Note a, Note b);

class SortingMode {
  static const Modified = SortingMode("Last Modified", "Modified");
  static const Created = SortingMode("Created", "Created");
  static const Default = Modified;

  final String _str;
  final String _publicString;
  const SortingMode(this._publicString, this._str);

  String toInternalString() {
    return _str;
  }

  String toPublicString() {
    return _publicString;
  }

  static const options = <SortingMode>[
    Modified,
    Created,
  ];

  static SortingMode fromInternalString(String str) {
    for (var opt in options) {
      if (opt.toInternalString() == str) {
        return opt;
      }
    }
    return Default;
  }

  static SortingMode fromPublicString(String str) {
    for (var opt in options) {
      if (opt.toPublicString() == str) {
        return opt;
      }
    }
    return Default;
  }

  @override
  String toString() {
    assert(false, "SortingMode toString should never be called");
    return "";
  }

  NoteSortingFunction sortingFunction() {
    switch (_str) {
      case "Created":
        return (Note a, Note b) {
          // vHanda FIXME: We should use when the file was created in the FS, but that doesn't
          //               seem to be acessible via dart
          var aDt = a.created ?? a.fileLastModified;
          var bDt = b.created ?? b.fileLastModified;
          if (aDt == null && bDt != null) {
            return -1;
          }
          if (aDt != null && bDt == null) {
            return -1;
          }
          if (bDt == null || aDt == null) {
            return 0;
          }
          return bDt.compareTo(aDt);
        };

      case "Modified":
      default:
        return (Note a, Note b) {
          var aDt = a.modified ?? a.fileLastModified;
          var bDt = b.modified ?? b.fileLastModified;
          if (aDt == null && bDt != null) {
            return -1;
          }
          if (aDt != null && bDt == null) {
            return -1;
          }
          if (bDt == null || aDt == null) {
            return 0;
          }
          if (bDt == null || aDt == null) {
            return 0;
          }
          return bDt.compareTo(aDt);
        };
    }
  }
}
