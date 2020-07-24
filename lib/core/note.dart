import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'package:gitjournal/core/links_loader.dart';
import 'package:gitjournal/core/md_yaml_doc_loader.dart';
import 'package:gitjournal/core/note_notifier.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/settings.dart';
import 'package:gitjournal/utils/datetime.dart';
import 'package:gitjournal/utils/logger.dart';
import 'package:gitjournal/utils/markdown.dart';
import 'link.dart';
import 'md_yaml_doc.dart';
import 'md_yaml_doc_codec.dart';
import 'note_serializer.dart';

enum NoteLoadState {
  None,
  Loading,
  Loaded,
  NotExists,
  Error,
}

enum NoteType {
  Unknown,
  Checklist,
  Journal,
}

enum NoteFileFormat {
  Markdown,
  Txt,
}

class Note with NotesNotifier {
  NotesFolderFS parent;
  String _filePath;

  String _title = "";
  DateTime _created;
  DateTime _modified;
  String _body = "";
  NoteType _type = NoteType.Unknown;
  Set<String> _tags = {};

  NoteFileFormat _fileFormat;

  MdYamlDoc _data = MdYamlDoc();
  NoteSerializer noteSerializer = NoteSerializer();

  DateTime fileLastModified;

  var _loadState = NoteLoadState.None;
  var _serializer = MarkdownYAMLCodec();

  // Computed from body
  String _summary;
  List<Link> _links;

  static final _mdYamlDocLoader = MdYamlDocLoader();
  static final _linksLoader = LinksLoader();

  Note(this.parent, this._filePath);

  Note.newNote(this.parent, {Map<String, dynamic> extraProps = const {}}) {
    created = DateTime.now();
    _loadState = NoteLoadState.Loaded;
    _fileFormat = NoteFileFormat.Markdown;

    if (extraProps.isNotEmpty) {
      extraProps.forEach((key, value) {
        _data.props[key] = value;
      });
      noteSerializer.decode(_data, this);
    }
  }

  String get filePath {
    if (_filePath == null) {
      try {
        _filePath = p.join(parent.folderPath, _buildFileName());
      } catch (e, stackTrace) {
        Log.e("_buildFileName: $e");
        logExceptionWarning(e, stackTrace);
        _filePath = p.join(parent.folderPath, Uuid().v4());
      }
      switch (_fileFormat) {
        case NoteFileFormat.Txt:
          if (!_filePath.toLowerCase().endsWith('.txt')) {
            _filePath += '.txt';
          }
          break;
        case NoteFileFormat.Markdown:
        default:
          if (!_filePath.toLowerCase().endsWith('.md')) {
            _filePath += '.md';
          }
          break;
      }
    }

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
    if (newBody == _body) {
      return;
    }

    _body = newBody;
    _summary = null;
    _links = null;
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

  Set<String> get tags {
    return _tags;
  }

  set tags(Set<String> tags) {
    assert(tags != null);
    if (!canHaveMetadata) return;

    _tags = tags;
    _notifyModified();
  }

  bool get canHaveMetadata {
    if (_fileFormat == NoteFileFormat.Txt) {
      return false;
    }
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
        this.fileLastModified = fileLastModified;
      } catch (e, stackTrace) {
        if (e is FileSystemException &&
            e.osError.errorCode == 2 /* File Not Found */) {
          _loadState = NoteLoadState.NotExists;
          _notifyModified();
          return _loadState;
        }

        logExceptionWarning(e, stackTrace);
        _loadState = NoteLoadState.Error;
        _notifyModified();
        return _loadState;
      }
      Log.d("Note modified: $_filePath");
    }

    var fpLowerCase = _filePath.toLowerCase();
    var isMarkdown = fpLowerCase.endsWith('.md');
    var isTxt = fpLowerCase.endsWith('.txt');

