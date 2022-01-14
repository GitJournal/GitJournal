/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:collection/collection.dart';
import 'package:dart_date/dart_date.dart';
import 'package:path/path.dart' as p;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:universal_io/io.dart' as io;
import 'package:uuid/uuid.dart';

import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/editors/common_types.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/generated/core.pb.dart' as pb;
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/utils/datetime.dart';
import 'file/file.dart';
import 'folder/notes_folder_config.dart';
import 'markdown/md_yaml_doc.dart';
import 'markdown/md_yaml_note_serializer.dart';

typedef NoteSelectedFunction = void Function(Note note);
typedef NoteBoolPropertyFunction = bool Function(Note note);

enum NoteType { Unknown, Checklist, Journal, Org }

class NoteFileFormatInfo {
  final NotesFolderConfig config;
  NoteFileFormatInfo(this.config);

  static String defaultExtension(NoteFileFormat format) {
    switch (format) {
      case NoteFileFormat.Markdown:
        return ".md";
      case NoteFileFormat.OrgMode:
        return '.org';
      case NoteFileFormat.Txt:
        return ".txt";
    }
  }

  static EditorType defaultEditor(NoteFileFormat format) {
    switch (format) {
      case NoteFileFormat.Markdown:
        return EditorType.Markdown;
      case NoteFileFormat.Txt:
        return EditorType.Raw;
      case NoteFileFormat.OrgMode:
        return EditorType.Org;
    }
  }

  static NoteFileFormat fromFilePath(String filePath) {
    var ext = p.extension(filePath).toLowerCase();
    switch (ext) {
      case ".md":
        return NoteFileFormat.Markdown;
      case ".org":
        return NoteFileFormat.OrgMode;
      case ".txt":
      default:
        return NoteFileFormat.Txt;
    }
  }

