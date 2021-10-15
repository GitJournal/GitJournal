/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart';

import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/core/transformers/base.dart';

class Image {
  final NotesFolderFS parent;
  final String filePath;
  final Digest md5Hash;

  static Future<Image> load(NotesFolderFS parent, String filePath) async {
    return Image._(parent, filePath, await _md5Hash(filePath));
  }

  Image._(this.parent, this.filePath, this.md5Hash);

  static Future<Image> copyIntoFs(NotesFolderFS parent, String filePath) async {
    var hash = await _md5Hash(filePath);
    var ext = p.extension(filePath);
    var absImagePath = Image._buildImagePath(parent, hash.toString() + ext);

    // FIXME: Handle errors in copying / reading the file
    var _ = await File(filePath).copy(absImagePath);

    return Image._(parent, absImagePath, hash);
  }

  static String _buildImagePath(NotesFolderFS parent, String imageFileName) {
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

    return p.join(baseFolder, imageFileName);
  }

  String toMarkup(NoteFileFormat? fileFormat) {
    var relativeImagePath = p.relative(filePath, from: parent.folderPath);
    if (!relativeImagePath.startsWith('.')) {
      relativeImagePath = './$relativeImagePath';
    }

    if (fileFormat == NoteFileFormat.OrgMode) {
      return "[[$relativeImagePath]]\n";
    }

    return "![Image]($relativeImagePath)\n";
  }
}

Future<Digest> _md5Hash(String filePath) async {
  var output = AccumulatorSink<Digest>();
  var input = md5.startChunkedConversion(output);

  var readStream = File(filePath).openRead();
  await for (var data in readStream) {
    input.add(data);
  }
  input.close();

  var digest = output.events.single;
  return digest;
}

//
// TextDocument
// OrgDocument
// MarkdownDocument
// MarkdownYamlDocument
//
// The last 2 share common settings
// All inherit from File
//
// Folder class
// -> just list a Files
// -> another list of Folders
//   That's it
// I can always filter by type
//
// When NoteEditor is called, it should create a new document and copy the parameters
//
