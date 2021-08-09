import 'package:dart_git/plumbing/git_hash.dart';

class File {
  final GitHash oid;
  final GitHash commitHash;
  final String filePath;

  final DateTime modified;
  final DateTime created;

  // Maybe attach the entire GitFileIndex?
  final DateTime? fileLastModified;

  File({
    required this.oid,
    required this.commitHash,
    required this.filePath,
    required this.modified,
    required this.created,
    this.fileLastModified,
  });
}
