/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:math';

import 'package:gitjournal/editors/common.dart';

// FIXME: Possibly conserve memory by only storing the difference between the
//        texts? Or by saving it to disk?

// FIXME: This should probably also have what field was changed?
//        How does this work for the title and the checklist editor?

// FIXME: Instead of storing if each note has been modified that should be
//        be just taken from this class
//
class UndoRedoStack {
  final _versions = <TextEditorState>[];
  int _index = -1;

  /// Returns if UI should be redrawn
  bool textChanged(TextEditorState es) {
    var _redo = redoPossible;
    var _undo = undoPossible;
    if (_redo) {
      var i = max(0, _index);
      _versions.removeRange(i, _versions.length - 1);
    }
    if (_versions.isEmpty) {
      _versions.add(es);
      _index = _versions.length - 1;
      return true;
    }
    var last = _versions.last;
    if (last.text == es.text) {
      return false;
    }
    _versions.add(es);
    _index = _versions.length - 1;

    return redoPossible != _redo || undoPossible != _undo;
  }

  TextEditorState undo() {
    var i = _index;
    _index--;
    return _versions[i];
  }

  TextEditorState redo() {
    _index++;
    return _versions[_index];
  }

  bool get undoPossible => _index >= 0;
  bool get redoPossible => _index < _versions.length - 1;
  bool get modified => _versions.isNotEmpty;
}

// FIXME: Only save it every x seconds?
