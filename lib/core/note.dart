import 'dart:io';

import 'package:gitjournal/core/md_yaml_doc_loader.dart';
import 'package:gitjournal/core/note_notifier.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils/markdown.dart';
import 'package:gitjournal/utils/logger.dart';

import 'package:path/path.dart' as p;

import 'md_yaml_doc.dart';
import 'md_yaml_doc_codec.dart';
import 'note_fileName.dart';
import 'note_serializer.dart';

enum NoteLoadState {
  None,
  Loading,
  Loaded,
  NotExists,
}

enum NoteType {
  Unknown,
  Checklist,
  Journal,
}

class Note with NotesNotifier {
  NotesFolderFS parent;
  String _filePath;

  String _title = "";
  DateTime _created;
  DateTime _modified;
  String _body = "";
  NoteType _type = NoteType.Unknown;
  List<String> _tags = [];

  MdYamlDoc _data = MdYamlDoc();
  NoteSerializer noteSerializer = NoteSerializer();

  DateTime fileLastModified;

  var _loadState = NoteLoadState.None;
  var _serializer = MarkdownYAMLCodec();

  String _summary;

  static final _mdYamlDocLoader = MdYamlDocLoader();

  Note(this.parent, this._filePath);

  Note.newNote(this.parent) {
    created = DateTime.now();
    _loadState = NoteLoadState.Loaded;
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
    _notifyModified();
  }

  DateTime get modified {
    return _modified;
  }

  set modified(DateTime dt) {
    if (!canHaveMetadata) return;

    _modified = dt;
    _notifyModified();
  }

  void updateModified() {
    modified = DateTime.now();
    _notifyModified();
  }

  String get body {
    return _body;
  }

  set body(String newBody) {
    _body = newBody;
    _summary = null;
    _notifyModified();
  }

  String get title {
    return _title;
  }

  set title(String title) {
    if (!canHaveMetadata) return;

    _title = title;
    _notifyModified();
  }

  NoteType get type {
    return _type;
  }

  set type(NoteType type) {
    if (!canHaveMetadata) return;

    _type = type;
    _notifyModified();
  }

  List<String> get tags {
    return _tags;
  }

  set tags(List<String> tags) {
    if (!canHaveMetadata) return;

    _tags = tags;
    _notifyModified();
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

    _notifyModified();
  }

  bool isEmpty() {
    return body.isEmpty;
  }

  String get summary {
    if (_loadState != NoteLoadState.Loaded) return "";

    _summary ??= stripMarkdownFormatting(body);
    return _summary;
  }

  NoteLoadState get loadState {
    return _loadState;
  }

  Future<NoteLoadState> load() async {
    assert(_filePath != null);
    assert(_filePath.isNotEmpty);

    if (_loadState == NoteLoadState.Loading) {
      return _loadState;
    }

    final file = File(_filePath);
    if (_loadState == NoteLoadState.Loaded) {
      try {
        var fileLastModified = file.lastModifiedSync();
        if (this.fileLastModified == fileLastModified) {
          return _loadState;
        }
      } on FileSystemException catch (e) {
        if (e.osError.errorCode == 2 /* File Not Found */) {
          _loadState = NoteLoadState.NotExists;
          _notifyModified();
          return _loadState;
        }
      }
      Log.d("Note modified: $_filePath");
    }

    try {
      data = await _mdYamlDocLoader.loadDoc(_filePath);
    } on MdYamlDocNotFoundException catch (_) {
      _loadState = NoteLoadState.NotExists;
      _notifyModified();
      return _loadState;
    }

    fileLastModified = file.lastModifiedSync();
    _loadState = NoteLoadState.Loaded;

    _notifyModified();
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

    var oldFilePath = filePath;
    var parentDirName = p.dirname(filePath);
    var newFilePath = p.join(parentDirName, newName);
    if (_loadState != NoteLoadState.None) {
      // for new notes
      File(filePath).renameSync(newFilePath);
    }
    _filePath = newFilePath;

    notifyRenameListeners(this, oldFilePath);
    _notifyModified();
  }

  bool move(NotesFolderFS destFolder) {
    var destPath = p.join(destFolder.folderPath, fileName);
    if (File(destPath).existsSync()) {
      return false;
    }

    File(filePath).renameSync(destPath);

    parent.remove(this);
    parent = destFolder;
    destFolder.add(this);

    _notifyModified();
    return true;
  }

  Future<void> addImage(File file) async {
    var imageFileName = p.basename(file.path);
    var imagePath = p.join(parent.folderPath, imageFileName);
    await file.copy(imagePath);

    body = "$body\n ![Image](./$imageFileName)\n";
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

  void _notifyModified() {
    notifyModifiedListeners(this);
    notifyListeners();
  }

  String pathSpec() {
    if (parent == null) {
      return fileName;
    }
    return p.join(parent.pathSpec(), fileName);
  }
}
