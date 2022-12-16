/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:collection/collection.dart';
import 'package:dart_date/dart_date.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/error_reporting.dart';
import 'package:gitjournal/generated/core.pb.dart' as pb;
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/settings/settings.dart';
import 'package:gitjournal/utils/datetime.dart';
import 'package:gitjournal/utils/note_filename_template.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';
import 'package:universal_io/io.dart' as io;
import 'package:uuid/uuid.dart';

import 'file/file.dart';
import 'markdown/md_yaml_doc.dart';
import 'markdown/md_yaml_note_serializer.dart';
import 'notes/note.dart';

@immutable
class Note implements File {
  final NotesFolderFS parent;

  final String? _title;
  final DateTime? _created;
  final DateTime? _modified;
  final String _body;
  final NoteType _type;
  final ISet<String> _tags;

  final Map<String, dynamic> _extraProps;
  final IList<String> _propsList;

  final NoteFileFormat _fileFormat;

  final NoteSerializer noteSerializer;

  final File file;

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
    required ISet<String> tags,
    required Map<String, dynamic> extraProps,
    required NoteFileFormat fileFormat,
    required IList<String> propsList,
    required NoteSerializationSettings serializerSettings,
    required DateTime? modified,
    required DateTime? created,
  })  : _title = title != null ? (title.isEmpty ? null : title) : null,
        _body = body,
        _type = noteType,
        _tags = tags,
        _extraProps = extraProps,
        _fileFormat = fileFormat,
        _propsList = propsList,
        _modified = modified,
        _created = created,
        noteSerializer = NoteSerializer.fromConfig(serializerSettings);

  static Note newNote(
    NotesFolderFS parent, {
    required NoteFileFormat fileFormat,
    Map<String, dynamic> extraProps = const {},
    String? fileName,
  }) {
    var file = File.empty(
      repoPath: parent.repoPath,
      dt: DateTime.now().setMicrosecond(0).setMillisecond(0),
    );

    DateTime? created;
    DateTime? modified;
    var settings = NoteSerializationSettings.fromConfig(parent.config);
    var noteSerializer = NoteSerializer.fromConfig(settings);
    var body = "";
    String? title;
    ISet<String> tags = ISet();
    IList<String> propsList = IList();
    NoteType type = NoteType.Unknown;

    if (extraProps.isNotEmpty) {
      var data = MdYamlDoc(props: extraProps.lock);
      var newNote = noteSerializer.decode(
        data: data,
        file: file,
        parent: parent,
        fileFormat: fileFormat,
      );

      body = newNote._body;
      created = newNote._created;
      modified = newNote._modified;
      title = newNote._title;
      tags = newNote._tags;
      type = newNote._type;

      propsList = data.props.keys.toIList();
    }

    // FIXME: Ensure this fileName doesn't exist
    var filePath = buildFilePath(
      parent: parent,
      fileFormat: fileFormat,
      created: created ?? DateTime.now(),
      type: type,
      fileName: fileName,
      title: title,
    );

    file = file.copyFile(filePath: filePath);
    // assert(p.dirname(fullFilePath) == parent.fullFolderPath);
    assert(title != null ? title.isNotEmpty : true);

    return Note.build(
      parent: parent,
      file: file,
      title: title,
      body: body,
      noteType: type,
      tags: tags,
      extraProps: extraProps,
      fileFormat: fileFormat,
      propsList: propsList,
      serializerSettings: settings,
      modified: modified,
      created: created,
    );
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
    Log.i("title: " + (title ?? "null"));

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
      case NoteFileNameFormat.KebabCase:
      case NoteFileNameFormat.Template:
        return buildTemplateFileName(
          isJournal ? parent.journalFileNameTemplate : parent.fileNameTemplate,
          date,
          parent.fullFolderPath,
          title,
          ext,
        );
    }

    return date.toString();
  }

  Note copyWithFileName(fileName) {
    var fileFormat = this.fileFormat;
    var file = this.file;

    if (fileName != this.fileName) {
      var filePath = p.join(p.dirname(this.filePath), fileName);
      if (filePath.startsWith('./')) {
        filePath = filePath.substring(2);
      }
      file = this.file.copyFile(filePath: filePath);
      fileFormat = NoteFileFormatInfo.fromFilePath(filePath);
    }

    return Note.build(
      body: body,
      parent: parent,
      propsList: _propsList,
      file: file,
      created: created,
      modified: modified,
      title: title,
      noteType: type,
      extraProps: extraProps,
      tags: tags,
      fileFormat: fileFormat,
      serializerSettings: noteSerializer.settings.clone(),
    );
  }

  Note resetOid() => copyWith(file: file.copyFile(oid: GitHash.zero()));

  Note copyWith({
    NotesFolderFS? parent,
    String? filePath,
    DateTime? created,
    DateTime? modified,
    String? body,
    String? title,
    NoteType? type,
    Map<String, dynamic>? extraProps,
    ISet<String>? tags,
    NoteFileFormat? fileFormat,
    File? file,
  }) {
    if (filePath != null && filePath.startsWith('./')) {
      filePath = filePath.substring(2);
    }

    return Note.build(
      body: body ?? this.body,
      parent: parent ?? this.parent,
      propsList: _propsList,
      file: file ?? this.file.copyFile(filePath: filePath),
      created: created ?? _created,
      modified: modified ?? _modified,
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

  Note updateModified() => copyWith(modified: DateTime.now());

  bool get shouldRebuildPath {
    if (fileFormat != NoteFileFormat.Markdown) return false;

    return parent.config.fileNameFormat.usesTitle;
  }

  String get body => _body;
  String? get title {
    assert(_title != null ? _title.isNotEmpty : true);
    return _title;
  }

  NoteType get type => _type;
  ISet<String> get tags => _tags;
  Map<String, dynamic> get extraProps => UnmodifiableMapView(_extraProps);
  IList<String> get propsList => _propsList;

  bool get canHaveMetadata {
    if (_fileFormat == NoteFileFormat.Txt ||
        _fileFormat == NoteFileFormat.OrgMode) {
      return false;
    }
    return parent.config.yamlHeaderEnabled;
  }

  MdYamlDoc get data => noteSerializer.encode(this);

  bool get pinned => extraProps["pinned"] == true;

  @override
  int get hashCode => file.hashCode ^ _body.hashCode;

  static final _mapEq = const MapEquality().equals;

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
          _tags == other._tags &&
          _mapEq(_extraProps, other._extraProps) &&
          _fileFormat == other._fileFormat &&
          noteSerializer.settings == other.noteSerializer.settings &&
          file.oid == other.file.oid &&
          file.filePath == other.file.filePath;

  // FIXME: operator== should compare the full file?

  @override
  String toString() {
    var pb = toProtoBuf().toProto3Json().toString();
    return 'Note{filePath: ${file.filePath}, pb: $pb}';
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
  pb.Note toProtoBuf() {
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
      propsList: _propsList,
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
      tags: ISet(n.tags),
      extraProps: mapFromProtoBuf(n.extraProps),
      fileFormat: _formatFromProto(n.fileFormat),
      propsList: n.propsList.lock,
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
    var fileName = "${name}_$i$ext";
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

String buildKebabTitleFileName(String parentDir, String title, String ext) {
  // Sanitize the title - these characters are not allowed in Windows
  title = title.replaceAll(RegExp(r'[/<\>":|?*]'), '-');

  return ensureFileNameUnique(parentDir, title.camelCase, ext);
}

String buildTemplateFileName(
  String template,
  DateTime date,
  String parentDir,
  String? title,
  String ext,
) {
  // Sanitize the title - these characters are not allowed in Windows
  title = FileNameTemplate.parse(
    template,
  )
      .render(date: date, uuidv4: const Uuid().v4, title: title)
      .replaceAll(RegExp(r'[/<\>":|?*]'), '_');

  return ensureFileNameUnique(parentDir, title, ext);
}
