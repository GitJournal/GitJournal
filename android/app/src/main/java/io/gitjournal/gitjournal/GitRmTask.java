package io.gitjournal.gitjournal;

import android.os.AsyncTask;
import android.util.Log;

import org.eclipse.jgit.api.Git;
import org.eclipse.jgit.api.RmCommand;
import org.eclipse.jgit.api.errors.GitAPIException;
import org.eclipse.jgit.api.errors.TransportException;

import java.io.File;

import io.flutter.plugin.common.MethodChannel.Result;

public class GitRmTask extends AsyncTask<String, Void, Void> {
    private final static String TAG = "GitRm";
    private Result result;

    public GitRmTask(Result _result) {
        result = _result;
    }

    protected Void doInBackground(String... params) {
        final String cloneDirPath = params[0];
        final String filePattern = params[1];

        File cloneDir = new File(cloneDirPath);
        Log.d("GitClone Directory", cloneDirPath);

        try {
            Git git = Git.open(cloneDir);

            RmCommand rmCommand = git.rm();
            rmCommand.addFilepattern(filePattern);
            rmCommand.call();

        } catch (TransportException e) {
            Log.d(TAG, e.toString());
            result.error("FAILED", e.getMessage(), null);
            return null;
        } catch (GitAPIException e) {
            Log.d(TAG, e.toString());
            result.error("FAILED", e.getMessage(), null);
            return null;
        } catch (Exception e) {
            Log.d(TAG, e.toString());
            result.error("FAILED", e.getMessage(), null);
            return null;
        }

        result.success(null);
        return null;
    }
}
