package io.gitjournal.gitjournal;

import android.os.AsyncTask;
import android.util.Log;

import org.eclipse.jgit.api.Git;
import org.eclipse.jgit.api.ResetCommand;
import org.eclipse.jgit.api.errors.GitAPIException;
import org.eclipse.jgit.api.errors.TransportException;

import java.io.File;

import io.flutter.plugin.common.MethodChannel.Result;

public class GitResetLastTask extends AsyncTask<String, Void, Void> {
    private final static String TAG = "GitResetLastTask";
    private Result result;

    public GitResetLastTask(Result _result) {
        result = _result;
    }

    protected Void doInBackground(String... params) {
        final String cloneDirPath = params[0];

        File cloneDir = new File(cloneDirPath);
        Log.d("GitResetLastTask", "Clone Path: " + cloneDirPath);

        try {
            Git git = Git.open(cloneDir);

            ResetCommand command = git.reset();
            command.setMode(ResetCommand.ResetType.HARD);
            command.setRef("HEAD^");
            command.call();

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
