import 'package:dart_git/plumbing/git_hash.dart';
import 'package:process_run/process_run.dart';

import 'package:gitjournal/logger/logger.dart';

Future<void> runGit(String args, [String? repoPath]) async {
  Log.d('test> git $args');
  var result = await runExecutableArguments('git', args.split(' '),
      workingDirectory: repoPath);

  if (result.exitCode != 0) {
    throw Exception("Command Failed: `git $args`");
  }
}

Future<void> setupFixture(String repoPath, GitHash hash) async {
  var repo = "https://github.com/GitJournal/test_data";

  await runGit('git clone $repo $repoPath', repoPath);
  await runGit('checkout $hash', repoPath);
  await runGit('switch -c main', repoPath);
  await runGit('remote rm origin', repoPath);
}
