/*
Copyright 2020-2021 Alen Šiljak <gitjournal@alensiljak.eu.org>

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

import 'dart:developer';
//import 'dart:html';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:gitjournal/folder_views/common.dart';
import 'package:gitjournal/utils/link_resolver.dart';
import 'package:gitjournal/utils/logger.dart';
import 'package:gitjournal/widgets/images/image_details.dart';
import 'package:gitjournal/widgets/images/themable_image.dart';

import 'package:org_flutter/org_flutter.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils.dart';

/// Handles links from .org documents.
class OrgLinkHandler {
  BuildContext context;
  Note note;
  //String notePath;

  OrgLinkHandler(this.context, this.note) : super();

  void launchUrl(String link) async {
    // handle =file:= prefix
    if (link.startsWith('file:')) {
      link = link.replaceFirst('file:', '');
    }

    // Images
    if (looksLikeImagePath(link)) {
      if (looksLikeUrl(link)) {
        // Remote images
        if (await canLaunch(link)) {
          await launch(link);
        } else {
          //throw 'Could not launch $link';
          log('could not launch $link');
        }
      } else {
        // Local images
        File file = File(link);

        if (file.isAbsolute) {
          // 3. absolute path
          log('image with absolute path');
        } else {
          //log('file exists? ' + file.exists().toString());

          // 1. name-only
          // 2. relative path
          //log('image ' + file.path);

          Context ctx = Context();
          String noteDir = ctx.dirname(note.filePath);
          String fullPath = ctx.join(noteDir, file.path);
          file = File(fullPath);
          // caption is the link caption
        }

        _showImage(file);
      }
    } else {
      // Other links.
      //
      if (looksLikeUrl(link)) {
        // Remote link: Open in system handler.
        log('url: ' + link);

        if (await canLaunch(link)) {
          await launch(link);
        } else {
          Log.w('could not launch $link');
          //Log.e('Opening Link', ex: e, stacktrace: stackTrace);
          showSnackbar(
            context,
            tr('widgets.NoteViewer.linkInvalid', args: [link]),
          );
        }
      } else {
        _openLocalLink(link);
      }
    }
  }

  void _showImage(File file) {
    ThemableImage im = ThemableImage.image(file);

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ImageDetails(im, "")));
    // captionText(context, altText, tooltip)
  }

  void _openLocalLink(String link) {
    // Local file link.
    //File file = File(link);

    // 1. Only name: Try to find the note with the same name, with or
    //    without the extension.
    // 2. Relative path: Open the path, if exists.
    //    Check if supported extension.
    // 3. Absolute path: Open if within the repo path?

    final linkResolver = LinkResolver(note);

    var linkedNote = linkResolver.resolve(link);
    if (linkedNote != null) {
      openNoteEditor(context, linkedNote, linkedNote.parent);
      return;
    }

    linkedNote = linkResolver.resolveWikiLink(link);
    if (linkedNote != null) {
      openNoteEditor(context, linkedNote, linkedNote.parent);
      return;
    }
  }
}
