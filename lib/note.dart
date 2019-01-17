import 'package:journal/datetime_utils.dart';

typedef NoteAdder(Note note);
typedef NoteRemover(Note note);
typedef NoteUpdator(Note note);

class Note implements Comparable {
  String id;
  DateTime created;
  String body;

  Map<String, dynamic> extraProperties = new Map<String, dynamic>();

  Note({this.created, this.body, this.id, this.extraProperties}) {
    if (extraProperties == null) {
      extraProperties = new Map<String, dynamic>();
    }
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    String id;
    if (json.containsKey("id")) {
      id = json["id"].toString();
      json.remove("id");
    }

    DateTime created;
    if (json.containsKey("created")) {
      var createdStr = json['created'].toString();
      try {
        created = DateTime.parse(json['created']);
      } catch (ex) {}

      if (created == null) {
        var regex = new RegExp(
            r"(\d{4})-(\d{2})-(\d{2})T(\d{2})\:(\d{2})\:(\d{2})\+(\d{2})\:(\d{2})");
        if (regex.hasMatch(createdStr)) {
          // FIXME: Handle the timezone!
          createdStr = createdStr.substring(0, 19);
          created = DateTime.parse(json['created']);
        }
      }

      // FIXME: Get created from file system or from git!
      if (created == null) {
        // FIXME: make this 0
        created = DateTime.now();
      }

      json.remove("created");
    }

    if (id == null && created != null) {
      id = toIso8601WithTimezone(created);
    }

    String body = "";
    if (json.containsKey("body")) {
      body = json['body'];
      json.remove("body");
    }

    return new Note(
      id: id,
      created: created,
      body: body,
      extraProperties: json,
    );
  }

  Map<String, dynamic> toJson() {
    var json = Map<String, dynamic>.from(extraProperties);
    json['created'] = toIso8601WithTimezone(created);
    json['body'] = body;
    json['id'] = id;

    return json;
  }

  @override
  int get hashCode =>
      id.hashCode ^ created.hashCode ^ body.hashCode ^ extraProperties.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          body == other.body &&
          created == other.created &&
          extraProperties == other.extraProperties;

  @override
  String toString() {
    return 'Note{id: $id, body: $body, created: $created, extraProperties: $extraProperties}';
  }

  @override
  int compareTo(other) {
    if (other == null) {
      return -1;
    }
    return created.compareTo(other.created);
  }
}
