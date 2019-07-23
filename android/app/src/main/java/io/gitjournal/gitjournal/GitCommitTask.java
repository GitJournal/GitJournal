package io.gitjournal.gitjournal;

import android.os.AsyncTask;
import android.util.Log;

import java.io.File;

public class GitCommitTask extends AsyncTask<String, Void, Void> {
    private final static String TAG = "GitCommit";
    private AnyThreadResult result;

    public GitCommitTask(AnyThreadResult _result) {
        result = _result;
    }

    protected Void doInBackground(String... params) {
        final String cloneDirPath = params[0];
        final String authorName = params[1];
        final String authorEmail = params[2];
        final String message = params[3];
        final String commitDateTimeStr = params[4];

        File cloneDir = new File(cloneDirPath);
        Log.d("GitClone Directory", cloneDirPath);

        Git git = new Git();
        String errorStr = git.commit(cloneDirPath, authorName, authorEmail, message);
        if (!errorStr.isEmpty()) {
            result.error("FAILED", errorStr, null);
            return null;
        }

        result.success(null);
        return null;
    }
}
