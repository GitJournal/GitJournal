import 'dart:io';

import 'package:gitjournal/storage/serializers.dart';
import 'package:gitjournal/datetime_utils.dart';

enum NoteLoadState {
  None,
  Loading,
  Loaded,
  NotExists,
}

class Note implements Comparable<Note> {
  String filePath = "";
  DateTime _created;
  NoteData _data = NoteData();

  DateTime _fileLastModified;

  var _loadState = NoteLoadState.None;
  var _serializer = MarkdownYAMLSerializer();

  Note([this.filePath]) {
    _created = _created ?? DateTime(0, 0, 0, 0, 0, 0, 0, 0);
  }

  DateTime get created {
    return _created;
  }

  set created(DateTime dt) {
    _created = dt;

    if (hasValidDate()) {
      _data.props['created'] = toIso8601WithTimezone(created);
    } else {
      _data.props.remove('created');
    }
  }

  String get body {
    return data.body;
  }

  set body(String newBody) {
    data.body = newBody;
  }

  NoteData get data {
    return _data;
  }

  set data(NoteData data) {
    _data = data;

    if (data.props.containsKey("created")) {
      var createdStr = data.props['created'].toString();
      try {
        _created = DateTime.parse(data.props['created']).toLocal();
      } catch (ex) {
        // Ignore it
      }

      if (_created == null) {
        var regex = RegExp(
            r"(\d{4})-(\d{2})-(\d{2})T(\d{2})\:(\d{2})\:(\d{2})\+(\d{2})\:(\d{2})");
        if (regex.hasMatch(createdStr)) {
          // FIXME: Handle the timezone!
          createdStr = createdStr.substring(0, 19);
          _created = DateTime.parse(createdStr);
        }
      }
    }

    if (_created == null) {
      _created = DateTime(0, 0, 0, 0, 0, 0, 0, 0);
    }
  }

  bool hasValidDate() {
    // Arbitrary number, when we set the year = 0, it becomes 1, somehow
    return created.year > 10;
  }

  bool isEmpty() {
    return body.isEmpty;
  }

  Future<NoteLoadState> load() async {
    if (_loadState == NoteLoadState.Loading) {
      return _loadState;
    }

    final file = File(filePath);
    if (_loadState == NoteLoadState.Loaded) {
      var fileLastModified = file.lastModifiedSync();
      if (fileLastModified == _fileLastModified) {
        return _loadState;
      }
    }

    if (!file.existsSync()) {
      _loadState = NoteLoadState.NotExists;
      return _loadState;
    }

    final string = await file.readAsString();
    data = _serializer.decode(string);

    _fileLastModified = file.lastModifiedSync();
    _loadState = NoteLoadState.Loaded;

    return _loadState;
  }

  // FIXME: What about error handling?
  Future<void> save() async {
    assert(filePath != null);
    assert(data != null);
    assert(data.body != null);
    assert(data.props != null);

    var file = File(filePath);
    var contents = _serializer.encode(data);
    await file.writeAsString(contents);
  }

  // FIXME: What about error handling?
  Future<void> remove() async {
    var file = File(filePath);
    await file.delete();
  }

  // FIXME: Can't this part be auto-generated?
  @override
  int get hashCode => filePath.hashCode ^ created.hashCode ^ data.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          filePath == other.filePath &&
          data == other.data;

  @override
  String toString() {
    return 'Note{filePath: $filePath, created: $created, data: $data}';
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
