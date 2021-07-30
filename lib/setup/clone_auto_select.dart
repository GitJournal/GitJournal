import 'package:universal_io/io.dart' show Platform;

import 'clone_gitExec.dart' as git_exec;
import 'clone_libgit2.dart' as libgit2;

final isMobileApp = Platform.isIOS || Platform.isAndroid;

var cloneRemote = isMobileApp ? libgit2.cloneRemote : git_exec.cloneRemote;
