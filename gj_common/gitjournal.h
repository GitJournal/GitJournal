#ifndef _GITJOURNAL_H_
#define _GITJOURNAL_H_

#include <stdbool.h>

int gj_init();
int gj_shutdown();

int gj_git_init(char *git_base_path);
int gj_git_clone(char *clone_url, char *git_base_path);

int gj_git_pull(char *git_base_path, char *author_name, char *author_email);
int gj_git_push(char *git_base_path);

int gj_git_commit(char *git_base_path, char *author_name, char *author_email, char *message);
int gj_git_reset_hard(char *git_base_path, char *ref);
int gj_git_add(char *git_base_path, char *pattern);
int gj_git_rm(char *git_base_path, char *pattern);

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
void gj_log(const char *format, ...);

#endif
