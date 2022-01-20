/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:collection';

import 'package:dart_git/utils/result.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';
import 'package:synchronized/synchronized.dart';
import 'package:universal_io/io.dart' as io;

import 'package:gitjournal/core/file/file_storage.dart';
import 'package:gitjournal/core/file/unopened_files.dart';
import 'package:gitjournal/core/note_storage.dart';
import 'package:gitjournal/core/views/inline_tags_view.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/logger/logger.dart';
import '../file/file.dart';
import '../file/ignored_file.dart';
import '../note.dart';
import 'notes_folder.dart';
import 'notes_folder_notifier.dart';

class NotesFolderFS with NotesFolderNotifier implements NotesFolder {
  final NotesFolderFS? _parent;
  String _folderPath;
  final _lock = Lock();

  var _files = <File>[];
  var _folders = <NotesFolderFS>[];
  var _entityMap = <String, dynamic>{};

  final NotesFolderConfig _config;
  late final FileStorage fileStorage;

  NotesFolderFS(
      NotesFolderFS parent, this._folderPath, this._config, this.fileStorage)
      : _parent = parent {
    assert(!_folderPath.startsWith(p.separator));
    assert(!_folderPath.endsWith(p.separator));
    assert(_folderPath.isNotEmpty);
  }

  NotesFolderFS.root(this._config, this.fileStorage)
      : _parent = null,
        _folderPath = "";

  @override
  void dispose() {
    for (var f in _folders) {
      f.removeListener(_entityChanged);
    }

    super.dispose();
  }

  @override
  NotesFolder? get parent => _parent;

  /// Always ends with a '/'
  String get repoPath => fileStorage.repoPath;

  NotesFolderFS? get parentFS => _parent;

  void _entityChanged() {
    notifyListeners();
  }

  void _noteRenamed(Note note, String oldPath) {
    assert(!oldPath.startsWith(p.separator));

    _lock.synchronized(() {
      assert(_entityMap.containsKey(oldPath));
      var _ = _entityMap.remove(oldPath);
      _entityMap[note.filePath] = note;

      notifyNoteRenamed(-1, note, oldPath);
    });
  }

  void _subFolderRenamed(NotesFolderFS folder, String oldPath) {
    assert(!oldPath.startsWith(p.separator));

    _lock.synchronized(() {
      assert(_entityMap.containsKey(oldPath));
      var _ = _entityMap.remove(oldPath);
      _entityMap[folder.folderPath] = folder;
    });
  }

  /// Will never end with '/'
  String get folderPath => _folderPath;
  String get folderName => p.basename(_folderPath);

  /// Will never end with '/'
  String get fullFolderPath {
    if (_folderPath.isEmpty) {
      return repoPath.substring(0, repoPath.length - 1);
    }
    return p.join(repoPath, _folderPath);
  }

  @override
  bool get isEmpty {
    return !hasNotes && _folders.isEmpty;
  }

  @override
  String get name => basename(folderPath);

  bool get hasSubFolders {
    return _folders.isNotEmpty;
  }

  @override
  bool get hasNotes {
    return _files.indexWhere((n) => n is Note) != -1;
  }

  bool get hasNotesRecursive {
    if (hasNotes) {
      return true;
    }

    for (var folder in _folders) {
      if (folder.hasNotesRecursive) {
        return true;
      }
    }
    return false;
  }

  int get numberOfNotes {
    return notes.length;
  }

  @override
  List<Note> get notes {
    return _files.whereType<Note>().toList();
  }

  @override
  List<NotesFolder> get subFolders => subFoldersFS;

  List<IgnoredFile> get ignoredFiles =>
      _files.whereType<IgnoredFile>().toList();

  List<NotesFolderFS> get subFoldersFS {
    // FIXME: This is really not ideal
    _folders.sort((NotesFolderFS a, NotesFolderFS b) =>
        a.folderPath.compareTo(b.folderPath));
    return _folders;
  }

