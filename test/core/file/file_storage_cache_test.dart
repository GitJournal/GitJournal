/*
 * SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:collection/collection.dart';
import 'package:dart_git/blob_ctime_builder.dart';
import 'package:dart_git/file_mtime_builder.dart';
import 'package:dart_git/git.dart';
import 'package:dart_git/utils/date_time.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart' as io;

import 'package:gitjournal/core/file/file.dart';
import 'package:gitjournal/core/file/file_storage.dart';
import 'package:gitjournal/core/file/file_storage_cache.dart';

void main() {
  test('Cache', () async {
    var commits = {
      GitHash("9a54971363328d210043eb0bea337e5742816194"),
      GitHash("b6cff32f9eac2a2b3f0c5f9b9e2f9e2301373a81"),
      GitHash("c819448676edc29f92056038de5ebc406e7a811c"),
    };

    var trees = {
      GitHash("1e6df0fe5169ab7e3eb2412845c0d0f2ae2330df"),
      GitHash("8664e404699fc62914d3d783a8aea904e8606c1d"),
      GitHash("c8557b0a89fdb925b5cac6e7f3a0cb0e7c14c923"),
    };

    const offset = Duration(hours: -8);
    final dt = GDateTime(offset, 2010, 1, 2, 3, 4, 5); // no msecs

    var cMap = <GitHash, GDateTime>{
      GitHash("9a54971363328d210043eb0bea337e5742816194"): dt,
    };

    var mMap = <String, FileMTimeInfo>{
      'foo': FileMTimeInfo(
        'foo',
        GitHash("1e6df0fe5169ab7e3eb2412845c0d0f2ae2330df"),
        dt,
      ),
    };

    var cTimeBuilder = BlobCTimeBuilder(
      processedCommits: commits,
      processedTrees: trees,
      map: cMap,
    );
    var mTimeBuilder = FileMTimeBuilder(
      processedCommits: commits,
      processedTrees: trees,
      map: mMap,
    );

    var tempDir = await io.Directory.systemTemp.createTemp('__fnft__');
    var repoPath = tempDir.path;

    await GitRepository.init(repoPath).throwOnError();
    var repo = await GitRepository.load(repoPath).getOrThrow();

    var fileStorage = FileStorage(
      gitRepo: repo,
      blobCTimeBuilder: cTimeBuilder,
      fileMTimeBuilder: mTimeBuilder,
    );

    var cacheDir = await io.Directory.systemTemp.createTemp('__cache__');

    var cache = FileStorageCache(cacheDir.path);
    await cache.save(fileStorage);
    var fileStorage2 = await cache.load(repo);

    var deepEq = const DeepCollectionEquality().equals;
    expect(
        deepEq(fileStorage2.blobCTimeBuilder.processedCommits, commits), true);
    expect(deepEq(fileStorage2.blobCTimeBuilder.processedTrees, trees), true);
    expect(deepEq(fileStorage2.blobCTimeBuilder.map, cMap), true);

    expect(
        deepEq(fileStorage2.fileMTimeBuilder.processedCommits, commits), true);
    expect(deepEq(fileStorage2.fileMTimeBuilder.processedTrees, trees), true);
    expect(deepEq(fileStorage2.fileMTimeBuilder.map, mMap), true);
  });
}
