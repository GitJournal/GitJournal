/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:supabase_flutter/src/local_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://api.gitjournal.io',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpYXQiOiAxNjM2MzI2MDAwLAogICAgImV4cCI6IDE3OTQwOTI0MDAKfQ.7t9lpqjJj8E4Xbvn6NvjjDNk316_ETcgf5zYCnKN-iA',
    authCallbackUrlHostname: 'register-callback',
    localStorage: const _HiveLocalStorage(),
  );
}

const _hiveBoxName = 'supabase_authentication';

// Mostly copied from supabase's LocalStorage, the only difference is that
// Hive is not initializled, as it has already been in the app.dart file
// and we don't want to store the files in the Documents directory as that
// results in it being stored in ~/Documents in linux

/// A [LocalStorage] implementation that implements Hive as the
/// storage method.
class _HiveLocalStorage extends LocalStorage {
  /// Creates a LocalStorage instance that implements the Hive Database
  const _HiveLocalStorage()
      : super(
          initialize: _initialize,
          hasAccessToken: _hasAccessToken,
          accessToken: _accessToken,
          removePersistedSession: _removePersistedSession,
          persistSession: _persistSession,
        );

  /// The encryption key used by Hive. If null, the box is not encrypted
  ///
  /// This value should not be redefined in runtime, otherwise the user may
  /// not be fetched correctly
  ///
  /// See also:
  ///
  ///   * <https://docs.hivedb.dev/#/advanced/encrypted_box?id=encrypted-box>
  static String? encryptionKey;

  static Future<void> _initialize() async {
    HiveCipher? encryptionCipher;
    if (encryptionKey != null) {
      encryptionCipher = HiveAesCipher(base64Url.decode(encryptionKey!));
    }
    // await Hive.initFlutter('auth');
    await Hive.openBox(_hiveBoxName, encryptionCipher: encryptionCipher);
  }

  static Future<bool> _hasAccessToken() {
    return Future.value(
        Hive.box(_hiveBoxName).containsKey(supabasePersistSessionKey));
  }

  static Future<String?> _accessToken() {
    return Future.value(
        Hive.box(_hiveBoxName).get(supabasePersistSessionKey) as String?);
  }

  static Future<void> _removePersistedSession() {
    return Hive.box(_hiveBoxName).delete(supabasePersistSessionKey);
  }

  static Future<void> _persistSession(String persistSessionString) {
    return Hive.box(_hiveBoxName)
        .put(supabasePersistSessionKey, persistSessionString);
  }
}
