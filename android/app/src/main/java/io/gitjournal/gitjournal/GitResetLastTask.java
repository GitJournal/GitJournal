package io.gitjournal.gitjournal;

import android.os.AsyncTask;

import io.flutter.plugin.common.MethodChannel.Result;

public class GitResetLastTask extends AsyncTask<String, Void, Void> {
    private final static String TAG = "GitResetLastTask";
    private Result result;

    public GitResetLastTask(Result _result) {
        result = _result;
    }

    protected Void doInBackground(String... params) {
        final String cloneDirPath = params[0];

        Git git = new Git();
        String errorStr = git.resetHard(cloneDirPath, "HEAD^");
        if (!errorStr.isEmpty()) {
            result.error("FAILED", errorStr, null);
            return null;
        }

        result.success(null);
        return null;
    }
}
