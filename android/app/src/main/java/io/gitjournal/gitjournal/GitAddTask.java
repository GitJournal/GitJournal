package io.gitjournal.gitjournal;

import android.os.AsyncTask;
import android.util.Log;

import io.flutter.plugin.common.MethodChannel.Result;

public class GitAddTask extends AsyncTask<String, Void, Void> {
    private final static String TAG = "GitAdd";
    private Result result;

    public GitAddTask(Result _result) {
        result = _result;
    }

    protected Void doInBackground(String... params) {
        final String cloneDirPath = params[0];
        final String filePattern = params[1];

        Log.d("GitClone Directory", cloneDirPath);

        Git git = new Git();
        String errorStr = git.add(cloneDirPath, filePattern);
        if (!errorStr.isEmpty()) {
            result.error("FAILED", errorStr, null);
            return null;
        }

        result.success(null);
        return null;
    }
}