  bool isAllowedFileName(String filePath) {
    var noteFilePath = filePath.toLowerCase();
    for (var ext in config.allowedFileExts) {
      if (p.extension(noteFilePath) == ext) {
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

  String? _title;
  DateTime? _created;
  DateTime? _modified;
  String _body = "";
  NoteType _type = NoteType.Unknown;
  Set<String> _tags = {};
  Map<String, dynamic> _extraProps = {};

  NoteFileFormat _fileFormat;

  MdYamlDoc _data = MdYamlDoc();
  late NoteSerializer noteSerializer;

  late File file;

  @override
  DateTime get fileLastModified => file.fileLastModified;

  @override
  GitHash get oid => file.oid;

  @override
  String get repoPath => file.repoPath;

  @override
  String get filePath => file.filePath;

  @override
  String get fullFilePath => p.join(repoPath, filePath);

  Note.build({
    required this.parent,
    required this.file,
    required String? title,
    required String body,
    required NoteType noteType,
    required Set<String> tags,
    required Map<String, dynamic> extraProps,
    required NoteFileFormat fileFormat,
    required MdYamlDoc doc,
    required NoteSerializationSettings serializerSettings,
    required DateTime? modified,
    required DateTime? created,
  })  : _title = title,
        _body = body,
        _type = noteType,
        _tags = tags,
        _extraProps = extraProps,
        _fileFormat = fileFormat,
        _data = doc,
        _modified = modified,
        _created = created,
        noteSerializer = NoteSerializer.fromConfig(serializerSettings) {
    assert(_title != null ? _title!.isNotEmpty : true);
  }

  Note.newNote(
    this.parent, {
    required NoteFileFormat fileFormat,
    Map<String, dynamic> extraProps = const {},
    String? fileName,
  })  : file = File.empty(
          repoPath: parent.repoPath,
          dt: DateTime.now().setMicrosecond(0).setMillisecond(0),
        ),
        _fileFormat = fileFormat {
    _created = DateTime.now();
    var settings = NoteSerializationSettings.fromConfig(parent.config);
    noteSerializer = NoteSerializer.fromConfig(settings);

    if (extraProps.isNotEmpty) {
      extraProps.forEach((key, value) {
        _data.props[key] = value;
      });
      var newNote = noteSerializer.decode(
        data: _data,
        file: file,
        parent: parent,
        fileFormat: _fileFormat,
      );
      _body = newNote._body;
      _created = newNote._created;
      _modified = newNote._modified;
      _title = newNote._title;
      _tags = newNote._tags;
      _type = newNote._type;
    }

    // FIXME: Ensure this fileName doesn't exist
    var filePath = buildFilePath(
      parent: parent,
      fileFormat: fileFormat,
      created: created,
      type: type,
      fileName: fileName,
      title: title,
    );

    file = file.copyFile(filePath: filePath);
    assert(p.dirname(fullFilePath) == parent.fullFolderPath);

    assert(_title != null ? _title!.isNotEmpty : true);
  }

  /// This doesn't modify the Note class
  String rebuildFileName() {
    var newPath = buildFilePath(
      parent: parent,
      fileFormat: fileFormat,
      created: created,
      type: type,
      fileName: null,
      title: title,
    );
    return p.basename(newPath);
  }

  static String buildFilePath({
    required NotesFolderFS parent,
    required NoteFileFormat fileFormat,
    required DateTime created,
    required NoteType type,
    required String? fileName,
    required String? title,
  }) {
    // The fileName is not null when following a wikiLink
    if (fileName != null) {
      assert(!fileName.endsWith(p.separator));
      assert(!parent.folderPath.endsWith(p.separator));
      assert(!parent.fullFolderPath.endsWith(p.separator));

      var formatInfo = NoteFileFormatInfo(parent.config);
      if (!formatInfo.isAllowedFileName(fileName)) {
        fileName += NoteFileFormatInfo.defaultExtension(fileFormat);
      }

      var fp = p.join(parent.folderPath, fileName);
      Log.i("Constructing new note with path $fp");

      return fp;
    }

    var fp = "";
    try {
      var fileName = _buildFileName(
        parent: parent,
        fileFormat: fileFormat,
        created: created,
        type: type,
        title: title,
      );
      fp = p.join(parent.folderPath, fileName);
    } catch (e, stackTrace) {
      Log.e("_buildFileName: $e");
      logExceptionWarning(e, stackTrace);
      fp = p.join(parent.folderPath, const Uuid().v4());
    }
    switch (fileFormat) {
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
    return fp;
  }

  static String _buildFileName({
    required DateTime created,
    required NoteType type,
    required NoteFileFormat fileFormat,
    required NotesFolderFS parent,
    required String? title,
  }) {
    var date = created;
    var isJournal = type == NoteType.Journal;
    var ext = NoteFileFormatInfo.defaultExtension(fileFormat);
    var format = !isJournal
        ? parent.config.fileNameFormat
        : parent.config.journalFileNameFormat;
    switch (format) {
      case NoteFileNameFormat.SimpleDate:
        return toSimpleDateTime(date);
      case NoteFileNameFormat.DateOnly:
        var dateStr = toDateString(date);
        return ensureFileNameUnique(parent.fullFolderPath, dateStr, ext);
      case NoteFileNameFormat.FromTitle:
        if (title != null) {
          return buildTitleFileName(parent.fullFolderPath, title, ext);
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

  void apply({
    DateTime? created,
    DateTime? modified,
    String? body,
    String? title,
    NoteType? type,
    Map<String, dynamic>? extraProps,
    Set<String>? tags,
    String? fileName,
  }) {
    var changed = false;

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

    if (title != null) {
      title = title.isEmpty ? null : title;
      if (title != _title) {
        _title = title;
        changed = true;
      }
    }

    if (fileName != null && fileName != this.fileName) {
      var filePath = p.join(p.dirname(this.filePath), fileName);
      if (filePath.startsWith('./')) {
        filePath = filePath.substring(2);
      }
      file = file.copyFile(filePath: filePath);

      _fileFormat = NoteFileFormatInfo.fromFilePath(filePath);
      changed = true;
    }

    if (changed) {
      _notifyModified();
    }
  }

  Note copyWith({
    String? filePath,
    DateTime? created,
    DateTime? modified,
    String? body,
    String? title,
    NoteType? type,
    Map<String, dynamic>? extraProps,
    Set<String>? tags,
    NoteFileFormat? fileFormat,
    File? file,
  }) {
    if (filePath != null && filePath.startsWith('./')) {
      filePath = filePath.substring(2);
    }

    return Note.build(
      body: body ?? this.body,
      parent: parent,
      doc: data,
      file: file ?? this.file.copyFile(filePath: filePath),
      created: created,
      modified: modified,
      title: title ?? this.title,
      noteType: type ?? this.type,
      extraProps: extraProps ?? this.extraProps,
      tags: tags ?? this.tags,
      fileFormat: fileFormat ?? this.fileFormat,
      serializerSettings: noteSerializer.settings.clone(),
    );
  }

  @override
  String get fileName {
    return p.basename(filePath);
  }

  @override
  DateTime get created {
    return _created ?? file.created;
  }

  @override
  DateTime get modified {
    return _modified ?? file.modified;
  }

  void updateModified() {
    _modified = DateTime.now();
    _notifyModified();
  }

  bool get shouldRebuildPath {
    if (fileFormat != NoteFileFormat.Markdown) return false;

    return parent.config.fileNameFormat == NoteFileNameFormat.FromTitle;
  }

  String get body => _body;
  String? get title {
    assert(_title != null ? _title!.isNotEmpty : true);
    return _title;
  }

  NoteType get type => _type;
  Set<String> get tags => _tags;
  Map<String, dynamic> get extraProps => _extraProps;

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

  bool get pinned => extraProps["pinned"] == true;

  @override
  int get hashCode => file.hashCode ^ _data.hashCode;

  static final _mapEq = const MapEquality().equals;
  static final _setEq = const SetEquality().equals;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          parent.folderPath == other.parent.folderPath &&
          _title == other._title &&
          // _created == other._created &&
          // _modified == other._modified &&
          _body == other._body &&
          _type == other._type &&
          _setEq(_tags, other._tags) &&
          _mapEq(_extraProps, other._extraProps) &&
          _fileFormat == other._fileFormat &&
          _data == other._data &&
          noteSerializer.settings == other.noteSerializer.settings &&
          file.oid == other.file.oid &&
          file.filePath == other.file.filePath;

  // FIXME: operator== should compare the full file?

  @override
  String toString() {
    var pb = toProtoBuf().toProto3Json().toString();
    return 'Note{filePath: ${file.filePath}, pb: $pb}';
  }

  void _notifyModified() {
    parent.noteModified(this);
  }

  NoteFileFormat get fileFormat => _fileFormat;

  @override
  File copyFile({
    GitHash? oid,
    String? filePath,
    DateTime? modified,
    DateTime? created,
    DateTime? fileLastModified,
  }) {
    return File(
      oid: oid ?? this.oid,
      filePath: filePath ?? this.filePath,
      repoPath: repoPath,
      modified: modified ?? this.modified,
      created: created ?? this.created,
      fileLastModified: fileLastModified ?? this.fileLastModified,
    );
  }

  @override
  $pb.GeneratedMessage toProtoBuf() {
    // Not sure why this is happening
    dynamic pbFile = file.toProtoBuf();
    if (pbFile is pb.Note) {
      pbFile = pbFile.file;
    }

    return pb.Note(
      file: pbFile,
      title: title,
      body: body,
      type: _typeToProto(type),
      tags: tags,
      extraProps: mapToProtoBuf(extraProps),
      fileFormat: _formatToProto(fileFormat),
      doc: _data.toProtoBuf(),
      modified: _modified?.toProtoBuf(),
      created: _created?.toProtoBuf(),
      serializerSettings: noteSerializer.settings.toProtoBuf(),
    );
  }

  static Note fromProtoBuf(NotesFolderFS parent, pb.Note n) {
    var title = n.hasTitle() ? n.title : null;
    if (title != null && title.isEmpty) {
      title = null;
    }

    return Note.build(
      parent: parent,
      file: File.fromProtoBuf(n.file),
      title: title,
      body: n.body,
      noteType: _typeFromProto(n.type),
      tags: n.tags.toSet(),
      extraProps: mapFromProtoBuf(n.extraProps),
      fileFormat: _formatFromProto(n.fileFormat),
      doc: MdYamlDoc.fromProtoBuf(n.doc),
      serializerSettings:
          NoteSerializationSettings.fromProtoBuf(n.serializerSettings),
      modified: n.hasModified() ? n.modified.toDateTime() : null,
      created: n.hasCreated() ? n.created.toDateTime() : null,
    );
  }
}

pb.NoteType _typeToProto(NoteType type) {
  switch (type) {
    case NoteType.Unknown:
      return pb.NoteType.Unknown;
    case NoteType.Checklist:
      return pb.NoteType.Checklist;
    case NoteType.Journal:
      return pb.NoteType.Journal;
    case NoteType.Org:
      return pb.NoteType.Org;
  }
}

NoteType _typeFromProto(pb.NoteType type) {
  switch (type) {
    case pb.NoteType.Unknown:
      return NoteType.Unknown;
    case pb.NoteType.Checklist:
      return NoteType.Checklist;
    case pb.NoteType.Journal:
      return NoteType.Journal;
    case pb.NoteType.Org:
      return NoteType.Org;
  }

  return NoteType.Unknown;
}

pb.NoteFileFormat _formatToProto(NoteFileFormat fmt) {
  switch (fmt) {
    case NoteFileFormat.Markdown:
      return pb.NoteFileFormat.Markdown;
    case NoteFileFormat.Txt:
      return pb.NoteFileFormat.Txt;
    case NoteFileFormat.OrgMode:
      return pb.NoteFileFormat.OrgMode;
  }
}

NoteFileFormat _formatFromProto(pb.NoteFileFormat fmt) {
  switch (fmt) {
    case pb.NoteFileFormat.Markdown:
      return NoteFileFormat.Markdown;
    case pb.NoteFileFormat.Txt:
      return NoteFileFormat.Txt;
    case pb.NoteFileFormat.OrgMode:
      return NoteFileFormat.OrgMode;
  }

  return NoteFileFormat.Markdown;
}

String ensureFileNameUnique(String parentDir, String name, String ext) {
  var fileName = name + ext;
  var fullPath = p.join(parentDir, fileName);
  assert(fullPath.startsWith(p.separator));

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

String buildTitleFileName(String parentDir, String title, String ext) {
  // Sanitize the title - these characters are not allowed in Windows
  title = title.replaceAll(RegExp(r'[/<\>":|?*]'), '_');

  return ensureFileNameUnique(parentDir, title, ext);
}
