#include <jni.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>

#include <android/log.h>
#include <errno.h>

#include <git2.h>

int match_cb(const char *path, const char *spec, void *payload)
{
    __android_log_print(ANDROID_LOG_ERROR, "GitAdd", "Match: %s\n", path);
}


JNIEXPORT jstring JNICALL
Java_io_gitjournal_gitjournal_Git_add(
        JNIEnv *env,
        jobject this_obj,
        jstring jni_git_base_path,
        jstring jni_add_pattern)
{
    const char *git_base_path = (*env)->GetStringUTFChars(env, jni_git_base_path, 0);
    const char *add_pattern = (*env)->GetStringUTFChars(env, jni_add_pattern, 0);

    int error;

    // FIXME: Do this somewhere else
    git_libgit2_init();

    git_repository *repo = NULL;
    error = git_repository_open(&repo, git_base_path);
    if (error < 0) {
        const git_error *e = giterr_last();
        __android_log_print(ANDROID_LOG_ERROR, "GitAdd", "Error %d/%d: %s\n", error, e->klass, e->message);
        return (*env)->NewStringUTF(env, "Error");
    }

    git_index *idx = NULL;
    error = git_repository_index(&idx, repo);
    if (error < 0) {
        const git_error *e = giterr_last();
        __android_log_print(ANDROID_LOG_ERROR, "GitAdd", "Error %d/%d: %s\n", error, e->klass, e->message);
        return (*env)->NewStringUTF(env, "Error");
    }

    const char *paths[] = {add_pattern};
    git_strarray pathspec = {paths, 1};

    __android_log_print(ANDROID_LOG_ERROR, "GitAdd", "Add Pattern: %s", add_pattern);

    error = git_index_add_all(idx, &pathspec, GIT_INDEX_ADD_DEFAULT, match_cb, NULL);
    if (error < 0) {
        const git_error *e = giterr_last();
        __android_log_print(ANDROID_LOG_ERROR, "GitAdd", "Error %d/%d: %s\n", error, e->klass, e->message);
        return (*env)->NewStringUTF(env, "Error");
    }

    error = git_index_write(idx);
    if (error < 0) {
        const git_error *e = giterr_last();
        __android_log_print(ANDROID_LOG_ERROR, "GitAdd", "Error %d/%d: %s\n", error, e->klass, e->message);
        return (*env)->NewStringUTF(env, "Error");
    }

    git_index_free(idx);
    if (error < 0) {
        const git_error *e = giterr_last();
        __android_log_print(ANDROID_LOG_ERROR, "GitAdd", "Error %d/%d: %s\n", error, e->klass, e->message);
        return (*env)->NewStringUTF(env, "Error");
    }

    __android_log_print(ANDROID_LOG_ERROR, "GitAdd", "Everything seems fine");

    return (*env)->NewStringUTF(env, "");
}
