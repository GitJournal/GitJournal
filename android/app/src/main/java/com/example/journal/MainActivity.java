package com.example.journal;

import java.io.File;

import android.os.Bundle;
import android.util.Log;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

// For MethodChannel
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import io.flutter.util.PathUtils;

import org.eclipse.jgit.api.CloneCommand;
import org.eclipse.jgit.api.Git;
import org.eclipse.jgit.api.errors.GitAPIException;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "samples.flutter.io/battery";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
      new MethodCallHandler() {
        @Override
        public void onMethodCall(MethodCall call, Result result) {
          if (call.method.equals("gitClone")) {
            String cloneUrl = call.argument("cloneUrl");
            String filePath = call.argument("filePath");

            if (cloneUrl.isEmpty() || filePath.isEmpty()) {
              result.error("Invalid Parameters", "Arguments Invalid", null);
              return;
            }

            String filesDir = PathUtils.getFilesDir(getApplicationContext());
            Log.d("vhanda", filesDir);
            String cloneLocation = filesDir + "/git";

            new GitCloneTask(result).execute(cloneUrl, cloneLocation);
            /*
            if (gitClone(cloneUrl, filePath)) {
              result.success(null);
            } else {
              result.error("UNAVAILABLE", "Battery level not available.", null);
            }
            */
            return;
          }

          result.notImplemented();

          // Methods to add
          // git clone
          // git pull - merge by taking newest
          // git add
          // git commit
          // git push
        }
      });
  }

  private boolean gitClone(String url, String filePath) {
    // TODO: Progress
    // TODO: Credentials
    // TODO: Handle errors!

    File directory = new File("/git");

    try {
      Git git = Git.cloneRepository()
              .setURI(url)
              .setDirectory(directory)
              .call();
      return true;
    }
    catch (GitAPIException e) {
      System.err.println("Error Cloning repository " + url + " : "+ e.getMessage());
      return false;
    }
  }

  /*
  private void gitAdd(String gitRootUrl, String gitFileUrl) {
    File directory = new File(gitRootUrl);

    try {
      Git git = Git.open(directory);

      git.add()
        .addFilepattern(gitFileUrl)
        .call();
    }
    catch (GitAPIException e) {
      System.err.println("Error Cloning repository " + url + " : "+ e.getMessage());
    }
    catch (java.io.IOException e) {
      System.err.println("Error Opening GitRepo " + gitRootUrl + " : "+ e.getMessage());
    }
  }

  private void gitRemove(String gitRootUrl, String gitFileUrl) {
    File directory = new File(gitRootUrl);

    try {
      Git git = Git.open(directory);

      git.rm()
        .addFilepattern(gitFileUrl)
        .call();
    }
    catch (GitAPIException e) {
      System.err.println("Error Cloning repository " + url + " : "+ e.getMessage());
    }
    catch (java.io.IOException e) {
      System.err.println("Error Opening GitRepo " + gitRootUrl + " : "+ e.getMessage());
    }
  }

  private void gitCommit(String gitRootUrl, String message) {
    File directory = new File(gitRootUrl);

    try {
      Git git = Git.open(directory);

      git.commit()
        .setAuthor("JournalApp", "none@example.com")
        .setMessage(message)
        .call();
    }
    catch (GitAPIException e) {
      System.err.println("Error Cloning repository " + url + " : "+ e.getMessage());
    }
    catch (java.io.IOException e) {
      System.err.println("Error Opening GitRepo " + gitRootUrl + " : "+ e.getMessage());
    }
  }
  */

}
