/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../note.dart';
import 'notes_folder.dart';
import 'notes_folder_fs.dart';

typedef FolderNotificationCallback = void Function(
    int index, NotesFolder folder);
typedef FolderRenamedCallback = void Function(
    NotesFolderFS folder, String oldPath);
typedef NoteNotificationCallback = void Function(int index, Note note);
typedef NoteRenamedCallback = void Function(
    int index, Note note, String oldPath);

class NotesFolderNotifier implements ChangeNotifier {
  ObserverList<void Function(int, NotesFolder)>? _folderAddedListeners =
      ObserverList<FolderNotificationCallback>();
  ObserverList<void Function(int, NotesFolder)>? _folderRemovedListeners =
      ObserverList<FolderNotificationCallback>();
  ObserverList<void Function(NotesFolderFS, String)>?
      _thisFolderRenamedListeners = ObserverList<FolderRenamedCallback>();

  ObserverList<void Function(int, Note)>? _noteAddedListeners =
      ObserverList<NoteNotificationCallback>();
  ObserverList<void Function(int, Note)>? _noteRemovedListeners =
      ObserverList<NoteNotificationCallback>();
  ObserverList<void Function(int, Note)>? _noteModifiedListeners =
      ObserverList<NoteNotificationCallback>();
  ObserverList<void Function(int, Note, String)>? _noteRenameListeners =
      ObserverList<NoteRenamedCallback>();

  void addFolderRemovedListener(FolderNotificationCallback listener) {
    if (_folderRemovedListeners != null) {
      _folderRemovedListeners!.add(listener);
    }
  }

  void removeFolderRemovedListener(FolderNotificationCallback listener) {
    if (_folderRemovedListeners != null) {
      assert(_folderRemovedListeners!.contains(listener));
      var _ = _folderRemovedListeners!.remove(listener);
    }
  }

  void addFolderAddedListener(FolderNotificationCallback listener) {
    if (_folderAddedListeners != null) {
      _folderAddedListeners!.add(listener);
    }
  }

  void removeFolderAddedListener(FolderNotificationCallback listener) {
    if (_folderAddedListeners != null) {
      assert(_folderAddedListeners!.contains(listener));
      var _ = _folderAddedListeners!.remove(listener);
    }
  }

  void addThisFolderRenamedListener(FolderRenamedCallback listener) {
    if (_thisFolderRenamedListeners != null) {
      _thisFolderRenamedListeners!.add(listener);
    }
  }

  void removeThisFolderRenamedListener(FolderRenamedCallback listener) {
    if (_thisFolderRenamedListeners != null) {
      assert(_thisFolderRenamedListeners!.contains(listener));
      var _ = _thisFolderRenamedListeners!.remove(listener);
    }
  }

  void addNoteAddedListener(NoteNotificationCallback listener) {
    if (_noteAddedListeners != null) {
      _noteAddedListeners!.add(listener);
    }
  }

  void removeNoteAddedListener(NoteNotificationCallback listener) {
    if (_noteAddedListeners != null) {
      assert(_noteAddedListeners!.contains(listener));
      var _ = _noteAddedListeners!.remove(listener);
    }
  }

  void addNoteRemovedListener(NoteNotificationCallback listener) {
    if (_noteRemovedListeners != null) {
      _noteRemovedListeners!.add(listener);
    }
  }

  void removeNoteRemovedListener(NoteNotificationCallback listener) {
    if (_noteRemovedListeners != null) {
      assert(_noteRemovedListeners!.contains(listener));
      var _ = _noteRemovedListeners!.remove(listener);
    }
  }

  void addNoteModifiedListener(NoteNotificationCallback listener) {
    if (_noteModifiedListeners != null) {
      _noteModifiedListeners!.add(listener);
    }
  }

  void removeNoteModifiedListener(NoteNotificationCallback listener) {
    if (_noteModifiedListeners != null) {
      assert(_noteModifiedListeners!.contains(listener));
      var _ = _noteModifiedListeners!.remove(listener);
    }
  }

  void addNoteRenameListener(NoteRenamedCallback listener) {
    if (_noteRenameListeners != null) {
      _noteRenameListeners!.add(listener);
    }
  }

