import 'package:gitjournal/core/note.dart';

typedef NoteSortingFunction = int Function(Note a, Note b);

class SortingMode {
  static const Modified = SortingMode("Last Modified", "Modified");
  static const Created = SortingMode("Created", "Created");
  static const FileName = SortingMode("File Name", "FileName");
  static const Title = SortingMode("Title", "Title");
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
    FileName,
    Title,
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

  // vHanda FIXME: The modified and created should come from Git if not present in the document
  NoteSortingFunction sortingFunction() {
    switch (_str) {
      case "Created":
        return (Note a, Note b) {
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
          return bDt.compareTo(aDt);
        };

      case "Title":
        return (Note a, Note b) {
          var aTitleExists = a.title != null && a.title.isNotEmpty;
          var bTitleExists = b.title != null && b.title.isNotEmpty;

          if (!aTitleExists && bTitleExists) {
            return 1;
          }
          if (aTitleExists && !bTitleExists) {
            return -1;
          }
          if (!aTitleExists && !bTitleExists) {
            return a.fileName.compareTo(b.fileName);
          }
          return a.title.compareTo(b.title);
        };

      case "FileName":
        return (Note a, Note b) {
          return a.fileName.compareTo(b.fileName);
        };

      case "Modified":
      default:
        return (Note a, Note b) {
          var aDt = a.modified;
          var bDt = b.modified;
          if (aDt == null && bDt != null) {
            return 1;
          }
          if (aDt != null && bDt == null) {
            return -1;
          }
          if (bDt == null && aDt == null) {
            return a.fileName.compareTo(b.fileName);
          }
          return bDt.compareTo(aDt);
        };
    }
  }
}
