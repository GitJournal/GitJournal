import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'note_data.dart';
import 'note_data_serializers.dart';
import 'note_fileName.dart';
import 'note_serializer.dart';
import 'notes_folder.dart';

enum NoteLoadState {
  None,
  Loading,
  Loaded,
  NotExists,
}

class Note with ChangeNotifier implements Comparable<Note> {
  NotesFolder parent;
  String _filePath;

  String _title = "";
  DateTime _created;
  DateTime _modified;
  NoteData _data = NoteData();

  DateTime _fileLastModified;

  var _loadState = NoteLoadState.None;
  var _serializer = MarkdownYAMLSerializer();

  Note(this.parent, this._filePath);

  Note.newNote(this.parent) {
    _created = DateTime.now();
    _filePath = p.join(parent.folderPath, getFileName(this));
  }

  String get filePath {
    return _filePath;
  }

  String get fileName {
    return p.basename(_filePath);
  }

  DateTime get created {
    return _created;
  }

  set created(DateTime dt) {
    _created = dt;
    notifyListeners();
  }

  DateTime get modified {
    return _modified;
  }

  set modified(DateTime dt) {
    _modified = dt;
    notifyListeners();
  }

  void updateModified() {
    modified = DateTime.now();
    notifyListeners();
  }

  String get body {
    return _data.body;
  }

  set body(String newBody) {
    _data.body = newBody;
    notifyListeners();
  }

  String get title {
    return _title;
  }

  set title(String title) {
    _title = title;
    notifyListeners();
  }

  NoteData get data {
    var serializer = NoteSerializer();
    serializer.encode(this, _data);

    return _data;
  }

  set data(NoteData data) {
    _data = data;

    // Fill the note's attributes from the data
    var serializer = NoteSerializer();
    serializer.decode(_data, this);

    notifyListeners();
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
      notifyListeners();
      return _loadState;
    }

    final string = await file.readAsString();
    data = _serializer.decode(string);

    _fileLastModified = file.lastModifiedSync();
    _loadState = NoteLoadState.Loaded;

    notifyListeners();
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

  @override
  int get hashCode => filePath.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          filePath == other.filePath &&
          _data == other._data;

  @override
  String toString() {
    return 'Note{filePath: $filePath, created: $created, modified: $modified, data: $_data}';
  }

  @override
  int compareTo(Note other) {
    if (other == null) {
      return -1;
    }

    var dt = modified ?? created ?? _fileLastModified;
    var otherDt = other.modified ?? other.created ?? other._fileLastModified;
    if (dt == null || otherDt == null) {
      return filePath.compareTo(other.filePath);
    }

    return dt.compareTo(otherDt);
  }
}
