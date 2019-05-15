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


// FIXME: Figure out better error handling!
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


JNIEXPORT void JNICALL
Java_io_gitjournal_gitjournal_Git_setupLib(
        JNIEnv *env,
        jobject this_obj) {
    gj_init();
}

JNIEXPORT jstring JNICALL
Java_io_gitjournal_gitjournal_Git_init(
        JNIEnv *env,
        jobject this_obj,
        jstring jni_git_base_path) {
    const char *git_base_path = (*env)->GetStringUTFChars(env, jni_git_base_path, 0);

    int err = gj_git_init(git_base_path);
    if (err < 0) {
        handle_error(err);
        return (*env)->NewStringUTF(env, "Error");
    }

    return (*env)->NewStringUTF(env, "");
}

JNIEXPORT jstring JNICALL
Java_io_gitjournal_gitjournal_Git_clone(
        JNIEnv *env,
        jobject this_obj,
        jstring jni_clone_url,
        jstring jni_git_base_path) {
    const char *clone_url = (*env)->GetStringUTFChars(env, jni_clone_url, 0);
    const char *git_base_path = (*env)->GetStringUTFChars(env, jni_git_base_path, 0);

    int err = gj_git_clone(clone_url, git_base_path);
    if (err < 0) {
        handle_error(err);
        return (*env)->NewStringUTF(env, "Error");
    }

    return (*env)->NewStringUTF(env, "");
}


JNIEXPORT jstring JNICALL
Java_io_gitjournal_gitjournal_Git_pull(
        JNIEnv *env,
        jobject this_obj,
        jstring jni_git_base_path,
        jstring jni_author_name,
        jstring jni_author_email) {
    const char *git_base_path = (*env)->GetStringUTFChars(env, jni_git_base_path, 0);
    const char *author_name = (*env)->GetStringUTFChars(env, jni_author_name, 0);
    const char *author_email = (*env)->GetStringUTFChars(env, jni_author_email, 0);

    int err = gj_git_pull(git_base_path, author_name, author_email);
    if (err < 0) {
        handle_error(err);
        return (*env)->NewStringUTF(env, "Error");
    }

    return (*env)->NewStringUTF(env, "");
}


JNIEXPORT jstring JNICALL
Java_io_gitjournal_gitjournal_Git_push(
        JNIEnv *env,
        jobject this_obj,
        jstring jni_git_base_path) {
    const char *git_base_path = (*env)->GetStringUTFChars(env, jni_git_base_path, 0);

    int err = gj_git_push(git_base_path);
    if (err < 0) {
        handle_error(err);
        return (*env)->NewStringUTF(env, "Error");
    }

    return (*env)->NewStringUTF(env, "");
}

JNIEXPORT jstring JNICALL
Java_io_gitjournal_gitjournal_Git_commit(
        JNIEnv *env,
        jobject this_obj,
        jstring jni_git_base_path,
        jstring jni_author_name,
        jstring jni_author_email,
        jstring jni_message) {
    const char *git_base_path = (*env)->GetStringUTFChars(env, jni_git_base_path, 0);
    const char *author_name = (*env)->GetStringUTFChars(env, jni_author_name, 0);
    const char *author_email = (*env)->GetStringUTFChars(env, jni_author_email, 0);
    const char *message = (*env)->GetStringUTFChars(env, jni_message, 0);

    int err = gj_git_commit(git_base_path, author_name, author_email, message);
    if (err < 0) {
        handle_error(err);
        return (*env)->NewStringUTF(env, "Error");
    }

    return (*env)->NewStringUTF(env, "");
}

JNIEXPORT jstring JNICALL
Java_io_gitjournal_gitjournal_Git_resetHard(
        JNIEnv *env,
        jobject this_obj,
        jstring jni_git_base_path,
        jstring jni_ref) {
    const char *git_base_path = (*env)->GetStringUTFChars(env, jni_git_base_path, 0);
    const char *ref = (*env)->GetStringUTFChars(env, jni_ref, 0);

    int err = gj_git_reset_hard(git_base_path, ref);
    if (err < 0) {
        handle_error(err);
        return (*env)->NewStringUTF(env, "Error");
    }

    return (*env)->NewStringUTF(env, "");
}

JNIEXPORT jstring JNICALL
Java_io_gitjournal_gitjournal_Git_add(
        JNIEnv *env,
        jobject this_obj,
        jstring jni_git_base_path,
        jstring jni_add_pattern) {
    const char *git_base_path = (*env)->GetStringUTFChars(env, jni_git_base_path, 0);
    const char *add_pattern = (*env)->GetStringUTFChars(env, jni_add_pattern, 0);

    int err = gj_git_add(git_base_path, add_pattern);
    if (err < 0) {
        handle_error(err);
        return (*env)->NewStringUTF(env, "Error");
    }

    __android_log_print(ANDROID_LOG_ERROR, "GitAdd", "Everything seems fine");

    return (*env)->NewStringUTF(env, "");
}


JNIEXPORT jstring JNICALL
Java_io_gitjournal_gitjournal_Git_rm(
        JNIEnv *env,
        jobject this_obj,
        jstring jni_git_base_path,
        jstring jni_pattern) {
    const char *git_base_path = (*env)->GetStringUTFChars(env, jni_git_base_path, 0);
    const char *pattern = (*env)->GetStringUTFChars(env, jni_pattern, 0);

    int err = gj_git_rm(git_base_path, pattern);
    if (err < 0) {
        handle_error(err);
        return (*env)->NewStringUTF(env, "Error");
    }

    __android_log_print(ANDROID_LOG_ERROR, "GitAdd", "Everything seems fine");

    return (*env)->NewStringUTF(env, "");
}


JNIEXPORT void JNICALL
Java_io_gitjournal_gitjournal_Git_setSshKeys(
        JNIEnv *env,
        jobject this_obj,
        jstring jni_public_key_path,
        jstring jni_private_key_path,
        jstring jni_passphrase) {
    const char *public_key_path = (*env)->GetStringUTFChars(env, jni_public_key_path, 0);
    const char *private_key_path = (*env)->GetStringUTFChars(env, jni_private_key_path, 0);
    const char *passphrase = (*env)->GetStringUTFChars(env, jni_passphrase, 0);

    gj_set_ssh_keys_paths((char *) public_key_path, (char *) private_key_path, (char *) passphrase);
}