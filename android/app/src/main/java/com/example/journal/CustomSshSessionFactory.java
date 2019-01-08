package io.gitjournal.gitjournal;

import android.util.Log;

import com.jcraft.jsch.JSch;
import com.jcraft.jsch.JSchException;
import com.jcraft.jsch.Session;

import org.eclipse.jgit.transport.JschConfigSessionFactory;
import org.eclipse.jgit.transport.OpenSshConfig;
import org.eclipse.jgit.util.FS;

public class CustomSshSessionFactory extends JschConfigSessionFactory {
    private String privateKeyPath;

    public CustomSshSessionFactory(String privateKeyPath_) {
        privateKeyPath = privateKeyPath_;
    }

    protected void configure(OpenSshConfig.Host host, Session session) {
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
}
