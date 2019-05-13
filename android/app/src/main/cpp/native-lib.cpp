#include <jni.h>
#include <string>
#include <stdlib.h>

#include <openssl/err.h>
#include <openssl/crypto.h>
#include <libssh2.h>
#include <git2.h>

extern "C" JNIEXPORT jstring JNICALL
Java_io_gitjournal_gitjournal_MainActivity_stringFromJNI(
        JNIEnv *env,
        jobject /* this */) {

    ERR_load_crypto_strings();
    const char *openssl_version = OpenSSL_version(0);
    const char *ssh2_version = libssh2_version(0);

    std::string hello = "Hello from C++: ";
    hello += openssl_version;
    hello += " SSH Version: ";
    hello += ssh2_version;

    //git_libgit2_init();
    int major;
    int minor;
    int patch;
    git_libgit2_version(&major, &minor, &patch);

    hello += " Git version: ";
    char n_str[20];
    sprintf(n_str, "%d.%d.%d", major, minor, patch);
    hello += n_str;

    return env->NewStringUTF(hello.c_str());
}
