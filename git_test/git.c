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

    git_repository_free(repo);

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

// FIXME: Add a datetime str
// FIXME: Do not allow empty commits
int gj_git_commit(char *git_base_path, char *author_name, char *author_email, char *message)
{
    int err;
    git_signature *sig = NULL;
    git_index *index = NULL;
    git_oid tree_id, commit_id;
    git_tree *tree = NULL;
    git_repository *repo = NULL;

    err = git_signature_now(&sig, author_name, author_email);
    if (err < 0)
    {
        handle_error(err);
    }

    err = git_repository_open(&repo, git_base_path);
    if (err < 0)
    {
        git_signature_free(sig);
        return handle_error(err);
    }

    err = git_repository_index(&index, repo);
    if (err < 0)
    {
        git_signature_free(sig);
        git_repository_free(repo);
        return handle_error(err);
    }

    err = git_index_write_tree(&tree_id, index);
    if (err < 0)
    {
        git_signature_free(sig);
        git_index_free(index);
        git_repository_free(repo);
        return handle_error(err);
    }

    git_index_free(index);

    err = git_tree_lookup(&tree, repo, &tree_id);
    if (err < 0)
    {
        git_signature_free(sig);
        git_repository_free(repo);
        return handle_error(err);
    }

    // Get the parent, if exists
    git_oid parent_id;
    git_commit *parent_commit = NULL;

    err = git_reference_name_to_id(&parent_id, repo, "HEAD");
    if (err)
    {
        // Probably first commit
        err = git_commit_create(&commit_id, repo, "HEAD", sig, sig, NULL, message, tree, 0, NULL);
        if (err < 0)
        {
            git_signature_free(sig);
            git_tree_free(tree);
            git_repository_free(repo);
            return handle_error(err);
        }
    }
    else
    {
        err = git_commit_lookup(&parent_commit, repo, &parent_id);
        if (err < 0)
        {
            git_signature_free(sig);
            git_tree_free(tree);
            git_repository_free(repo);
            return handle_error(err);
        }

        const git_commit *parents = {parent_commit};
        err = git_commit_create(&commit_id, repo, "HEAD", sig, sig, NULL, message, tree, 1, &parents);
        if (err < 0)
        {
            git_commit_free(parent_commit);
            git_signature_free(sig);
            git_tree_free(tree);
            git_repository_free(repo);
            return handle_error(err);
        }
    }

    git_commit_free(parent_commit);
    git_tree_free(tree);
    git_repository_free(repo);
    git_signature_free(sig);

    return 0;
}

int fetch_progress(const git_transfer_progress *stats, void *payload)
{
    int fetch_percent =
        (100 * stats->received_objects) /
        stats->total_objects;
    int index_percent =
        (100 * stats->indexed_objects) /
        stats->total_objects;
    int kbytes = stats->received_bytes / 1024;

    printf("network %3d%% (%4d kb, %5d/%5d)  /"
           "  index %3d%% (%5d/%5d)\n",
           fetch_percent, kbytes,
           stats->received_objects, stats->total_objects,
           index_percent,
           stats->indexed_objects, stats->total_objects);
    return 0;
}

int gj_git_clone(char *clone_url, char *git_base_path)
{
    int err;
    git_repository *repo = NULL;
    git_clone_options options = GIT_CLONE_OPTIONS_INIT;
    options.fetch_opts.callbacks.transfer_progress = fetch_progress;

    git_clone(&repo, clone_url, git_base_path, &options);
    if (err < 0)
    {
        return handle_error(err);
    }

    git_repository_free(repo);

    return 0;
}

int gj_git_pull()
{
    return 0;
}

int main(int argc, char *argv[])
{
    char *git_base_path = "/tmp/journal_test";
    char *clone_url = "https://github.com/GitJournal/journal_test.git";
    char *add_pattern = ".";
    char *author_name = "TestMan";
    char *author_email = "TestMan@example.com";
    char *message = "Commit message for GitJournal";

    git_libgit2_init();

    //gj_git_init(git_base_path);
    //gj_git_commit(git_base_path, author_name, author_email, message);

    gj_git_clone(clone_url, git_base_path);

    printf("We seem to be done\n");
    git_libgit2_shutdown();
    return 0;
}
