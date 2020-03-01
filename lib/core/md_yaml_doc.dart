import 'dart:collection';

class MdYamlDoc {
  String body = "";
  LinkedHashMap<String, dynamic> props = LinkedHashMap<String, dynamic>();

  MdYamlDoc([this.body, this.props]) {
    body = body ?? "";
    // ignore: prefer_collection_literals
    props = props ?? LinkedHashMap<String, dynamic>();
  }

  MdYamlDoc.from(MdYamlDoc other) {
    body = String.fromCharCodes(other.body.codeUnits);
    props = LinkedHashMap<String, dynamic>.from(other.props);
  }

  @override
  int get hashCode => body.hashCode ^ props.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MdYamlDoc &&
          runtimeType == other.runtimeType &&
          body == other.body &&
          _equalMaps(props, other.props);

  static bool _equalMaps(Map a, Map b) {
    if (a.length != b.length) return false;
    return a.keys
        .every((dynamic key) => b.containsKey(key) && a[key] == b[key]);
  }

  @override
  String toString() {
    return 'MdYamlDoc{body: "$body", props: $props}';
  }
}
