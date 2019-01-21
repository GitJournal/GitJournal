package io.gitjournal.gitjournal;

import android.os.AsyncTask;
import android.util.Log;

import org.eclipse.jgit.api.Git;
import org.eclipse.jgit.api.errors.GitAPIException;
import org.eclipse.jgit.api.CloneCommand;
import org.eclipse.jgit.api.TransportConfigCallback;
import org.eclipse.jgit.api.errors.TransportException;
import org.eclipse.jgit.transport.Transport;
import org.eclipse.jgit.transport.SshTransport;

import org.eclipse.jgit.lib.TextProgressMonitor;

import java.io.PrintWriter;
import java.io.File;

import io.flutter.plugin.common.MethodChannel.Result;

public class GitInitTask extends AsyncTask<String, Void, Void> {
    private final static String TAG = "GitInit";
    private Result result;

    public GitInitTask(Result _result) {
        result = _result;
    }

    protected Void doInBackground(String... params) {
        String cloneDirPath = params[0];

        File cloneDir = new File(cloneDirPath);
        Log.d("GitInit Directory", cloneDirPath);

        try {
            Git.init().setDirectory(cloneDir).call();

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
