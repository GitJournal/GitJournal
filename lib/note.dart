import 'package:journal/datetime_utils.dart';

class Note implements Comparable<Note> {
  String filePath;
  DateTime created;
  String body;

  Map<String, dynamic> extraProperties = Map<String, dynamic>();

  Note({this.created, this.body, this.filePath, this.extraProperties}) {
    if (created == null) {
      created = DateTime(0, 0, 0, 0, 0, 0, 0, 0);
    }
    if (extraProperties == null) {
      extraProperties = Map<String, dynamic>();
    }
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    String filePath = "";
    if (json.containsKey("filePath")) {
      filePath = json["filePath"].toString();
      json.remove("filePath");
    }

    DateTime created;
    if (json.containsKey("created")) {
      var createdStr = json['created'].toString();
      try {
        created = DateTime.parse(json['created']).toLocal();
      } catch (ex) {
        // Ignore it
      }

      if (created == null) {
        var regex = RegExp(
            r"(\d{4})-(\d{2})-(\d{2})T(\d{2})\:(\d{2})\:(\d{2})\+(\d{2})\:(\d{2})");
        if (regex.hasMatch(createdStr)) {
          // FIXME: Handle the timezone!
          createdStr = createdStr.substring(0, 19);
          created = DateTime.parse(createdStr);
        }
      }

      json.remove("created");
    }

    if (created == null) {
      created = DateTime(0, 0, 0, 0, 0, 0, 0, 0);
    }

    String body = "";
    if (json.containsKey("body")) {
      body = json['body'];
      json.remove("body");
    }

    return Note(
      filePath: filePath,
      created: created,
      body: body,
      extraProperties: json,
    );
  }

  Map<String, dynamic> toJson() {
    var json = Map<String, dynamic>.from(extraProperties);
    var createdStr = toIso8601WithTimezone(created);
    if (!createdStr.startsWith("00")) {
      json['created'] = createdStr;
    }
    json['body'] = body;
    json['filePath'] = filePath;

    return json;
  }

  @override
  int get hashCode =>
      filePath.hashCode ^
      created.hashCode ^
      body.hashCode ^
      extraProperties.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          filePath == other.filePath &&
          body == other.body &&
          created == other.created &&
          _equalMaps(extraProperties, other.extraProperties);

  static bool _equalMaps(Map a, Map b) {
    if (a.length != b.length) return false;
    return a.keys
        .every((dynamic key) => b.containsKey(key) && a[key] == b[key]);
  }

  @override
  String toString() {
    return 'Note{filePath: $filePath, body: $body, created: $created, extraProperties: $extraProperties}';
  }

  @override
  int compareTo(Note other) {
    if (other == null) {
      return -1;
    }
    if (created == other.created) return filePath.compareTo(other.filePath);
    return created.compareTo(other.created);
  }
}
