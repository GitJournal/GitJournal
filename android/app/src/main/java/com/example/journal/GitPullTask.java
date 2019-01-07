package com.example.journal;

import android.os.AsyncTask;
import android.util.Log;

import org.eclipse.jgit.api.Git;
import org.eclipse.jgit.api.errors.GitAPIException;

import org.eclipse.jgit.api.PullCommand;
import org.eclipse.jgit.api.TransportConfigCallback;
import org.eclipse.jgit.api.errors.TransportException;
import org.eclipse.jgit.transport.Transport;
import org.eclipse.jgit.transport.SshTransport;

import java.io.File;

import io.flutter.plugin.common.MethodChannel.Result;

public class GitPullTask extends AsyncTask<String, Void, Void> {
    private final static String TAG = "GitPull";
    private Result result;

    public GitPullTask(Result _result) {
        result = _result;
    }

    protected Void doInBackground(String... params) {
        String cloneDirPath = params[0];
        final String privateKeyPath = params[1];

        File cloneDir = new File(cloneDirPath);
        Log.d("GitClone Directory", cloneDirPath);

        try {
            Git git = Git.open(cloneDir);

            PullCommand pullCommand = git.pull();
            pullCommand.setTransportConfigCallback(new TransportConfigCallback() {
                @Override
                public void configure(Transport transport) {
                    SshTransport sshTransport = (SshTransport) transport;
                    sshTransport.setSshSessionFactory(new CustomSshSessionFactory(privateKeyPath));
                }
            });

            pullCommand.call();
        } catch (TransportException e) {
            Log.d(TAG, e.toString());
            result.error("FAILED", e.toString(), null);
            return null;
        } catch (GitAPIException e) {
            Log.d(TAG, e.toString());
            result.error("FAILED", e.toString(), null);
            return null;
        } catch (Exception e) {
            Log.d(TAG, e.toString());
            result.error("FAILED", e.toString(), null);
            return null;
        }

        result.success(null);
        return null;
    }
}
