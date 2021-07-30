import 'package:flutter_test/flutter_test.dart' as ft;
import 'package:path/path.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

import 'package:gitjournal/utils/logger.dart';

void main() {
  setUp(() async {
    ft.TestWidgetsFlutterBinding.ensureInitialized();

    var provider = await FakePathProviderPlatform.init();
    PathProviderPlatform.instance = provider;
    await Log.init(ignoreFimber: true);
  });

  test('Logger', () async {
    Log.e("Hello");

    try {
      throw Exception("Boo");
    } catch (e, st) {
      Log.e("Caught", ex: e, stacktrace: st);
    }

    var logs = Log.fetchLogsForDate(DateTime.now()).toList();
    expect(logs.length, 2);
    expect(logs[0].msg, "Hello");
    expect(logs[1].msg, "Caught");
  });
}
// todo: Make this async
// todo: Make sure all exceptions are being caught

// from path_provider_test
const String kTemporaryPath = 'temporaryPath';
const String kApplicationSupportPath = 'applicationSupportPath';
const String kDownloadsPath = 'downloadsPath';
const String kLibraryPath = 'libraryPath';
const String kApplicationDocumentsPath = 'applicationDocumentsPath';
const String kExternalCachePath = 'externalCachePath';
const String kExternalStoragePath = 'externalStoragePath';

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final Directory dir;

  FakePathProviderPlatform(this.dir);

  static Future<FakePathProviderPlatform> init() async {
    var dir = await Directory.systemTemp.createTemp();
    await Directory(join(dir.path, kTemporaryPath)).create();

    return FakePathProviderPlatform(dir);
  }

  @override
  Future<String?> getTemporaryPath() async {
    return join(dir.path, kTemporaryPath);
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return kApplicationSupportPath;
  }

  @override
  Future<String?> getLibraryPath() async {
    return kLibraryPath;
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return kApplicationDocumentsPath;
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return kExternalStoragePath;
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return <String>[kExternalCachePath];
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return <String>[kExternalStoragePath];
  }

  @override
  Future<String?> getDownloadsPath() async {
    return kDownloadsPath;
  }
}
