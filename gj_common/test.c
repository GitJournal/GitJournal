#include "gitjournal.h"

#include <stdio.h>

int handle_error(int err)
{
    if (err != 0)
    {
        const gj_error *e = gj_error_info(err);
        if (e)
        {
            printf("Error %d/%d: %s\n", err, e->code, e->message);
            gj_error_free(e);
        }
    }
    return err;
}

void gj_log(const char *message)
{
    printf("%s", message);
}

int main(int argc, char *argv[])
{
    gj_init();

    char *publickey = "/Users/vishesh/.ssh/id_rsa.pub";
    char *privatekey = "/Users/vishesh/.ssh/id_rsa";
    char *passphrase = "";

    gj_set_ssh_keys_paths(publickey, privatekey, passphrase);

    int err;
    char *git_base_path = "/tmp/test";
    //char *clone_url = "https://github.com/GitJournal/journal_test.git";
    char *clone_url = "git@github.com:GitJournal/journal_test.git";
    //char *clone_url = "root@pi.local:git/test";
    char *add_pattern = ".";
    char *author_name = "TestMan";
    char *author_email = "TestMan@example.com";
    char *message = "Commit message for GitJournal";

    //err = gj_git_init(git_base_path);
    //err = gj_git_commit(git_base_path, author_name, author_email, message);
    err = gj_git_clone(clone_url, git_base_path);
    //err = gj_git_push(git_base_path);
    //err = gj_git_pull(git_base_path, author_name, author_email);
    //err = gj_git_add(git_base_path, "9.md");
    //err = gj_git_rm(git_base_path, "9.md");
    //err = gj_git_reset_hard(git_base_path, "HEAD^");

    if (err < 0)
        handle_error(err);
    printf("We seem to be done\n");

    gj_shutdown();

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
