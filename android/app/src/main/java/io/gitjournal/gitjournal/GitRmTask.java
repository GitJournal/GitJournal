package io.gitjournal.gitjournal;

import android.os.AsyncTask;
import android.util.Log;

import java.io.File;

public class GitRmTask extends AsyncTask<String, Void, Void> {
    private final static String TAG = "GitRm";
    private AnyThreadResult result;

    public GitRmTask(AnyThreadResult _result) {
        result = _result;
    }

    protected Void doInBackground(String... params) {
        final String cloneDirPath = params[0];
        final String filePattern = params[1];

        File cloneDir = new File(cloneDirPath);
        Log.d("GitClone Directory", cloneDirPath);

        Git git = new Git();
        String errorStr = git.rm(cloneDirPath, filePattern);
        if (!errorStr.isEmpty()) {
            result.error("FAILED", errorStr, null);
            return null;
        }

        result.success(null);
        return null;
    }
}
