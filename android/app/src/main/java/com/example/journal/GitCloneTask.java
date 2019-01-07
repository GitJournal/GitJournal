package com.example.journal;

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

public class GitCloneTask extends AsyncTask<String, Void, Void> {
    private Result result;

    public GitCloneTask(Result _result) {
        result = _result;
    }

    protected Void doInBackground(String... params) {
        String url = params[0];
        String cloneDirPath = params[1];
        final String privateKeyPath = params[2];

        File cloneDir = new File(cloneDirPath);
        Log.d("GitClone Directory", cloneDirPath);

        try {
            CloneCommand cloneCommand = Git.cloneRepository()
                    .setURI(url)
                    .setDirectory(cloneDir)
                    .setProgressMonitor(new TextProgressMonitor(new PrintWriter(System.out)));

            cloneCommand.setTransportConfigCallback(new TransportConfigCallback() {
                @Override
                public void configure(Transport transport) {
                    SshTransport sshTransport = (SshTransport) transport;
                    sshTransport.setSshSessionFactory(new CustomSshSessionFactory(privateKeyPath));
                }
            });

            cloneCommand.call();
        } catch (TransportException e) {
            Log.d("gitClone", e.toString());
            result.error("FAILED", e.toString(), null);
            return null;
        } catch (GitAPIException e) {
            Log.d("gitClone", e.toString());
            result.error("FAILED", e.toString(), null);
            return null;
        } catch (Exception e) {
            Log.d("gitClone", e.toString());
            result.error("FAILED", e.toString(), null);
            return null;
        }

        result.success(null);
        return null;
    }
}