  void removeNoteRenameListener(NoteRenamedCallback listener) {
    if (_noteRenameListeners != null) {
      assert(_noteRenameListeners!.contains(listener));
      var _ = _noteRenameListeners!.remove(listener);
    }
  }

  @mustCallSuper
  @override
  void dispose() {
    _folderAddedListeners = null;
    _folderRemovedListeners = null;
    _thisFolderRenamedListeners = null;
    _noteAddedListeners = null;
    _noteRemovedListeners = null;
    _noteModifiedListeners = null;
    _noteRenameListeners = null;

    assert(_debugAssertNotDisposed());
    _listeners = null;
  }

  void _notifyFolderCallback(
    ObserverList<FolderNotificationCallback>? _listeners,
    int index,
    NotesFolder folder,
  ) {
    if (_listeners == null) {
      return;
    }
    final localListeners = List<FolderNotificationCallback>.from(_listeners);
    for (var listener in localListeners) {
      try {
        if (_listeners.contains(listener)) {
          listener(index, folder);
        }
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'GitJournal',
          context: ErrorDescription(
              'while dispatching notifications for $runtimeType'),
          informationCollector: () sync* {
            yield DiagnosticsProperty<ChangeNotifier>(
              'The $runtimeType sending notification was',
              this,
              style: DiagnosticsTreeStyle.errorProperty,
            );
          },
        ));
      }
    }
    notifyListeners();
  }

  void notifyFolderAdded(int index, NotesFolder folder) {
    _notifyFolderCallback(_folderAddedListeners, index, folder);
  }

  void notifyFolderRemoved(int index, NotesFolder folder) {
    _notifyFolderCallback(_folderRemovedListeners, index, folder);
  }

  void notifyThisFolderRenamed(NotesFolderFS folder, String oldPath) {
    final localListeners =
        List<FolderRenamedCallback>.from(_thisFolderRenamedListeners!);
    for (var listener in localListeners) {
      try {
        if (_thisFolderRenamedListeners!.contains(listener)) {
          listener(folder, oldPath);
        }
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'GitJournal',
          context: ErrorDescription(
              'while dispatching notifications for $runtimeType'),
          informationCollector: () sync* {
            yield DiagnosticsProperty<ChangeNotifier>(
              'The $runtimeType sending notification was',
              this,
              style: DiagnosticsTreeStyle.errorProperty,
            );
          },
        ));
      }
    }
    notifyListeners();
  }

  void _notifyNoteCallback(
    ObserverList<NoteNotificationCallback>? _listeners,
    int index,
    Note note,
  ) {
    if (_listeners == null) {
      return;
    }
    final localListeners = List<NoteNotificationCallback>.from(_listeners);
    for (var listener in localListeners) {
      try {
        if (_listeners.contains(listener)) {
          listener(index, note);
        }
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'GitJournal',
          context: ErrorDescription(
              'while dispatching notifications for $runtimeType'),
          informationCollector: () sync* {
            yield DiagnosticsProperty<ChangeNotifier>(
              'The $runtimeType sending notification was',
              this,
              style: DiagnosticsTreeStyle.errorProperty,
            );
          },
        ));
      }
    }
    notifyListeners();
  }

  void notifyNoteAdded(int index, Note note) {
    _notifyNoteCallback(_noteAddedListeners, index, note);
  }

  void notifyNoteRemoved(int index, Note note) {
    _notifyNoteCallback(_noteRemovedListeners, index, note);
  }

  void notifyNoteModified(int index, Note note) {
    _notifyNoteCallback(_noteModifiedListeners, index, note);
  }

  void notifyNoteRenamed(int index, Note note, String oldPath) {
    final localListeners =
        List<NoteRenamedCallback>.from(_noteRenameListeners!);
    for (var listener in localListeners) {
      try {
        if (_noteRenameListeners!.contains(listener)) {
          listener(index, note, oldPath);
        }
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'GitJournal',
          context: ErrorDescription(
              'while dispatching notifications for $runtimeType'),
          informationCollector: () sync* {
            yield DiagnosticsProperty<ChangeNotifier>(
              'The $runtimeType sending notification was',
              this,
              style: DiagnosticsTreeStyle.errorProperty,
            );
          },
        ));
      }
    }
    notifyListeners();
  }

  //
  // ChangeNotifier implementation - How to not duplicate this?
  //
  ObserverList<VoidCallback>? _listeners = ObserverList<VoidCallback>();

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_listeners == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('A $runtimeType was used after being disposed.'),
          ErrorDescription(
              'Once you have called dispose() on a $runtimeType, it can no longer be used.')
        ]);
      }
      return true;
    }());
    return true;
  }

  /// Whether any listeners are currently registered.
  ///
  /// Clients should not depend on this value for their behavior, because having
  /// one listener's logic change when another listener happens to start or stop
  /// listening will lead to extremely hard-to-track bugs. Subclasses might use
  /// this information to determine whether to do any work when there are no
  /// listeners, however; for example, resuming a [Stream] when a listener is
  /// added and pausing it when a listener is removed.
  ///
  /// Typically this is used by overriding [addListener], checking if
  /// [hasListeners] is false before calling `super.addListener()`, and if so,
  /// starting whatever work is needed to determine when to call
  /// [notifyListeners]; and similarly, by overriding [removeListener], checking
  /// if [hasListeners] is false after calling `super.removeListener()`, and if
  /// so, stopping that same work.
  @protected
  @override
  bool get hasListeners {
    assert(_debugAssertNotDisposed());
    return _listeners!.isNotEmpty;
  }

  /// Register a closure to be called when the object changes.
  ///
  /// This method must not be called after [dispose] has been called.
  @override
  void addListener(VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    _listeners!.add(listener);
  }

  /// Remove a previously registered closure from the list of closures that are
  /// notified when the object changes.
  ///
  /// If the given listener is not registered, the call is ignored.
  ///
  /// This method must not be called after [dispose] has been called.
  ///
  /// If a listener had been added twice, and is removed once during an
  /// iteration (i.e. in response to a notification), it will still be called
  /// again. If, on the other hand, it is removed as many times as it was
  /// registered, then it will no longer be called. This odd behavior is the
  /// result of the [ChangeNotifier] not being able to determine which listener
  /// is being removed, since they are identical, and therefore conservatively
  /// still calling all the listeners when it knows that any are still
  /// registered.
  ///
  /// This surprising behavior can be unexpectedly observed when registering a
  /// listener on two separate objects which are both forwarding all
  /// registrations to a common upstream object.
  @override
  void removeListener(VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    var _ = _listeners!.remove(listener);
  }

  /// Call all the registered listeners.
  ///
  /// Call this method whenever the object changes, to notify any clients the
  /// object may have. Listeners that are added during this iteration will not
  /// be visited. Listeners that are removed during this iteration will not be
  /// visited after they are removed.
  ///
  /// Exceptions thrown by listeners will be caught and reported using
  /// [FlutterError.reportError].
  ///
  /// This method must not be called after [dispose] has been called.
  ///
  /// Surprising behavior can result when reentrantly removing a listener (i.e.
  /// in response to a notification) that has been registered multiple times.
  /// See the discussion at [removeListener].
  @protected
  @visibleForTesting
  @override
  void notifyListeners() {
    assert(_debugAssertNotDisposed());
    if (_listeners != null) {
      final List<VoidCallback> localListeners =
          List<VoidCallback>.from(_listeners!);
      for (VoidCallback listener in localListeners) {
        try {
          if (_listeners!.contains(listener)) {
            listener();
          }
        } catch (exception, stack) {
          FlutterError.reportError(FlutterErrorDetails(
            exception: exception,
            stack: stack,
            library: 'foundation library',
            context: ErrorDescription(
                'while dispatching notifications for $runtimeType'),
            informationCollector: () sync* {
              yield DiagnosticsProperty<ChangeNotifier>(
                'The $runtimeType sending notification was',
                this,
                style: DiagnosticsTreeStyle.errorProperty,
              );
            },
          ));
        }
      }
    }
  }
}
