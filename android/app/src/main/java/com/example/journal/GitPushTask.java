package io.gitjournal.gitjournal;

import android.os.AsyncTask;
import android.util.Log;

import org.eclipse.jgit.api.Git;
import org.eclipse.jgit.api.errors.GitAPIException;

import org.eclipse.jgit.api.PushCommand;
import org.eclipse.jgit.api.TransportConfigCallback;
import org.eclipse.jgit.api.errors.TransportException;
import org.eclipse.jgit.transport.Transport;
import org.eclipse.jgit.transport.SshTransport;

import java.io.File;

import io.flutter.plugin.common.MethodChannel.Result;

public class GitPushTask extends AsyncTask<String, Void, Void> {
    private final static String TAG = "GitPush";
    private Result result;

    public GitPushTask(Result _result) {
        result = _result;
    }

    protected Void doInBackground(String... params) {
        String cloneDirPath = params[0];
        final String privateKeyPath = params[1];

        File cloneDir = new File(cloneDirPath);
        Log.d("GitClone Directory", cloneDirPath);

        try {
            Git git = Git.open(cloneDir);

            PushCommand pushCommand = git.push();
            pushCommand.setTransportConfigCallback(new TransportConfigCallback() {
                @Override
                public void configure(Transport transport) {
                    SshTransport sshTransport = (SshTransport) transport;
                    sshTransport.setSshSessionFactory(new CustomSshSessionFactory(privateKeyPath));
                }
            });

            pushCommand.call();
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
