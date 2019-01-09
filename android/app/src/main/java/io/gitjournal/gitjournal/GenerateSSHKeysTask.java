package io.gitjournal.gitjournal;

import android.os.AsyncTask;
import android.util.Log;

import com.jcraft.jsch.*;

import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;

import org.apache.commons.io.FileUtils;

import io.flutter.plugin.common.MethodChannel.Result;

public class GenerateSSHKeysTask extends AsyncTask<String, Void, Void> {
    private Result result;

    public GenerateSSHKeysTask(Result _result) {
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
            Log.d("GenerateSSHKeys", "Private key already exists");
            result.error("FAILED", "Private key already exists", null);
            return null;
        }

        // Generate key pair
        try {
            JSch jsch = new JSch();
            KeyPair kpair = KeyPair.genKeyPair(jsch, KeyPair.RSA, 1024 * 4);

            kpair.writePrivateKey(privateKeyPath);
            kpair.writePublicKey(publicKeyPath, comment);
            kpair.dispose();
        } catch (JSchException ex) {
            Log.d("GenerateSSHKeys", ex.toString());
            result.error("FAILED", ex.toString(), null);
            return null;
        } catch (IOException ex) {
            Log.d("GenerateSSHKeys", ex.toString());
            result.error("FAILED", ex.toString(), null);
            return null;
        }

        String publicKey;
        try {
            publicKey = FileUtils.readFileToString(new File(publicKeyPath), Charset.defaultCharset());
        } catch (IOException ex) {
            Log.d("GenerateSSHKeys", ex.toString());
            result.error("FAILED", "Failed to read the public key", null);
            return null;
        }

        result.success(publicKey);
        return null;
    }
}
