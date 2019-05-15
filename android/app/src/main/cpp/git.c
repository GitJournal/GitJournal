#include <jni.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>

#include <android/log.h>
#include <errno.h>

#include "gitjournal.h"

void gj_log(const char *message) {
    __android_log_print(ANDROID_LOG_ERROR, "GitJournalLib", "%s", message);
}


int handle_error(int err) {
    if (err != 0) {
        const gj_error *e = gj_error_info(err);
        if (e) {
            __android_log_print("Error %d/%d: %s\n", err, e->code, e->message);
            gj_error_free(e);
        }
    }
    return err;
}

JNIEXPORT jstring JNICALL
Java_io_gitjournal_gitjournal_Git_add(
        JNIEnv *env,
        jobject this_obj,
        jstring jni_git_base_path,
        jstring jni_add_pattern) {
    const char *git_base_path = (*env)->GetStringUTFChars(env, jni_git_base_path, 0);
    const char *add_pattern = (*env)->GetStringUTFChars(env, jni_add_pattern, 0);

    // FIXME: This should be done somewhere else!
    gj_init();

    int err = gj_git_add(git_base_path, add_pattern);
    if (err < 0) {
        handle_error(err);
        return (*env)->NewStringUTF(env, "Error");
    }

    __android_log_print(ANDROID_LOG_ERROR, "GitAdd", "Everything seems fine");

    return (*env)->NewStringUTF(env, "");
}
