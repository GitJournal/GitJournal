#include "gitjournal.h"

#include <stdarg.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>

#include <git2.h>
#include <openssl/err.h>

void gj_log_internal(const char *format, ...)
{
    char buffer[1024];
    va_list args;
    va_start(args, format);
    vsprintf(buffer, format, args);
    gj_log(buffer);
    va_end(args);
}

gj_error *gj_error_info(int err)
{
    if (err == 0)
        return NULL;

    gj_error *error = (gj_error *)malloc(sizeof(gj_error));
    error->message_allocated = false;
    if (err <= GJ_ERR_FIRST && err >= GJ_ERR_LAST)
    {
        switch (err)
        {
        case GJ_ERR_EMPTY_COMMIT:
            error->code = err;
            error->message = "Empty Commit";
            break;

        case GJ_ERR_PULL_INVALID_STATE:
            error->code = err;
            error->message = "GitPull Invalid State";
            break;

        case GJ_ERR_OPENSSL:
            error->code = ERR_peek_last_error();
            error->message_allocated = true;
            error->message = (char *)malloc(256);
            ERR_error_string(error->code, error->message);
            break;

        case GJ_ERR_INVALID_CREDENTIALS:
            error->code = err;
            error->message = "Invalid Credentials";
            break;
        }
        return error;
    }

    const git_error *e = git_error_last();
    if (e)
    {
        error->code = e->klass;
        error->message = (char *)malloc(strlen(e->message));
        strcpy(error->message, e->message);
        error->message_allocated = true;
    }
    else
    {
        error->code = 1000;
        error->message = "Unknown Message";
    }

    return error;
}

void gj_error_free(const gj_error *err)
{
    if (err->message_allocated)
        free(err->message);
    free((void *)err);
}
