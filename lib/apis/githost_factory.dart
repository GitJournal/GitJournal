import 'githost.dart';
import 'github.dart';
import 'gitlab.dart';

export 'githost.dart';

enum GitHostType {
  GitHub,
  GitLab,
  Custom,
}

GitHost createGitHost(GitHostType type) {
  switch (type) {
    case GitHostType.GitHub:
      return new GitHub();

    case GitHostType.GitLab:
      return new GitLab();

    default:
      return null;
  }
}
