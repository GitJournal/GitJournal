/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart' as io;
import 'package:uuid/uuid.dart';

import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/utils/datetime.dart';
import 'file/file.dart';
import 'md_yaml_doc.dart';
import 'note_serializer.dart';

typedef NoteSelectedFunction = void Function(Note note);
typedef NoteBoolPropertyFunction = bool Function(Note note);

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

// FIXME: Treat Markdown and Markdown + YAML differently
enum NoteFileFormat {
  Markdown,
  OrgMode,
  Txt,
}

class Note implements File {
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

  @override
  DateTime fileLastModified;

  @override
  GitHash get oid => GitHash.zero();

  var _loadState = NoteLoadState.None;

  Note(this.parent, this._filePath, this.fileLastModified) {
    var settings = NoteSerializationSettings.fromConfig(parent.config);
    noteSerializer = NoteSerializer.fromConfig(settings);
  }

  /*
  Note.build({
    required this.parent,
    required String filePath,
    required String title,
    required DateTime created,
    required DateTime modified,
    required String body,
    required NoteType noteType,
    required Set<String> tags,
    required Map<String, dynamic> extraProps,
    required NoteFileFormat fileFormat,
    required this.fileLastModified,
    required MdYamlDoc doc,
    required NoteSerializationSettings serializerSettings,
  }) {
    _filePath = filePath;
    _title = title;
    _created = created;
    _modified = modified;
    _body = body;
    _type = noteType;
    _tags = tags;
    _extraProps = extraProps;
    _fileFormat = fileFormat;
    _data = doc;
    noteSerializer = NoteSerializer.fromConfig(serializerSettings);
  }
  */

  Note.newNote(
    this.parent, {
    Map<String, dynamic> extraProps = const {},
    String? fileName,
  }) : fileLastModified = DateTime.fromMillisecondsSinceEpoch(0) {
    _created = DateTime.now();
    _loadState = NoteLoadState.Loaded;
    _fileFormat = parent.config.defaultFileFormat.toFileFormat();
    var settings = NoteSerializationSettings.fromConfig(parent.config);
    noteSerializer = NoteSerializer.fromConfig(settings);

    if (extraProps.isNotEmpty) {
      extraProps.forEach((key, value) {
        _data.props[key] = value;
      });
      noteSerializer.decode(_data, this);
    }

    if (fileName != null) {
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

  @override
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

  void apply({
    String? filePath,
    DateTime? created,
    DateTime? modified,
    String? body,
    String? title,
    NoteType? type,
    Map<String, dynamic>? extraProps,
    Set<String>? tags,
    NoteFileFormat? fileFormat,
    NoteLoadState? loadState,
  }) {
    var changed = false;
    if (filePath != null) {
      _filePath = filePath;
      changed = true;
    }
    if (canHaveMetadata) {
      if (created != null && created != _created) {
        _created = created;
        changed = true;
      }
      if (modified != null && modified != _modified) {
        _modified = modified;
        changed = true;
      }

      if (type != null && type != _type) {
        _type = type;
        changed = true;
      }

      if (extraProps != null) {
        _extraProps = extraProps;
        changed = true;
      }

      if (tags != null) {
        _tags = tags;
        changed = true;
      }
    }

    if (body != null && body != _body) {
      _body = body;
      changed = true;
    }

    if (title != null && title != _title) {
      _title = title;
      changed = true;
    }

    if (fileFormat != null && _fileFormat != fileFormat) {
      _fileFormat = fileFormat;
      changed = true;
    }

    if (loadState != null && _loadState != loadState) {
      _loadState = loadState;
      changed = true;
    }

    if (changed) {
      _notifyModified();
    }
  }

  @override
  String get fileName {
    return p.basename(filePath);
  }

  @override
  DateTime? get created {
    return _created;
  }

  @override
  DateTime? get modified {
    return _modified;
  }

  void updateModified() {
    _modified = DateTime.now();
    _notifyModified();
  }

  String get body {
    return _body;
  }

  String get title {
    return _title;
  }

  NoteType get type {
    return _type;
  }

  Set<String> get tags {
    return _tags;
  }

  Map<String, dynamic> get extraProps {
    return _extraProps;
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

  NoteLoadState get loadState {
    return _loadState;
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
    parent.noteModified(this);
  }

  String pathSpec() {
    return p.join(parent.pathSpec(), fileName);
  }

  String _buildFileName() {
    var date = created ?? modified ?? fileLastModified;
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

  NoteFileFormat? get fileFormat {
    return _fileFormat;
  }
}

String ensureFileNameUnique(String parentDir, String name, String ext) {
  var fileName = name + ext;
  var fullPath = p.join(parentDir, fileName);
  var file = io.File(fullPath);
  if (!file.existsSync()) {
    return fileName;
  }

  for (var i = 1;; i++) {
    var fileName = name + "_$i$ext";
    var fullPath = p.join(parentDir, fileName);
    var file = io.File(fullPath);
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
