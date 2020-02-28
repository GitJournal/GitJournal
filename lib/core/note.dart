import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils/markdown.dart';
import 'package:path/path.dart' as p;

import 'md_yaml_doc.dart';
import 'md_yaml_doc_codec.dart';
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
  String _body = "";
  MdYamlDoc _data = MdYamlDoc();
  NoteSerializer noteSerializer = NoteSerializer();

  DateTime fileLastModified;

  var _loadState = NoteLoadState.None;
  var _serializer = MarkdownYAMLCodec();

  String _summary;

  Note(this.parent, this._filePath);

  Note.newNote(this.parent) {
    created = DateTime.now();
  }

  String get filePath {
    _filePath ??= p.join(parent.folderPath, getFileName(this));
    return _filePath;
  }

  String get fileName {
    return p.basename(filePath);
  }

  DateTime get created {
    return _created;
  }

  set created(DateTime dt) {
    if (!canHaveMetadata) return;

    _created = dt;
    notifyListeners();
  }

  DateTime get modified {
    return _modified;
  }

  set modified(DateTime dt) {
    if (!canHaveMetadata) return;

    _modified = dt;
    notifyListeners();
  }

  void updateModified() {
    modified = DateTime.now();
    notifyListeners();
  }

  String get body {
    return _body;
  }

  set body(String newBody) {
    _body = newBody;
    _summary = null;
    notifyListeners();
  }

  String get title {
    return _title;
  }

  set title(String title) {
    if (!canHaveMetadata) return;

    _title = title;
    notifyListeners();
  }

  bool get canHaveMetadata {
    return Settings.instance.yamlHeaderEnabled;
  }

  MdYamlDoc get data {
    noteSerializer.encode(this, _data);
    return _data;
  }

  set data(MdYamlDoc data) {
    _data = data;
    noteSerializer.decode(_data, this);

    notifyListeners();
  }

  bool isEmpty() {
    return body.isEmpty;
  }

  String get summary {
    _summary ??= stripMarkdownFormatting(body);
    return _summary;
  }

  Future<NoteLoadState> load() async {
    assert(_filePath != null);
    assert(_filePath.isNotEmpty);

    if (_loadState == NoteLoadState.Loading) {
      return _loadState;
    }

    final file = File(_filePath);
    if (_loadState == NoteLoadState.Loaded) {
      var fileLastModified = file.lastModifiedSync();
      if (fileLastModified == fileLastModified) {
        return _loadState;
      }
    }

    if (!file.existsSync()) {
      _loadState = NoteLoadState.NotExists;
      notifyListeners();
      return _loadState;
    }

    // FIXME: This could throw an exception!
    final string = await file.readAsString();
    data = _serializer.decode(string);

    fileLastModified = file.lastModifiedSync();
    _loadState = NoteLoadState.Loaded;

    notifyListeners();
    return _loadState;
  }

  // FIXME: What about error handling?
  Future<void> save() async {
    assert(_filePath != null);
    assert(_data != null);
    assert(_data.body != null);
    assert(_data.props != null);

    var file = File(filePath);
    var contents = _serializer.encode(data);
    await file.writeAsString(contents);
  }

  // FIXME: What about error handling?
  Future<void> remove() async {
    assert(_filePath != null);

    var file = File(_filePath);
    await file.delete();
  }

  void rename(String newName) {
    // Do not let the user rename it to a non-markdown file
    if (!newName.toLowerCase().endsWith('.md')) {
      newName += '.md';
    }

    var parentDirName = p.dirname(filePath);
    var newFilePath = p.join(parentDirName, newName);
    if (_loadState != NoteLoadState.None) {
      // for new notes
      File(filePath).renameSync(newFilePath);
    }
    _filePath = newFilePath;

    notifyListeners();
  }

  bool move(NotesFolder destFolder) {
    var destPath = p.join(destFolder.folderPath, fileName);
    if (File(destPath).existsSync()) {
      return false;
    }

    File(filePath).renameSync(destPath);

    parent.remove(this);
    parent = destFolder;
    destFolder.add(this);

    notifyListeners();
    return true;
  }

  @override
  int get hashCode => _filePath.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          _filePath == other._filePath &&
          _data == other._data;

  @override
  String toString() {
    return 'Note{filePath: $_filePath, created: $created, modified: $modified, data: $_data}';
  }

  @override
  int compareTo(Note other) {
    if (other == null) {
      return -1;
    }

    var dt = modified ?? created ?? fileLastModified;
    var otherDt = other.modified ?? other.created ?? other.fileLastModified;
    if (dt == null || otherDt == null) {
      return _filePath.compareTo(other._filePath);
    }

    return dt.compareTo(otherDt);
  }
}
