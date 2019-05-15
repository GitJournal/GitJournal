package io.gitjournal.gitjournal;

public class Git {
    static {
        System.loadLibrary("native-lib");
    }

    // This needs to be called once!
    public native void setupLib();

    public native String generateKeys(String privateKeyPath, String publicKeyPath, String comment);

    public native String init(String basePath);
    public native String clone(String cloneUrl, String basePath);

    public native String pull(String basePath, String authorName, String authorEmail);
    public native String push(String basePath);

    public native String commit(String basePath, String authorName, String authorEmail, String message);
    public native String resetHard(String basePath, String ref);
    public native String add(String basePath, String pattern);
    public native String rm(String basePath, String pattern);

    public native void setSshKeys(String publicKeyPath, String privateKeyPath, String passphrase);
}
