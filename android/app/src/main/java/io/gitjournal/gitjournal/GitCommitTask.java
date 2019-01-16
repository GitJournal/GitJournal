package io.gitjournal.gitjournal;

import android.os.AsyncTask;
import android.util.Log;

import org.eclipse.jgit.api.Git;
import org.eclipse.jgit.api.errors.GitAPIException;

import org.eclipse.jgit.api.CommitCommand;
import org.eclipse.jgit.api.errors.TransportException;

import java.io.File;

import io.flutter.plugin.common.MethodChannel.Result;

public class GitCommitTask extends AsyncTask<String, Void, Void> {
    private final static String TAG = "GitCommit";
    private Result result;

    public GitCommitTask(Result _result) {
        result = _result;
    }

    protected Void doInBackground(String... params) {
        final String cloneDirPath = params[0];
        final String authorName = params[1];
        final String authorEmail = params[2];
        final String message = params[3];

        File cloneDir = new File(cloneDirPath);
        Log.d("GitClone Directory", cloneDirPath);

        try {
            Git git = Git.open(cloneDir);

            CommitCommand commitCommand = git.commit();
            commitCommand.setAuthor(authorName, authorEmail);
            commitCommand.setMessage(message);
            commitCommand.call();

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
