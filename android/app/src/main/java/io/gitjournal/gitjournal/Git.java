package io.gitjournal.gitjournal;

public class Git {
    static {
        System.loadLibrary("native-lib");
    }

    public native String generateKeys(String privateKeyPath, String publicKeyPath, String comment);
}
