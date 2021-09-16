/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart';

import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/core/transformers/base.dart';

class Image {
  NotesFolderFS parent;
  String filePath;

  Image(this.parent, this.filePath);

  static Future<Image> copyIntoFs(NotesFolderFS parent, String filePath) async {
    var file = File(filePath);
    var image = Image(parent, file.path);

    var absImagePath = Image._buildImagePath(parent, file.path);
    await file.copy(absImagePath);

    return image;
  }

  static String _buildImagePath(NotesFolderFS parent, String filePath) {
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

    var imageFileName = p.basename(filePath);
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
