/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 * SPDX-FileCopyrightText: 2020-2021 Alen Šiljak <gitjournal@alensiljak.eu.org>
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:org_flutter/org_flutter.dart';
import 'package:path/path.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/folder_views/common.dart';
import 'package:gitjournal/generated/locale_keys.g.dart';
import 'package:gitjournal/logger/logger.dart';
import 'package:gitjournal/utils/link_resolver.dart';
import 'package:gitjournal/utils/utils.dart';
import 'package:gitjournal/widgets/images/image_details.dart';
import 'package:gitjournal/widgets/images/themable_image.dart';

//import 'dart:html';

/// Handles links from .org documents.
class OrgLinkHandler {
  BuildContext context;
  Note note;
  //String notePath;

  OrgLinkHandler(this.context, this.note) : super();

  Future<void> launchUrl(String link) async {
    // handle =file:= prefix
    if (link.startsWith('file:')) {
      link = link.replaceFirst('file:', '');
    }

    // Images
    if (looksLikeImagePath(link)) {
      if (looksLikeUrl(link)) {
        // Remote images
        if (await canLaunch(link)) {
          var _ = await launch(link);
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
          var _ = await launch(link);
        } else {
          Log.w('could not launch $link');
          //Log.e('Opening Link', ex: e, stacktrace: stackTrace);
          showSnackbar(
            context,
            tr(LocaleKeys.widgets_NoteViewer_linkInvalid, args: [link]),
          );
        }
      } else {
        _openLocalLink(link);
      }
    }
  }

  void _showImage(File file) {
    ThemableImage im = ThemableImage.image(file);

    var _ = Navigator.push(
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
