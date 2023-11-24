/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:gitjournal/core/folder/notes_folder_fs.dart';
import 'package:gitjournal/editors/common.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart';

import 'notes/note.dart';

class Image {
  final NotesFolderFS parent;
  final String filePath;

  Image._(this.parent, this.filePath);

  static Future<Image> copyIntoFs(NotesFolderFS parent, String filePath) async {
    var hash = await _md5Hash(filePath);
    var ext = p.extension(filePath);
    var imagePath = Image._buildImagePath(parent, hash.toString() + ext);

    await File(filePath).copy(p.join(parent.repoPath, imagePath));
    return Image._(parent, imagePath);
  }

  static String _buildImagePath(NotesFolderFS parent, String imageFileName) {
    String folderPath;

    var imageSpec = parent.config.imageLocationSpec;
    if (imageSpec == '.') {
      folderPath = parent.folderPath;
    } else {
      var folder = parent.rootFolder.getFolderWithSpec(imageSpec);
      if (folder != null) {
        folderPath = folder.folderPath;
      } else {
        folderPath = parent.folderPath;
      }
    }

    return p.join(folderPath, imageFileName);
  }

  String toMarkup(NoteFileFormat? fileFormat) {
    var relativeImagePath = p.relative(filePath, from: parent.folderPath);
    if (!relativeImagePath.startsWith('.')) {
      relativeImagePath = './$relativeImagePath';
    }

    if (fileFormat == NoteFileFormat.OrgMode) {
      return "[[$relativeImagePath]] ";
    }

    return "![Image]($relativeImagePath) ";
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

TextEditorState insertImage(
  TextEditorState ts,
  Image image,
  NoteFileFormat fileFormat,
) {
  var b = ts.text;
  var markup = image.toMarkup(fileFormat);

  if (ts.cursorPos > ts.text.length) {
    ts.cursorPos = ts.text.length;
  }
  var prevChar =
      ts.text.isEmpty || ts.cursorPos == 0 ? " " : ts.text[ts.cursorPos - 1];
  if (prevChar.contains(RegExp(r'[\S]'))) {
    markup = ' $markup';
  }

  if (ts.cursorPos < b.length) {
    b = b.substring(0, ts.cursorPos) + markup + b.substring(ts.cursorPos);
  } else {
    b += markup;
  }

  return TextEditorState(b, ts.cursorPos + markup.length);
}
