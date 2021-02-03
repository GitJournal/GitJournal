import 'package:yaml_serializer/yaml_serializer.dart';

import 'package:gitjournal/features.dart';

// This doesn't work as this requires flutter
void main() {
  var all = <Map<String, dynamic>>[];
  for (var feature in Features.all) {
    all.add(_toMap(feature));
  }

  var yaml = toYAML({'features': all});
  print(yaml);
}

Map<String, dynamic> _toMap(Feature feature) {
  return {
    "title": feature.title,
    "date": feature.date,
    "pro": feature.pro,
  };
}
