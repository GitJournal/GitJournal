import 'package:journal/datetime_utils.dart';

typedef NoteAdder(Note note);
typedef NoteRemover(Note note);
typedef NoteUpdator(Note note);

class Note implements Comparable {
  String fileName;
  DateTime created;
  String body;

  Map<String, dynamic> extraProperties = new Map<String, dynamic>();

  Note({this.created, this.body, this.fileName, this.extraProperties}) {
    if (extraProperties == null) {
      extraProperties = new Map<String, dynamic>();
    }
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    String fileName = "";
    if (json.containsKey("fileName")) {
      fileName = json["fileName"].toString();
      json.remove("fileName");
    }

    DateTime created;
    if (json.containsKey("created")) {
      var createdStr = json['created'].toString();
      try {
        created = DateTime.parse(json['created']).toLocal();
      } catch (ex) {}

      if (created == null) {
        var regex = new RegExp(
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

    return new Note(
      fileName: fileName,
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
    json['fileName'] = fileName;

    return json;
  }

  @override
  int get hashCode =>
      fileName.hashCode ^
      created.hashCode ^
      body.hashCode ^
      extraProperties.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          fileName == other.fileName &&
          body == other.body &&
          created == other.created &&
          _equalMaps(extraProperties, other.extraProperties);

  static bool _equalMaps(Map a, Map b) {
    if (a.length != b.length) return false;
    return a.keys.every((key) => b.containsKey(key) && a[key] == b[key]);
  }

  @override
  String toString() {
    return 'Note{fileName: $fileName, body: $body, created: $created, extraProperties: $extraProperties}';
  }

  @override
  int compareTo(other) {
    if (other == null) {
      return -1;
    }
    if (created == other.created) return fileName.compareTo(other.fileName);
    return created.compareTo(other.created);
  }
}