  Future<void> loadNotes() async {
    const maxParallel = 10;
    var futures = <Future>[];

    var storage = NoteStorage();
    for (var i = 0; i < _files.length; i++) {
      late Future future;

      var file = _files[i];
      if (file is UnopenedFile) {
        future = (int index, UnopenedFile file) async {
          var result = await storage.load(file, file.parent);
          if (result.isFailure) {
            var reason = IgnoreReason.Custom;
            var reasonError = result.error;
            if (result.error!
                .toString()
                .toLowerCase()
                .contains("failed to decode data using encoding 'utf-8'")) {
              // FIXME: There has got to be an easier way
              reason = IgnoreReason.InvalidEncoding;
            }

            _files[index] = IgnoredFile(
              file: file,
              reason: reason,
              customError: reasonError,
            );
            _entityMap[file.filePath] = _files[index];
            return;
          }

          var note = result.getOrThrow();
          _files[index] = note;
          _entityMap[file.filePath] = note;

          notifyNoteAdded(index, note);
        }(i, file);
      } else if (file is Note) {
        future = (int index, Note note) async {
          var result = await storage.reload(note);
          if (result.isFailure) {
            if (result.error is NoteReloadNotRequired) {
              return;
            }
            _files[index] = IgnoredFile(
              file: file,
              reason: IgnoreReason.Custom,
            );
            _entityMap[file.filePath] = _files[index];
            return;
          }

          note = result.getOrThrow();
          _files[index] = note;
          _entityMap[file.filePath] = _files[index];

          notifyNoteModified(index, note);
        }(i, file);
      } else {
        continue;
      }

      // FIXME: Collected all the Errors, and report them back, along with "WHY", and the contents of the Note
      //        Each of these needs to be reported to sentry, as Note loading should never fail
      futures.add(future);

      if (futures.length >= maxParallel) {
        var _ = await Future.wait(futures);
        futures = <Future>[];
      }
    }

    var _ = await Future.wait(futures);
  }

  Future<Result<void>> loadRecursively() async {
    var r = await load();
    if (r.isFailure) return r;

    await loadNotes();

    var futures = <Future>[];
    for (var folder in _folders) {
      var f = folder.loadRecursively();
      futures.add(f);
    }

    var _ = await Future.wait(futures);
    return Result(null);
  }

  Future<Result<void>> load() => _lock.synchronized(_load);

  Future<Result<void>> _load() async {
    var ignoreFilePath = p.join(fullFolderPath, ".gjignore");
    if (io.File(ignoreFilePath).existsSync()) {
      Log.i("Ignoring $folderPath as it has .gjignore");
      return Result(null);
    }

    var newEntityMap = <String, dynamic>{};
    var newFiles = <File>[];
    var newFolders = <NotesFolderFS>[];

    final dir = io.Directory(fullFolderPath);
    var lister = dir.list(recursive: false, followLinks: false);
    await for (var fsEntity in lister) {
      if (fsEntity is io.Link) {
        continue;
      }

      assert(fsEntity.path.startsWith(p.separator));
      var filePath = fsEntity.path.substring(repoPath.length);

      if (fsEntity is io.Directory) {
        var subFolder = NotesFolderFS(this, filePath, _config, fileStorage);
        if (subFolder.name.startsWith('.')) {
          // Log.v("Ignoring Folder", props: {
          //   "path": filePath,
          //   "reason": "Hidden folder",
          // });
          continue;
        }
        // Log.v("Found Folder", props: {"path": filePath});

        newFolders.add(subFolder);
        newEntityMap[filePath] = subFolder;
        continue;
      }

      assert(fsEntity is io.File);

      var fileR = await fileStorage.load(filePath);
      if (fileR.isFailure) {
        Log.e("NotesFolderFS FileStorage Failure", result: fileR);
        if (fileR.error is FileStorageCacheIncomplete) {
          return fileR;
        }
        assert(fileR.isFailure == false);
        continue;
      }
      var file = fileR.getOrThrow();

      var fileName = p.basename(filePath);
      if (fileName.startsWith('.')) {
        var ignoredFile = IgnoredFile(
          file: file,
          reason: IgnoreReason.HiddenFile,
        );

        newFiles.add(ignoredFile);
        newEntityMap[filePath] = ignoredFile;
        continue;
      }

      var formatInfo = NoteFileFormatInfo(config);
      if (!formatInfo.isAllowedFileName(filePath)) {
        var ignoredFile = IgnoredFile(
          file: file,
          reason: IgnoreReason.InvalidExtension,
        );

        newFiles.add(ignoredFile);
        newEntityMap[filePath] = ignoredFile;
        continue;
      }

      // Log.v("Found file", props: {"path": filePath});
      var fileToBeProcessed = UnopenedFile(
        file: file,
        parent: this,
      );

      newFiles.add(fileToBeProcessed);
      newEntityMap[filePath] = fileToBeProcessed;
    }

    var originalPathsList = _entityMap.keys.toSet();
    var newPathsList = newEntityMap.keys.toSet();

    var origEntityMap = _entityMap;
    _entityMap = newEntityMap;
    _files = newFiles;
    _folders = newFolders;

    var pathsRemoved = originalPathsList.difference(newPathsList);
    for (var path in pathsRemoved) {
      var e = origEntityMap[path];
      assert(e is NotesFolder || e is File);

      if (e is File) {
        if (e is Note) {
          notifyNoteRemoved(-1, e);
        }
      } else {
        _removeFolderListeners(e);
        notifyFolderRemoved(-1, e);
      }
    }

    var pathsAdded = newPathsList.difference(originalPathsList);
    for (var path in pathsAdded) {
      var e = _entityMap[path];
      assert(e is NotesFolder || e is File);

      if (e is File) {
        assert(e is! Note);
      } else {
        _addFolderListeners(e);
        notifyFolderAdded(-1, e);
      }
    }

    var pathsPossiblyChanged = newPathsList.intersection(originalPathsList);
    for (var i = 0; i < _files.length; i++) {
      var filePath = _files[i].filePath;
      if (!pathsPossiblyChanged.contains(filePath)) {
        continue;
      }

      var ent = origEntityMap[filePath];
      assert(ent is File);

      if (ent is Note) {
        _files[i] = ent;
        _entityMap[ent.filePath] = ent;
      }
    }

    for (var i = 0; i < _folders.length; i++) {
      var folderPath = _folders[i].folderPath;
      if (!pathsPossiblyChanged.contains(folderPath)) {
        continue;
      }

      var ent = origEntityMap[folderPath];
      assert(ent is NotesFolderFS);
      if (ent is NotesFolderFS) {
        _folders[i] = ent;
        _entityMap[ent.folderPath] = ent;
      }
    }

    return Result(null);
  }

