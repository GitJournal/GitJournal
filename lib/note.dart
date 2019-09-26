import 'dart:io';

import 'package:journal/storage/serializers.dart';
import 'package:journal/datetime_utils.dart';

enum NoteLoadState {
  None,
  Loading,
  Loaded,
  NotExists,
}

class Note implements Comparable<Note> {
  String filePath = "";
  DateTime created;
  String body = "";

  var _loadState = NoteLoadState.None;
  var _serializer = MarkdownYAMLSerializer();

  // FIXME: Make it an ordered Map
  Map<String, dynamic> props = {};

  Note({this.created, this.body, this.filePath, this.props}) {
    created = created ?? DateTime(0, 0, 0, 0, 0, 0, 0, 0);
    props = props ?? <String, dynamic>{};
    body = body ?? "";
  }

  bool hasValidDate() {
    // Arbitrary number, when we set the year = 0, it becomes 1, somehow
    return created.year > 10;
  }

  Future<NoteLoadState> load() async {
    if (_loadState == NoteLoadState.Loading) {
      return _loadState;
    }

    final file = File(filePath);
    if (!file.existsSync()) {
      _loadState = NoteLoadState.NotExists;
      return _loadState;
    }

    final string = await file.readAsString();
    var noteData = _serializer.decode(string);

    body = noteData.body;
    props = noteData.props;

    if (props.containsKey("created")) {
      var createdStr = props['created'].toString();
      try {
        created = DateTime.parse(props['created']).toLocal();
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
    }

    if (created == null) {
      created = DateTime(0, 0, 0, 0, 0, 0, 0, 0);
    }

    _loadState = NoteLoadState.Loaded;
    return _loadState;
  }

  // FIXME: What about error handling?
  Future<void> save() async {
    assert(filePath != null);

    if (hasValidDate()) {
      props['created'] = toIso8601WithTimezone(created);
    }

    var file = File(filePath);
    var contents = _serializer.encode(NoteData(body, props));
    await file.writeAsString(contents);
  }

  // FIXME: What about error handling?
  Future<void> remove() async {
    var file = File(filePath);
    await file.delete();
  }

  // FIXME: Can't this part be auto-generated?
  @override
  int get hashCode =>
      filePath.hashCode ^ created.hashCode ^ body.hashCode ^ props.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          filePath == other.filePath &&
          body == other.body &&
          created == other.created &&
          _equalMaps(props, other.props);

  static bool _equalMaps(Map a, Map b) {
    if (a.length != b.length) return false;
    return a.keys
        .every((dynamic key) => b.containsKey(key) && a[key] == b[key]);
  }

  @override
  String toString() {
    return 'Note{filePath: $filePath, body: $body, created: $created, props: $props}';
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
