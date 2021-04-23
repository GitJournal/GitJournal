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
import 'dart:io';

import 'package:org_flutter/org_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Handles links from .org documents.
class OrgLinkHandler {
  String notePath;

  OrgLinkHandler(this.notePath) : super();

  void launchUrl(String link) async {
    // handle =file:= prefix
    if (link.startsWith('file:')) {
      link = link.replaceFirst('file:', '');
    }

    if (looksLikeImagePath(link)) {
      // Images
      if (looksLikeUrl(link)) {
        // Remote images
        if (await canLaunch(link)) {
          await launch(link);
        } else {
          //throw 'Could not launch $link';
          log('could not launch $link');
        }
      } else {
        // (presumably-)Local images
        File file = File(link);

        if (file.isAbsolute) {
          // 3. absolute path
          log('image with absolute path');
        } else {
          //log('file exists? ' + file.exists().toString());

          // 1. name-only
          // 2. relative path
          log('image ' + file.path);
        }
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
          //throw 'Could not launch $link';
          log('could not launch $link');
        }
      } else {
        // Local file link.
        File file = File(link);
        // 1. Only name: Try to find the note with the same name, with or
        //    without the extension.
        // 2. Relative path: Open the path, if exists.
        //    Check if supported extension.
        // 3. Absolute path: Open if within the repo path?
        log('note path: ' + notePath);
        log('local: ' + file.path);
      }
    }
  }
}