  void add(Note note) {
    assert(note.parent == this);

    _files.add(note);
    _entityMap[note.filePath] = note;

    notifyNoteAdded(-1, note);
  }

  void remove(Note note) {
    assert(note.parent == this);
    _removeFile(note);
  }

  void _removeFile(File f) {
    assert(_files.indexWhere((n) => n.filePath == f.filePath) != -1);
    assert(_entityMap.containsKey(f.filePath));

    var index = _files.indexWhere((n) => n.filePath == f.filePath);

    dynamic _;
    _ = _files.removeAt(index);
    _ = _entityMap.remove(f.filePath);

    if (f is Note) {
      notifyNoteRemoved(index, f);
    }
  }

  void create() {
    // Git doesn't track Directories, only files, so we create an empty .gitignore file
    // in the directory instead.
    var gitIgnoreFilePath = p.join(fullFolderPath, ".gitignore");
    var file = io.File(gitIgnoreFilePath);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    notifyListeners();
  }

  void addFolder(NotesFolderFS folder) {
    assert(folder.parent == this);
    _addFolderListeners(folder);

    _folders.add(folder);
    _entityMap[folder.folderPath] = folder;

    notifyFolderAdded(_folders.length - 1, folder);
  }

  void removeFolder(NotesFolderFS folder) {
    var filesCopy = List<File>.from(folder._files);
    filesCopy.forEach(folder._removeFile);

    var foldersCopy = List<NotesFolderFS>.from(folder._folders);
    foldersCopy.forEach(folder.removeFolder);

    _removeFolderListeners(folder);

    assert(_folders.indexWhere((f) => f.folderPath == folder.folderPath) != -1);
    assert(_entityMap.containsKey(folder.folderPath));

    var index = _folders.indexWhere((f) => f.folderPath == folder.folderPath);
    assert(index != -1);
    dynamic _;
    _ = _folders.removeAt(index);
    _ = _entityMap.remove(folder.folderPath);

    notifyFolderRemoved(index, folder);
  }

  void rename(String newName) {
    if (parent == null) {
      throw Exception("Cannot rename root directory");
    }

    var oldPath = folderPath;
    var dir = io.Directory(fullFolderPath);
    _folderPath = p.join(dirname(oldPath), newName);
    assert(!_folderPath.endsWith(p.separator));

    if (io.Directory(fullFolderPath).existsSync()) {
      throw Exception("Directory already exists");
    }
    var _ = dir.renameSync(fullFolderPath);

    notifyThisFolderRenamed(this, oldPath);
  }

  void updateNote(Note note) {
    var i = _files.indexWhere((e) => e.filePath == note.filePath);
    _files[i] = note;
    _entityMap[note.filePath] = note;

    notifyNoteModified(i, note);
  }

  void _addFolderListeners(NotesFolderFS folder) {
    folder.addListener(_entityChanged);
    folder.addThisFolderRenamedListener(_subFolderRenamed);
  }

  void _removeFolderListeners(NotesFolderFS folder) {
    folder.removeListener(_entityChanged);
    folder.removeThisFolderRenamedListener(_subFolderRenamed);
  }

  @override
  String get publicName {
    var spec = folderPath;
    if (spec.isEmpty) {
      return tr(LocaleKeys.rootFolder);
    }
    return spec;
  }

  Iterable<Note> getAllNotes() sync* {
    for (var f in _files) {
      if (f is Note) {
        yield f;
      }
    }

    for (var folder in _folders) {
      var notes = folder.getAllNotes();
      for (var note in notes) {
        yield note;
      }
    }
  }

  @override
  NotesFolder get fsFolder {
    return this;
  }

