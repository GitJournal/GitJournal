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
}
