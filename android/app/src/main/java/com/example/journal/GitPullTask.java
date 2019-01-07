package com.example.journal;

import android.os.AsyncTask;
import android.util.Log;

import org.eclipse.jgit.api.Git;
import org.eclipse.jgit.api.errors.GitAPIException;
import org.eclipse.jgit.lib.Repository;

import org.eclipse.jgit.api.PullCommand;
import org.eclipse.jgit.api.TransportConfigCallback;
import org.eclipse.jgit.api.errors.TransportException;
import org.eclipse.jgit.transport.Transport;
import org.eclipse.jgit.transport.SshTransport;

import org.eclipse.jgit.transport.JschConfigSessionFactory;
import org.eclipse.jgit.transport.SshSessionFactory;
import org.eclipse.jgit.transport.OpenSshConfig.Host;
import org.eclipse.jgit.util.FS;

import com.jcraft.jsch.Session;
import com.jcraft.jsch.*;

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
            final SshSessionFactory sshSessionFactory = new JschConfigSessionFactory() {
                protected void configure(Host host, Session session) {
                    session.setConfig("StrictHostKeyChecking", "no");
                }

                protected JSch createDefaultJSch(FS fs) throws JSchException {

                    class MyLogger implements com.jcraft.jsch.Logger {
                        java.util.Hashtable name;

                        MyLogger() {
                            name = new java.util.Hashtable();
                            name.put(new Integer(DEBUG), "DEBUG: ");
                            name.put(new Integer(INFO), "INFO: ");
                            name.put(new Integer(WARN), "WARN: ");
                            name.put(new Integer(ERROR), "ERROR: ");
                            name.put(new Integer(FATAL), "FATAL: ");
                        }


                        public boolean isEnabled(int level) {
                            return true;
                        }

                        public void log(int level, String message) {
                            System.err.print(name.get(new Integer(level)));
                            System.err.println(message);
                        }
                    }
                    JSch.setLogger(new MyLogger());

                    JSch defaultJSch = super.createDefaultJSch(fs);
                    defaultJSch.addIdentity(privateKeyPath);

                    JSch.setConfig("PreferredAuthentications", "publickey");

                    Log.d("identityNames", defaultJSch.getIdentityNames().toString());
                    return defaultJSch;
                }
            };

            Git git = Git.open(cloneDir);

            PullCommand pullCommand = git.pull();
            pullCommand.setTransportConfigCallback(new TransportConfigCallback() {
                @Override
                public void configure(Transport transport) {
                    SshTransport sshTransport = (SshTransport) transport;
                    sshTransport.setSshSessionFactory(sshSessionFactory);
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
