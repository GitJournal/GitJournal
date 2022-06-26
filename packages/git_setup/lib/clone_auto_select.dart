/*
 * SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
 *
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

import 'package:universal_io/io.dart' show Platform;

import 'clone_git_exec.dart' as git_exec;
import 'clone_libgit2.dart' as libgit2;

final isMobileApp = Platform.isIOS || Platform.isAndroid;

var cloneRemote = isMobileApp ? libgit2.cloneRemote : git_exec.cloneRemote;
