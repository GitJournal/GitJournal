#include "gitjournal.h"

#include <stdio.h>
#include <string.h>
#include <sys/stat.h>

#include <git2.h>
#include <libssh/libssh.h>
#include <libssh/callbacks.h>

void change_pubickey_comment(const char *filename, const char *comment)
{
    FILE *fp = fopen(filename, "r");
    char buff[10000];
    fgets(buff, 10000, fp);
    fclose(fp);

    // Remove the comment
    char *end = strchr(strchr(buff, ' ') + 1, ' ');
    int len = end - buff + 1;
    buff[len] = 0;

    // Add custom comment
    strcat(buff, comment);
    strcat(buff, "\n");

    // Write the file back
    fp = fopen(filename, "w");
    fputs(buff, fp);
    fclose(fp);
}

void gj_ssh_log_callback(int priority, const char *function, const char *buffer, void *userdata)
{
    char log_str[1024];
    sprintf(log_str, "LIB_SSH P%d : %s : %s\n", priority, function, buffer);
    gj_log(log_str);
}

int gj_generate_ssh_keys(const char *private_key_path,
                         const char *public_key_path, const char *comment)
{
    ssh_key key;
    int err;

    ssh_set_log_level(SSH_LOG_FUNCTIONS);
    ssh_set_log_callback(gj_ssh_log_callback);

    err = ssh_pki_generate(SSH_KEYTYPE_RSA, 4096, &key);
    if (err != SSH_OK)
    {
        gj_log("LIBSSH: ssh_pki_generate failed\n");
        //printf("Error: %s", ssh_get_error());
        return err;
    }

    char *password = "";
    err = ssh_pki_export_privkey_file(key, password, NULL, NULL, private_key_path);
    if (err != SSH_OK)
    {
        gj_log("LIBSSH: ssh_pki_export_privkey_file failed\n");
        return err;
    }

    err = ssh_pki_export_pubkey_file(key, public_key_path);
    if (err != SSH_OK)
    {
        gj_log("LIBSSH: ssh_pki_export_pubkey_file failed\n");
        return err;
    }

    ssh_key_free(key);

    change_pubickey_comment(public_key_path, comment);

    // Change file permissions
    char mode[] = "0600";
    int modeInt = strtol(mode, 0, 8);
    chmod(private_key_path, modeInt);

    return 0;
}