    if (isMarkdown) {
      try {
        data = await _mdYamlDocLoader.loadDoc(_filePath);
        _fileFormat = NoteFileFormat.Markdown;
      } on MdYamlDocNotFoundException catch (_) {
        _loadState = NoteLoadState.NotExists;
        _notifyModified();
        return _loadState;
      }
    } else if (isTxt) {
      try {
        body = await File(_filePath).readAsString();
        _fileFormat = NoteFileFormat.Txt;
      } catch (e, stackTrace) {
        logExceptionWarning(e, stackTrace);

        _loadState = NoteLoadState.Error;
        _notifyModified();
        return _loadState;
      }
    } else {
      _loadState = NoteLoadState.Error;
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

  String serialize() {
    return _serializer.encode(data);
  }

  // FIXME: What about error handling?
  Future<void> remove() async {
    assert(_filePath != null);

    var file = File(_filePath);
    await file.delete();
  }

  void rename(String newName) {
    // Do not let the user rename it to a non-markdown file
    switch (_fileFormat) {
      case NoteFileFormat.Txt:
        if (!newName.toLowerCase().endsWith('.txt')) {
          newName += '.txt';
        }
        break;

      case NoteFileFormat.Markdown:
      default:
        if (!newName.toLowerCase().endsWith('.md')) {
          newName += '.md';
        }
        break;
    }

    var oldFilePath = filePath;
    var parentDirName = p.dirname(filePath);
    var newFilePath = p.join(parentDirName, newName);

    // The file will not exist for new notes
    if (File(oldFilePath).existsSync()) {
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
    var absImagePath = _buildImagePath(file);
    await file.copy(absImagePath);

    var relativeImagePath = p.relative(absImagePath, from: parent.folderPath);
    if (!relativeImagePath.startsWith('.')) {
      relativeImagePath = './$relativeImagePath';
    }
    var imageMarkdown = "![Image]($relativeImagePath)\n";
    if (body.isEmpty) {
      body = imageMarkdown;
    } else {
      body = "$body\n$imageMarkdown";
    }
  }

  Future<void> addImageSync(File file) async {
    var absImagePath = _buildImagePath(file);
    file.copySync(absImagePath);

    var relativeImagePath = p.relative(absImagePath, from: parent.folderPath);
    if (!relativeImagePath.startsWith('.')) {
      relativeImagePath = './$relativeImagePath';
    }
    var imageMarkdown = "![Image]($relativeImagePath)\n";
    if (body.isEmpty) {
      body = imageMarkdown;
    } else {
      body = "$body\n$imageMarkdown";
    }
  }

  String _buildImagePath(File file) {
    String baseFolder;

    var imageSpec = Settings.instance.imageLocationSpec;
    if (imageSpec == '.') {
      baseFolder = parent.folderPath;
    } else {
      baseFolder = parent.rootFolder.getFolderWithSpec(imageSpec).folderPath;
      baseFolder ??= parent.folderPath;
    }

    var imageFileName = p.basename(file.path);
    return p.join(baseFolder, imageFileName);
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
    return 'Note{filePath: $_filePath, created: $created, modified: $modified, data: $_data, loadState: $_loadState}';
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

  String _buildFileName() {
    var date = created ?? modified ?? fileLastModified ?? DateTime.now();
    switch (parent.config.fileNameFormat) {
      case NoteFileNameFormat.SimpleDate:
        return toSimpleDateTime(date);
      case NoteFileNameFormat.FromTitle:
        if (title.isNotEmpty) {
          return buildTitleFileName(parent.folderPath, title);
        } else {
          return toSimpleDateTime(date);
        }
        break;
      case NoteFileNameFormat.Iso8601:
        return toIso8601(date);
      case NoteFileNameFormat.Iso8601WithTimeZone:
        return toIso8601WithTimezone(date);
      case NoteFileNameFormat.Iso8601WithTimeZoneWithoutColon:
        return toIso8601WithTimezone(date).replaceAll(":", "_");
      case NoteFileNameFormat.UuidV4:
        return Uuid().v4();
    }

    return date.toString();
  }

  Future<List<Link>> fetchLinks() async {
    if (_links != null) {
      return _links;
    }

    _links = await _linksLoader.parseLinks(_body, parent.folderPath);
    return _links;
  }

  List<Link> links() {
    return _links;
  }

  NoteFileFormat get fileFormat {
    return _fileFormat;
  }
}

String buildTitleFileName(String parentDir, String title) {
  // Sanitize the title - these characters are not allowed in Windows
  title = title.replaceAll(RegExp(r'[/<\>":|?*]'), '_');

  var fileName = title + ".md";
  var fullPath = p.join(parentDir, fileName);
  var file = File(fullPath);
  if (!file.existsSync()) {
    return fileName;
  }

  for (var i = 1;; i++) {
    var fileName = title + "_$i.md";
    var fullPath = p.join(parentDir, fileName);
    var file = File(fullPath);
    if (!file.existsSync()) {
      return fileName;
    }
  }
}
