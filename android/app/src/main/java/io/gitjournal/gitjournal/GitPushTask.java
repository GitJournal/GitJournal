package io.gitjournal.gitjournal;

import android.os.AsyncTask;
import android.util.Log;

import java.io.File;

import io.flutter.plugin.common.MethodChannel.Result;

public class GitPushTask extends AsyncTask<String, Void, Void> {
    private final static String TAG = "GitPush";
    private Result result;

    public GitPushTask(Result _result) {
        result = _result;
    }

    protected Void doInBackground(String... params) {
        String cloneDirPath = params[0];
        final String publicKeyPath = params[1];
        final String privateKeyPath = params[2];

        File cloneDir = new File(cloneDirPath);
        Log.d("GitClone Directory", cloneDirPath);

        Git git = new Git();
        git.setSshKeys(publicKeyPath, privateKeyPath, "");
        String errorStr = git.push(cloneDirPath);
        if (!errorStr.isEmpty()) {
            result.error("FAILED", errorStr, null);
            return null;
        }

        result.success(null);
        return null;
    }
}
