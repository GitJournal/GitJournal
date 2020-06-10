import 'dart:collection';

import 'package:gitjournal/core/md_yaml_doc.dart';
import 'package:test/test.dart';

void main() {
  test('Equality', () {
    // ignore: prefer_collection_literals
    var aProps = LinkedHashMap<String, dynamic>();
    aProps['a'] = 1;
    aProps['title'] = "Foo";
    aProps['list'] = ["Foo", "Bar", 1];

    // ignore: prefer_collection_literals
    var bProps = LinkedHashMap<String, dynamic>();
    bProps['a'] = 1;
    bProps['title'] = "Foo";
    bProps['list'] = ["Foo", "Bar", 1];

    var a = MdYamlDoc("a", aProps);
    var b = MdYamlDoc("a", bProps);
    expect(a, b);
  });
}
