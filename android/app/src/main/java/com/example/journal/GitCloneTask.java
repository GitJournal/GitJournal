package com.example.journal;

import android.os.AsyncTask;

import org.eclipse.jgit.api.Git;
import org.eclipse.jgit.api.errors.GitAPIException;

import java.io.File;

import io.flutter.plugin.common.MethodChannel.Result;

public class GitCloneTask extends AsyncTask<String, Void, Void> {
    private Result result;

    public GitCloneTask(Result _result) {
        result = _result;
    }

    protected Void doInBackground(String... params) {
        String url = params[0];
        String filesDir = params[1];
        File directory = new File(filesDir + "/git");

        try {
            Git git = Git.cloneRepository()
                    .setURI(url)
                    .setDirectory(directory)
                    .call();
        }
        catch (GitAPIException e) {
            System.err.println("Error Cloning repository " + url + " : "+ e.getMessage());
        }
        return null;
    }

    protected void onPostExecute(Void taskResult) {
        result.success(null);
    }
}
