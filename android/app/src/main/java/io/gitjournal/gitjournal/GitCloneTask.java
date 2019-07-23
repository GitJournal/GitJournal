package io.gitjournal.gitjournal;

import android.os.AsyncTask;
import android.util.Log;

import java.io.File;

public class GitCloneTask extends AsyncTask<String, Void, Void> {
    private final static String TAG = "GitClone";
    private AnyThreadResult result;

    public GitCloneTask(AnyThreadResult _result) {
        result = _result;
    }

    protected Void doInBackground(String... params) {
        String url = params[0];
        String cloneDirPath = params[1];
        final String publicKeyPath = params[2];
        final String privateKeyPath = params[3];

        File cloneDir = new File(cloneDirPath);
        Log.d("GitClone Directory", cloneDirPath);

        Git git = new Git();
        git.setSshKeys(publicKeyPath, privateKeyPath, "");

        String errorStr = git.clone(url, cloneDirPath);
        if (!errorStr.isEmpty()) {
            result.error("FAILED", errorStr, null);
            return null;
        }

        result.success(null);
        return null;
    }
}
