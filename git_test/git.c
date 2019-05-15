#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <sys/stat.h>

#include <git2.h>

#define GJ_ERR_EMPTY_COMMIT -954

int handle_error(int err)
{
    if (err != 0)
    {
        const git_error *e = giterr_last();
        if (e)
        {
            printf("Error %d/%d: %s\n", err, e->klass, e->message);
        }
        else
        {
            printf("Unknown Error: %d\n", err);
        }
    }
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

// FIXME: Add a datetime str
int gj_git_commit(char *git_base_path, char *author_name, char *author_email, char *message)
{
    int err = 0;
    git_signature *sig = NULL;
    git_index *index = NULL;
    git_oid tree_id, commit_id;
    git_tree *tree = NULL;
    git_repository *repo = NULL;
    git_oid parent_id;
    git_commit *parent_commit = NULL;

    err = git_repository_open(&repo, git_base_path);
    if (err < 0)
        goto cleanup;

    err = git_repository_index(&index, repo);
    if (err < 0)
        goto cleanup;

    int numOps = git_index_entrycount(index);
    if (numOps == 0)
    {
        err = GJ_ERR_EMPTY_COMMIT;
        goto cleanup;
    }

    err = git_signature_now(&sig, author_name, author_email);
    if (err < 0)
        goto cleanup;

    err = git_index_write_tree(&tree_id, index);
    if (err < 0)
        goto cleanup;

    err = git_tree_lookup(&tree, repo, &tree_id);
    if (err < 0)
        goto cleanup;

    err = git_reference_name_to_id(&parent_id, repo, "HEAD");
    if (err < 0)
    {
        if (err != GIT_ENOTFOUND)
            goto cleanup;

        git_error_clear();

        err = git_commit_create(&commit_id, repo, "HEAD", sig, sig, NULL, message, tree, 0, NULL);
        if (err < 0)
            goto cleanup;
    }
    else
    {
        err = git_commit_lookup(&parent_commit, repo, &parent_id);
        if (err < 0)
            goto cleanup;

        const git_commit *parents = {parent_commit};
        err = git_commit_create(&commit_id, repo, "HEAD", sig, sig, NULL, message, tree, 1, &parents);
        if (err < 0)
            goto cleanup;
    }

cleanup:
    git_index_free(index);
    git_commit_free(parent_commit);
    git_tree_free(tree);
    git_repository_free(repo);
    git_signature_free(sig);

    return err;
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

int credentials_cb(git_cred **out, const char *url, const char *username_from_url,
                   unsigned int allowed_types, void *payload)
{
    printf("UsernameProvided: %s\n", username_from_url);
    printf("Allowed Types: %d\n", allowed_types);
    printf("Payload: %p\n", payload);

    if (!(allowed_types & GIT_CREDTYPE_SSH_KEY))
    {
        printf("Some other auth mechanism is being used: %d\n", allowed_types);
        return -1;
    }

    char *publickey = "/Users/vishesh/.ssh/id_rsa.pub";
    char *privatekey = "/Users/vishesh/.ssh/id_rsa";
    char *passphrase = "";

    int err = git_cred_ssh_key_new(out, username_from_url, publickey, privatekey, passphrase);
    if (err < 0)
    {
        return handle_error(err);
    }

    return 0;
}

int certificate_check_cb(git_cert *cert, int valid, const char *host, void *payload)
{
    printf("Valid: %d\n", valid);
    printf("CertType: %d\n", cert->cert_type);

    if (valid == 0)
    {
        printf("%s: Invalid certificate\n", host);
    }

    if (cert->cert_type == GIT_CERT_HOSTKEY_LIBSSH2)
    {
        printf("LibSSH2 Key: %p\n", payload);
        return 0;
    }
    return -1;
}

int gj_git_clone(char *clone_url, char *git_base_path)
{
    int err;
    git_repository *repo = NULL;
    git_clone_options options = GIT_CLONE_OPTIONS_INIT;
    options.fetch_opts.callbacks.transfer_progress = fetch_progress;
    options.fetch_opts.callbacks.credentials = credentials_cb;
    options.fetch_opts.callbacks.certificate_check = certificate_check_cb;

    err = git_clone(&repo, clone_url, git_base_path, &options);
    if (err < 0)
    {
        return handle_error(err);
    }

    git_repository_free(repo);

    return 0;
}

// FIXME: What if the 'HEAD" does not point to 'master'
int gj_git_push(char *git_base_path)
{
    int err = 0;
    git_repository *repo = NULL;
    git_remote *remote = NULL;
    git_oid head_id;

    err = git_repository_open(&repo, git_base_path);
    if (err < 0)
        goto cleanup;

    err = git_remote_lookup(&remote, repo, "origin");
    if (err < 0)
        goto cleanup;

    char *name = "refs/heads/master";
    const git_strarray refs = {&name, 1};

    git_push_options options = GIT_PUSH_OPTIONS_INIT;
    options.callbacks.credentials = credentials_cb;

    err = git_remote_push(remote, &refs, &options);
    if (err < 0)
        goto cleanup;

cleanup:
    git_remote_free(remote);
    git_repository_free(repo);

    return err;
}

int gj_git_pull(char *git_base_path, char *author_name, char *author_email)
{
    int err = 0;
    git_repository *repo = NULL;
    git_remote *remote = NULL;
    git_annotated_commit *annotated_commit = NULL;
    git_reference *ref = NULL;
    git_index *index = NULL;
    git_index_conflict_iterator *conflict_iter = NULL;

    err = git_repository_open(&repo, git_base_path);
    if (err < 0)
        goto cleanup;

    err = git_remote_lookup(&remote, repo, "origin");
    if (err < 0)
        goto cleanup;

    git_fetch_options options = GIT_FETCH_OPTIONS_INIT;
    options.callbacks.credentials = credentials_cb;

    err = git_remote_fetch(remote, NULL, &options, NULL);
    if (err < 0)
        goto cleanup;

    git_merge_options merge_options = GIT_MERGE_OPTIONS_INIT;
    git_checkout_options checkout_options = GIT_CHECKOUT_OPTIONS_INIT;

    // FIXME: Maybe I should be taking the head of the remote?
    err = git_repository_head(&ref, repo);
    if (err < 0)
        goto cleanup;

    err = git_annotated_commit_from_ref(&annotated_commit, repo, ref);
    if (err < 0)
        goto cleanup;

    err = git_merge(repo, (const git_annotated_commit **)&annotated_commit, 1,
                    &merge_options, &checkout_options);
    if (err < 0)
        goto cleanup;

    err = git_repository_index(&index, repo);
    if (err < 0)
        goto cleanup;

    err = git_index_conflict_iterator_new(&conflict_iter, index);
    if (err < 0)
        goto cleanup;

    // Handle Conflicts
    while (1)
    {
        git_index_entry *ancestor_out;
        git_index_entry *our_out;
        git_index_entry *their_out;
        err = git_index_conflict_next((const git_index_entry **)&ancestor_out,
                                      (const git_index_entry **)&our_out,
                                      (const git_index_entry **)&their_out,
                                      conflict_iter);

        if (err == GIT_ITEROVER)
        {
            printf("    No Conflicts\n");
            break;
        }
        if (err < 0)
            goto cleanup;

        // FIXME: This isn't what I want. I want 'theirs' to be applied!
        //        How to do that?
        git_index_conflict_remove(index, their_out->path);
    }

    err = git_index_write(index);
    if (err < 0)
        goto cleanup;

    //const git_commit *parents = {parent_commit};
    //err = git_commit_create(&commit_id, repo, "HEAD", sig, sig, NULL, message, tree, 1, &parents);

cleanup:
    git_repository_state_cleanup(repo);
    git_index_conflict_iterator_free(conflict_iter);
    git_index_free(index);
    git_reference_free(ref);
    git_annotated_commit_free(annotated_commit);
    git_remote_free(remote);
    git_repository_free(repo);

    return err;
}

int main(int argc, char *argv[])
{
    int err;
    char *git_base_path = "/tmp/foo";
    //char *clone_url = "https://github.com/GitJournal/journal_test.git";
    char *clone_url = "git@github.com:GitJournal/journal_test.git";
    //char *clone_url = "root@pi.local:git/test";
    char *add_pattern = ".";
    char *author_name = "TestMan";
    char *author_email = "TestMan@example.com";
    char *message = "Commit message for GitJournal";

    git_libgit2_init();

    //err = gj_git_init(git_base_path);
    //err = gj_git_commit(git_base_path, author_name, author_email, message);
    //err = gj_git_clone(clone_url, git_base_path);
    //err = gj_git_push(git_base_path);
    err = gj_git_pull(git_base_path, author_name, author_email);

    if (err < 0)
        handle_error(err);
    printf("We seem to be done\n");

    git_libgit2_shutdown();

    /*
    int features = git_libgit2_features();
    bool supports_threading = features & GIT_FEATURE_THREADS;
    bool supports_https2 = features & GIT_FEATURE_HTTPS;
    bool supports_ssh = features & GIT_FEATURE_SSH;
    printf("Threading: %d\n", supports_threading);
    printf("Https: %d\n", supports_https2);
    printf("SSH: %d\n", supports_ssh);
    */
    return 0;
}
