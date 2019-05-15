#ifndef _GITJOURNAL_H_
#define _GITJOURNAL_H_

#include <stdbool.h>

int gj_init();
int gj_shutdown();

int gj_git_init(const char *git_base_path);
int gj_git_clone(const char *clone_url, const char *git_base_path);

int gj_git_pull(const char *git_base_path, const char *author_name, const char *author_email);
int gj_git_push(const char *git_base_path);

int gj_git_commit(const char *git_base_path, const char *author_name,
                  const char *author_email, const char *message);
int gj_git_reset_hard(const char *git_base_path, const char *ref);
int gj_git_add(const char *git_base_path, const char *pattern);
int gj_git_rm(const char *git_base_path, const char *pattern);

void gj_set_ssh_keys_paths(char *public_key, char *private_key, char *passcode);

typedef struct
{
    char *message;
    bool message_allocated;
    int code;
} gj_error;

gj_error *gj_error_info(int err);
void gj_error_free(const gj_error *err);

// This must be implemented by you
void gj_log(const char *message);

#endif
