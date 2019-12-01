package io.gitjournal.gitjournal;

import android.os.AsyncTask;
import android.util.Log;

import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;

public class GenerateSSHKeysTask extends AsyncTask<String, Void, Void> {
    private final static String TAG = "GenerateSSHKeys";
    private AnyThreadResult result;

    public GenerateSSHKeysTask(AnyThreadResult _result) {
        result = _result;
    }

    protected Void doInBackground(String... params) {
        String keysDirPath = params[0];
        File keysDir = new File(keysDirPath);
        if (!keysDir.exists()) {
            keysDir.mkdir();
        }

        String comment = params[1];

        final String privateKeyPath = keysDir + "/id_rsa";
        final String publicKeyPath = keysDir + "/id_rsa.pub";

        File privateKeyFile = new File(privateKeyPath);
        if (privateKeyFile.exists()) {
            Log.d(TAG, "Private key already exists. Overwriting");
        }

        Git git = new Git();
        String errorStr = git.generateKeys(privateKeyPath, publicKeyPath, comment);
        if (!errorStr.isEmpty()) {
            result.error("FAILED", errorStr, null);
            return null;
        }

        String publicKey;
        try {
            publicKey = FileUtils.readFileToString(new File(publicKeyPath), Charset.defaultCharset());
        } catch (IOException ex) {
            Log.d(TAG, ex.toString());
            result.error("FAILED", "Failed to read the public key", null);
            return null;
        }

        result.success(publicKey);
        return null;
    }
}
