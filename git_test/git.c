#include <stdio.h>
#include <string.h>
#include <sys/stat.h>

#include <git2.h>

void handle_error(int err)
{
    if (err < 0)
    {
        const git_error *e = giterr_last();
        printf("Error %d/%d: %s\n", err, e->klass, e->message);
    }
}

int match_cb(const char *path, const char *spec, void *payload)
{
    printf("Match: %s\n", path);
    return 0;
}

int main(int argc, char *argv[])
{
    int err;
    char *git_base_path = "/tmp/journal_test";
    char *clone_url = "git@github.com:GitJournal/journal_test.git";
    char *add_pattern = ".";

    git_libgit2_init();

    git_repository *repo = NULL;
    err = git_repository_open(&repo, git_base_path);
    handle_error(err);

    git_index *idx = NULL;
    err = git_repository_index(&idx, repo);
    handle_error(err);

    char *paths[] = {add_pattern};
    git_strarray pathspec = {paths, 1};

    err = git_index_add_all(idx, &pathspec, GIT_INDEX_ADD_DEFAULT, match_cb, NULL);
    handle_error(err);

    err = git_index_write(idx);
    handle_error(err);

    git_index_free(idx);

    return 0;
}
