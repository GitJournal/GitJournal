package io.gitjournal.gitjournal;

import android.os.AsyncTask;
import android.util.Log;

import org.eclipse.jgit.api.Git;
import org.eclipse.jgit.api.errors.GitAPIException;

import org.eclipse.jgit.api.CommitCommand;
import org.eclipse.jgit.api.errors.TransportException;
import org.eclipse.jgit.lib.PersonIdent;

import java.io.File;
import java.util.*;
import java.text.SimpleDateFormat;
import java.util.TimeZone;
import java.util.SimpleTimeZone;

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
        final String commitDateTimeStr = params[4];

        File cloneDir = new File(cloneDirPath);
        Log.d("GitClone Directory", cloneDirPath);

        try {
            Git git = Git.open(cloneDir);

            PersonIdent identity = new PersonIdent(authorName, authorEmail);
            if (commitDateTimeStr != null && !commitDateTimeStr.isEmpty()) {
                Log.d(TAG, "CustomDateTime: " + commitDateTimeStr);
                SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
                Date date = format.parse(commitDateTimeStr);
                TimeZone tz = identity.getTimeZone();

                // Check for timezone
                /*
                if (commitDateTimeStr.indexOf('+') == 19) {
                    // FIXME: This does not deal with timezones with minutes!
                    int hours = Integer.parseInt(commitDateTimeStr.substring(20, 22));
                    int minutes = Integer.parseInt(commitDateTimeStr.substring(23));
                    Log.d(TAG, "TimeZone Hours: " + hours);
                    Log.d(TAG, "TimeZone Minutes: " + minutes);

                    tz = new SimpleTimeZone(hours, "foo");
                } else {
                    Log.d(TAG, "No custom timezone provided");

                }
                */
                identity = new PersonIdent(identity, date, tz);
            } else {
                Log.d(TAG, "No custom datetime provided");
            }

            CommitCommand commitCommand = git.commit();
            commitCommand.setAuthor(identity);
            commitCommand.setMessage(message);
            //commitCommand.setAllowEmpty(false);
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
