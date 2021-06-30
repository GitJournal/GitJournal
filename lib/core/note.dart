/*
Copyright 2020-2021 Vishesh Handa <me@vhanda.in>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import 'dart:io';

import 'package:dart_git/utils/result.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'package:gitjournal/core/links_loader.dart';
import 'package:gitjournal/core/md_yaml_doc_loader.dart';
import 'package:gitjournal/core/note_notifier.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/core/processors/image_extractor.dart';
import 'package:gitjournal/core/processors/inline_tags.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/utils/datetime.dart';
import 'package:gitjournal/utils/logger.dart';
import 'package:gitjournal/utils/markdown.dart';
import 'link.dart';
import 'md_yaml_doc.dart';
import 'md_yaml_doc_codec.dart';
import 'note_serializer.dart';

typedef void NoteSelectedFunction(Note note);
typedef bool NoteBoolPropertyFunction(Note note);

/// Move this to NotesFolderFS
enum NoteLoadState {
  None,
  Loading,
  Loaded,
  NotExists,
  Error,
}

enum NoteType { Unknown, Checklist, Journal, Org }

class NoteFileFormatInfo {
  static List<String> allowedExtensions = ['.md', '.org', '.txt'];

  static String defaultExtension(NoteFileFormat format) {
    switch (format) {
      case NoteFileFormat.Markdown:
        return ".md";
      case NoteFileFormat.OrgMode:
        return '.org';
      case NoteFileFormat.Txt:
        return ".txt";
      default:
        return ".md";
    }
  }

  static bool isAllowedFileName(String filePath) {
    var noteFilePath = filePath.toLowerCase();
    for (var ext in allowedExtensions) {
      if (noteFilePath.endsWith(ext)) {
        return true;
      }
    }

    return false;
  }
}

enum NoteFileFormat {
  Markdown,
  OrgMode,
  Txt,
}

class Note with NotesNotifier {
  NotesFolderFS parent;
  String? _filePath;

  String _title = "";
  DateTime? _created;
  DateTime? _modified;
  String _body = "";
  NoteType _type = NoteType.Unknown;
  Set<String> _tags = {};
  Map<String, dynamic> _extraProps = {};

  NoteFileFormat? _fileFormat;

  MdYamlDoc _data = MdYamlDoc();
  late NoteSerializer noteSerializer;

  DateTime? fileLastModified;

  var _loadState = NoteLoadState.None;
  var _serializer = MarkdownYAMLCodec();

  // Computed from body
  String? _summary;
  List<Link>? _links;
  Set<String>? _inlineTags;
  Set<NoteImage>? _images;

  static final _mdYamlDocLoader = MdYamlDocLoader();
  static final _linksLoader = LinksLoader();

  Note(this.parent, this._filePath) {
    noteSerializer = NoteSerializer.fromConfig(parent.config);
  }

  Note.newNote(
    this.parent, {
    Map<String, dynamic> extraProps = const {},
    String fileName = "",
  }) {
    created = DateTime.now();
    _loadState = NoteLoadState.Loaded;
    _fileFormat = NoteFileFormat.Markdown;
    noteSerializer = NoteSerializer.fromConfig(parent.config);

    if (extraProps.isNotEmpty) {
      extraProps.forEach((key, value) {
        _data.props[key] = value;
      });
      noteSerializer.decode(_data, this);
    }

    if (fileName.isNotEmpty) {
      // FIXME: We should ensure a note with this fileName does not already
      //        exist
      if (!NoteFileFormatInfo.isAllowedFileName(fileName)) {
        fileName +=
            NoteFileFormatInfo.defaultExtension(NoteFileFormat.Markdown);
      }
      _filePath = p.join(parent.folderPath, fileName);
      Log.i("Constructing new note with path $_filePath");
    }
  }

  String get filePath {
    if (_filePath == null) {
      var fp = "";
      try {
        fp = p.join(parent.folderPath, _buildFileName());
      } catch (e, stackTrace) {
        Log.e("_buildFileName: $e");
        logExceptionWarning(e, stackTrace);
        fp = p.join(parent.folderPath, const Uuid().v4());
      }
      switch (_fileFormat) {
        case NoteFileFormat.OrgMode:
          if (!fp.toLowerCase().endsWith('.org')) {
            fp += '.org';
          }
          break;

        case NoteFileFormat.Txt:
          if (!fp.toLowerCase().endsWith('.txt')) {
            fp += '.txt';
          }
          break;

        case NoteFileFormat.Markdown:
        default:
          if (!fp.toLowerCase().endsWith('.md')) {
            fp += '.md';
          }
          break;
      }

      _filePath = fp;
    }

    return _filePath as String;
  }

  String get fileName {
    return p.basename(filePath);
  }

  DateTime? get created {
    return _created;
  }

  set created(DateTime? dt) {
    if (!canHaveMetadata) return;

    _created = dt;
    _notifyModified();
  }

  DateTime? get modified {
    return _modified;
  }

  set modified(DateTime? dt) {
    if (!canHaveMetadata) return;

    _modified = dt;
    _notifyModified();
  }

  void updateModified() {
    modified = DateTime.now();
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
    _inlineTags = null;
    _images = null;

    _notifyModified();
  }

  String get title {
    return _title;
  }

  set title(String title) {
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
    if (!canHaveMetadata) return;

    _tags = tags;
    _notifyModified();
  }

  Set<String> get inlineTags {
    if (_loadState != NoteLoadState.Loaded) return {};

    if (_inlineTags == null) {
      var tagPrefixes = parent.config.inlineTagPrefixes;
      var p = InlineTagsProcessor(tagPrefixes: tagPrefixes);
      _inlineTags = p.extractTags(body);
    }
    return _inlineTags!;
  }

  Set<NoteImage> get images {
    if (_loadState != NoteLoadState.Loaded) return {};

    var p = ImageExtractor();
    _images = p.extract(body);

    return _images!;
  }

  Map<String, dynamic> get extraProps {
    return _extraProps;
  }

  set extraProps(Map<String, dynamic> props) {
    if (!canHaveMetadata) return;

    _extraProps = props;
    _notifyModified();
  }

  bool get canHaveMetadata {
    if (_fileFormat == NoteFileFormat.Txt ||
        _fileFormat == NoteFileFormat.OrgMode) {
      return false;
    }
    return parent.config.yamlHeaderEnabled;
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
    return _summary!;
  }

  NoteLoadState get loadState {
    return _loadState;
  }

  Future<Result<NoteLoadState>> load() async {
    assert(_filePath != null);
    assert(_filePath!.isNotEmpty);

    if (_loadState == NoteLoadState.Loading) {
      return Result(_loadState);
    }

    final file = File(_filePath!);
    if (_loadState == NoteLoadState.Loaded) {
      try {
        var fileLastModified = file.lastModifiedSync();
        if (this.fileLastModified == fileLastModified) {
          return Result(_loadState);
        }
        this.fileLastModified = fileLastModified;
      } catch (e, stackTrace) {
        if (e is FileSystemException &&
            e.osError!.errorCode == 2 /* File Not Found */) {
          _loadState = NoteLoadState.NotExists;
          _notifyModified();
          return Result(_loadState);
        }

        logExceptionWarning(e, stackTrace);
        _loadState = NoteLoadState.Error;
        _notifyModified();
        return Result(_loadState);
      }
      Log.d("Note modified: $_filePath");
    }

    var fpLowerCase = _filePath!.toLowerCase();
    var isMarkdown = fpLowerCase.endsWith('.md');
    var isTxt = fpLowerCase.endsWith('.txt');
    var isOrg = fpLowerCase.endsWith('.org');

    if (isMarkdown) {
      var dataResult = await _mdYamlDocLoader.loadDoc(_filePath!);
      if (dataResult.isSuccess) {
        data = dataResult.getOrThrow();
        _fileFormat = NoteFileFormat.Markdown;
      } else {
        if (dataResult.error is MdYamlDocNotFoundException) {
          _loadState = NoteLoadState.NotExists;
          _notifyModified();
          return Result(_loadState);
        }
        if (dataResult.error is MdYamlParsingException) {
          _loadState = NoteLoadState.Error;
          _notifyModified();
          return Result(_loadState);
        }
      }
    } else if (isTxt) {
      try {
        body = await File(_filePath!).readAsString();
        _fileFormat = NoteFileFormat.Txt;
      } catch (e, stackTrace) {
        logExceptionWarning(e, stackTrace);

        _loadState = NoteLoadState.Error;
        _notifyModified();
        return Result(_loadState);
      }
    } else if (isOrg) {
      try {
        body = await File(_filePath!).readAsString();
        _fileFormat = NoteFileFormat.OrgMode;
      } catch (e, stackTrace) {
        logExceptionWarning(e, stackTrace);

        _loadState = NoteLoadState.Error;
        _notifyModified();
        return Result(_loadState);
      }
    } else {
      _loadState = NoteLoadState.Error;
      _notifyModified();
      return Result(_loadState);
    }

    fileLastModified = file.lastModifiedSync();
    _loadState = NoteLoadState.Loaded;

    _notifyModified();
    return Result(_loadState);
  }

  // FIXME: What about error handling?
  Future<void> save() async {
    var file = File(filePath);
    var contents = _serializer.encode(data);
    // Make sure all docs end with a \n
    if (!contents.endsWith('\n')) {
      contents += '\n';
    }

    await file.writeAsString(contents, flush: true);
  }

  String serialize() {
    return _serializer.encode(data);
  }

  // FIXME: What about error handling?
  Future<void> remove() async {
    assert(_filePath != null);

    var file = File(filePath);
    await file.delete();
  }

  ///
  /// Do not let the user rename it to a different file-type.
  ///
  void rename(String newName) {
    switch (_fileFormat) {
      case NoteFileFormat.OrgMode:
        if (!newName.toLowerCase().endsWith('.org')) {
          newName += '.org';
        }
        break;

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

  Future<void> addImage(String filePath) async {
    var file = File(filePath);
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

    var imageSpec = parent.config.imageLocationSpec;
    if (imageSpec == '.') {
      baseFolder = parent.folderPath;
    } else {
      var folder = parent.rootFolder.getFolderWithSpec(imageSpec);
      if (folder != null) {
        baseFolder = folder.folderPath;
      } else {
        baseFolder = parent.folderPath;
      }
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
    return p.join(parent.pathSpec(), fileName);
  }

  String _buildFileName() {
    var date = created ?? modified ?? fileLastModified ?? DateTime.now();
    var isJournal = type == NoteType.Journal;
    switch (!isJournal
        ? parent.config.fileNameFormat
        : parent.config.journalFileNameFormat) {
      case NoteFileNameFormat.SimpleDate:
        return toSimpleDateTime(date);
      case NoteFileNameFormat.DateOnly:
        var dateStr = toDateString(date);
        return ensureFileNameUnique(parent.folderPath, dateStr, ".md");
      case NoteFileNameFormat.FromTitle:
        if (title.isNotEmpty) {
          return buildTitleFileName(parent.folderPath, title);
        } else {
          return toSimpleDateTime(date);
        }
      case NoteFileNameFormat.Iso8601:
        return toIso8601(date);
      case NoteFileNameFormat.Iso8601WithTimeZone:
        return toIso8601WithTimezone(date);
      case NoteFileNameFormat.Iso8601WithTimeZoneWithoutColon:
        return toIso8601WithTimezone(date).replaceAll(":", "_");
      case NoteFileNameFormat.UuidV4:
        return const Uuid().v4();
      case NoteFileNameFormat.Zettelkasten:
        return toZettleDateTime(date);
    }

    return date.toString();
  }

  Future<List<Link>> fetchLinks() async {
    if (_links != null) {
      return _links!;
    }

    _links = await _linksLoader.parseLinks(body: _body, filePath: _filePath!);
    return _links!;
  }

  List<Link>? links() {
    return _links;
  }

  NoteFileFormat? get fileFormat {
    return _fileFormat;
  }
}

String ensureFileNameUnique(String parentDir, String name, String ext) {
  var fileName = name + ext;
  var fullPath = p.join(parentDir, fileName);
  var file = File(fullPath);
  if (!file.existsSync()) {
    return fileName;
  }

  for (var i = 1;; i++) {
    var fileName = name + "_$i$ext";
    var fullPath = p.join(parentDir, fileName);
    var file = File(fullPath);
    if (!file.existsSync()) {
      return fileName;
    }
  }
}

String buildTitleFileName(String parentDir, String title) {
  // Sanitize the title - these characters are not allowed in Windows
  title = title.replaceAll(RegExp(r'[/<\>":|?*]'), '_');

  return ensureFileNameUnique(parentDir, title, ".md");
}
