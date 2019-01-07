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

import org.eclipse.jgit.transport.JschConfigSessionFactory;
import org.eclipse.jgit.transport.SshSessionFactory;
import org.eclipse.jgit.transport.OpenSshConfig.Host;
import org.eclipse.jgit.util.FS;

import org.eclipse.jgit.lib.TextProgressMonitor;

import java.io.PrintWriter;

import com.jcraft.jsch.Session;
import com.jcraft.jsch.*;

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

            CloneCommand cloneCommand = Git.cloneRepository()
                    .setURI(url)
                    .setDirectory(cloneDir)
                    .setProgressMonitor(new TextProgressMonitor(new PrintWriter(System.out)));

            cloneCommand.setTransportConfigCallback(new TransportConfigCallback() {
                @Override
                public void configure(Transport transport) {
                    SshTransport sshTransport = (SshTransport) transport;
                    sshTransport.setSshSessionFactory(sshSessionFactory);
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
