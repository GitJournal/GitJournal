package io.gitjournal.gitjournal;

import android.os.AsyncTask;
import android.util.Log;

public class GitInitTask extends AsyncTask<String, Void, Void> {
    private final static String TAG = "GitInit";
    private AnyThreadResult result;

    public GitInitTask(AnyThreadResult _result) {
        result = _result;
    }

    protected Void doInBackground(String... params) {
        String cloneDirPath = params[0];
        Log.d("GitInit Directory", cloneDirPath);

        Git git = new Git();
        String errorStr = git.init(cloneDirPath);
        if (!errorStr.isEmpty()) {
            result.error("FAILED", errorStr, null);
            return null;
        }

        result.success(null);
        return null;
    }
}
