#include <jni.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>

#include <libssh/libssh.h>
#include <android/log.h>
#include <errno.h>

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

int generate_keys(const char* private_key_path,
                  const char* public_key_path,
                  const char* comment)
{
    ssh_key key;

    int ret = ssh_pki_generate(SSH_KEYTYPE_RSA, 4096, &key);
    if (ret != SSH_OK)
    {
        return ret;
    }

    __android_log_write(ANDROID_LOG_ERROR, "HOWDY", "KEY GENERATED");

    /*
    FILE*  file = fopen(private_key_path, "wb");
        if (file == NULL) {
                __android_log_print(ANDROID_LOG_ERROR, "HOWDY", "file is null %d", errno);
                return 1;
        }

    struct stat sb;

       int rc = fstat(fileno(file), &sb);
           if (rc < 0) {
                           __android_log_write(ANDROID_LOG_ERROR, "HOWDY", "stat problems");

           }
    */

    char *password = "";
    ret = ssh_pki_export_privkey_file(key, password, NULL, NULL, private_key_path);
    if (ret != SSH_OK) {
        __android_log_print(ANDROID_LOG_ERROR, "HOWDY", "Could not write private key %d", ret);
        return ret;
    }
    __android_log_write(ANDROID_LOG_ERROR, "HOWDY", "Private key exported");

    ret = ssh_pki_export_pubkey_file(key, public_key_path);
    if (ret != SSH_OK) {
        return ret;
    }
    __android_log_write(ANDROID_LOG_ERROR, "HOWDY", "Public key exported");

    ssh_key_free(key);

    change_pubickey_comment(public_key_path, comment);

    // Change file permissions
    char mode[] = "0600";
    int modeInt = strtol(mode, 0, 8);
    chmod(private_key_path, modeInt);

    return 0;
}

void ssh_log_jni_callback(int priority, const char *function, const char *buffer, void *userdata)
{
    __android_log_print(ANDROID_LOG_ERROR, "SSH_HOWDY", "P%d : %s : %s", priority, function, buffer);
}

JNIEXPORT jstring JNICALL
Java_io_gitjournal_gitjournal_Git_generateKeys(
        JNIEnv *env,
        jobject this_obj,
        jstring jni_private_key_path,
        jstring jni_public_key_path,
        jstring jni_comment)
{
    const char *private_key_path = (*env)->GetStringUTFChars(env, jni_private_key_path, 0);
    const char *public_key_path = (*env)->GetStringUTFChars(env, jni_public_key_path, 0);
    const char *comment = (*env)->GetStringUTFChars(env, jni_comment, 0);

    __android_log_write(ANDROID_LOG_ERROR, "HOWDY", "Error msg");
    __android_log_write(ANDROID_LOG_ERROR, "HOWDY", private_key_path);
    __android_log_write(ANDROID_LOG_ERROR, "HOWDY", public_key_path);
    __android_log_write(ANDROID_LOG_ERROR, "HOWDY", comment);

    // Debugging
    ssh_set_log_level(SSH_LOG_FUNCTIONS);
    ssh_set_log_callback(ssh_log_jni_callback);
    ssh_set_log_level(SSH_LOG_FUNCTIONS);

    int ret = generate_keys(private_key_path, public_key_path, comment);
    if (ret != 0) {
        return (*env)->NewStringUTF(env, "Error Generating PublicKeys");
    }

    return (*env)->NewStringUTF(env, "");
}
