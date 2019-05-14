#include <stdio.h>
#include <string.h>
#include <sys/stat.h>

#include <git2.h>

int handle_error(int err)
{
    const git_error *e = giterr_last();
    printf("Error %d/%d: %s\n", err, e->klass, e->message);
    return err;
}

int match_cb(const char *path, const char *spec, void *payload)
{
    printf("Match: %s\n", path);
    return 0;
}

int gj_git_add(char *git_base_path, char *add_pattern)
{
    int err;

    git_repository *repo = NULL;
    err = git_repository_open(&repo, git_base_path);
    if (err < 0)
    {
        return handle_error(err);
    }

    git_index *idx = NULL;
    err = git_repository_index(&idx, repo);
    if (err < 0)
    {
        return handle_error(err);
    }

    char *paths[] = {add_pattern};
    git_strarray pathspec = {paths, 1};

    err = git_index_add_all(idx, &pathspec, GIT_INDEX_ADD_DEFAULT, match_cb, NULL);
    if (err < 0)
    {
        return handle_error(err);
    }

    err = git_index_write(idx);
    if (err < 0)
    {
        return handle_error(err);
    }

    git_index_free(idx);
    git_repository_free(repo);

    return 0;
}

int gj_git_rm(char *git_base_path, char *pattern)
{
    return 0;
}

int gj_git_clone(char *clone_url, char *git_base_path)
{
    return 0;
}

int gj_git_init(char *git_base_path)
{
    int err;

    git_repository_init_options initopts = GIT_REPOSITORY_INIT_OPTIONS_INIT;
    initopts.flags = GIT_REPOSITORY_INIT_MKPATH;
    initopts.workdir_path = git_base_path;

    git_repository *repo = NULL;
    err = git_repository_init_ext(&repo, git_base_path, &initopts);
    if (err < 0)
    {
        return handle_error(err);
    }

    return 0;
}

int gj_git_reset_hard(char *clone_url, char *ref)
{
    return 0;
}

int gj_git_push()
{
    return 0;
}

int gj_git_commit()
{
    return 0;
}

int gj_git_pull()
{
    return 0;
}

int main(int argc, char *argv[])
{
    char *git_base_path = "/tmp/journal_test";
    char *clone_url = "git@github.com:GitJournal/journal_test.git";
    char *add_pattern = ".";

    git_libgit2_init();

    gj_git_init("/tmp/foo");

    git_libgit2_shutdown();
    return 0;
}