  NotesFolderFS? getFolderWithSpec(String spec) {
    if (folderPath == spec) {
      return this;
    }
    for (var f in _folders) {
      var res = f.getFolderWithSpec(spec);
      if (res != null) {
        return res;
      }
    }

    return null;
  }

  NotesFolderFS getOrBuildFolderWithSpec(String spec) {
    assert(!spec.startsWith(p.separator));
    if (spec == '.') {
      return this;
    }

    var components = spec.split(p.separator);
    var folder = this;
    for (var i = 0; i < components.length; i++) {
      var c = components.sublist(0, i + 1);
      var folderPath = c.join(p.separator);

      var folders = folder.subFoldersFS;
      var folderIndex = folders.indexWhere((f) => f.folderPath == folderPath);
      if (folderIndex != -1) {
        folder = folders[folderIndex];
        continue;
      }

      var subFolder = NotesFolderFS(folder, folderPath, _config, fileStorage);
      folder.addFolder(subFolder);
      folder = subFolder;
    }

    return folder;
  }

  NotesFolderFS get rootFolder {
    var folder = this;
    while (folder.parent != null) {
      folder = folder.parent as NotesFolderFS;
    }
    return folder;
  }

  Note? getNoteWithSpec(String spec) {
    // FIXME: Once each note is stored with the spec as the path, this becomes
    //        so much easier!
    var parts = spec.split(p.separator);

    var folder = this;
    while (parts.length != 1) {
      var folderName = parts[0];

      bool foundFolder = false;
      for (var f in _folders) {
        if (f.name == folderName) {
          folder = f;
          foundFolder = true;
          break;
        }
      }

      if (!foundFolder) {
        return null;
      }
      var _ = parts.removeAt(0);
    }

    var fileName = parts[0];
    for (var note in folder.notes) {
      if (note.fileName == fileName) {
        return note;
      }
    }

    return null;
  }

  @override
  NotesFolderConfig get config => _config;

  Future<SplayTreeSet<String>> getNoteTagsRecursively(
    InlineTagsView inlineTagsView,
  ) async {
    return _fetchTags(this, inlineTagsView, SplayTreeSet<String>());
  }

  Future<List<Note>> matchNotes(NoteMatcherAsync pred) async {
    var matchedNotes = <Note>[];
    await _matchNotes(matchedNotes, pred);
    return matchedNotes;
  }

  Future<void> _matchNotes(
    List<Note> matchedNotes,
    NoteMatcherAsync pred,
  ) async {
    for (var file in _files) {
      if (file is! Note) {
        continue;
      }
      var note = file;
      var matches = await pred(note);
      if (matches) {
        matchedNotes.add(note);
      }
    }

    for (var folder in _folders) {
      var _ = await folder._matchNotes(matchedNotes, pred);
    }
  }

  ///
  /// Do not let the user rename it to a different file-type.
  ///
  Note renameNote(Note note, String newName) {
    assert(!newName.contains(p.separator));

    var oldFilePath = note.filePath;
    var parentDirName = p.dirname(oldFilePath);
    var newFilePath = p.join(parentDirName, newName);

    assert(_files.contains(note));
    var _ = io.File(oldFilePath).renameSync(newFilePath);

    assert(!newFilePath.startsWith(p.separator));
    var newFormat = NoteFileFormatInfo.fromFilePath(newFilePath);

    note = note.copyWith(filePath: newFilePath, fileFormat: newFormat);
    assert(note.fileName == newName);

    _noteRenamed(note, oldFilePath);
    notifyNoteModified(-1, note);
    return note;
  }

  static Note? moveNote(Note note, NotesFolderFS destFolder) {
    var destPath = p.join(destFolder.fullFolderPath, note.fileName);
    if (io.File(destPath).existsSync()) {
      // FIXME: Shouldn't this give an error?
      return null;
    }

    var _ = io.File(note.fullFilePath).renameSync(destPath);

    note.parent.remove(note);
    note = note.copyWith(parent: destFolder);
    note.parent.add(note);

    return note;
  }

  void visit(void Function(File) visitor) {
    for (var f in _files) {
      visitor(f);
    }

    for (var folder in _folders) {
      folder.visit(visitor);
    }
  }
}

typedef NoteMatcherAsync = Future<bool> Function(Note n);

Future<SplayTreeSet<String>> _fetchTags(
  NotesFolder folder,
  InlineTagsView inlineTagsView,
  SplayTreeSet<String> tags,
) async {
  for (var note in folder.notes) {
    tags.addAll(note.tags);
    tags.addAll(await inlineTagsView.fetch(note));
  }

  for (var folder in folder.subFolders) {
    tags = await _fetchTags(folder, inlineTagsView, tags);
  }

  return tags;
}
