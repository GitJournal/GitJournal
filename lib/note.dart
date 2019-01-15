import 'package:journal/datetime_utils.dart';

typedef NoteAdder(Note note);
typedef NoteRemover(Note note);
typedef NoteUpdator(Note note);

class Note implements Comparable {
  String id;
  DateTime created;
  String body;

  Note({this.created, this.body, this.id});

  factory Note.fromJson(Map<String, dynamic> json) {
    String id;
    if (json.containsKey("id")) {
      id = json["id"].toString();
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
        created = DateTime.now();
      }
    }

    if (id == null && created != null) {
      id = toIso8601WithTimezone(created);
    }

    String body = "";
    if (json.containsKey("body")) {
      body = json['body'];
    }

    return new Note(
      id: id,
      created: created,
      body: body,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "created": toIso8601WithTimezone(created),
      "body": body,
      "id": id,
    };
  }

  @override
  int get hashCode => id.hashCode ^ created.hashCode ^ body.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          body == other.body &&
          created == other.created;

  @override
  String toString() {
    return 'Note{id: $id, body: $body, created: $created}';
  }

  @override
  int compareTo(other) {
    if (other == null) {
      return -1;
    }
    return created.compareTo(other.created);
  }
}
