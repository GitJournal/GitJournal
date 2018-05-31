package com.example.journal;

import java.io.File;

import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

// For MethodChannel
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

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

            gitClone(cloneUrl, filePath);
            result.success(null);
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

  private void gitClone(String url, String filePath) {
    // TODO: Progress
    // TODO: Credentials
    // TODO: Handle errors!
    File directory = new File(filePath);

    try {
      Git git = Git.cloneRepository()
              .setURI(url)
              .setDirectory(directory)
              .call();
    }
    catch (GitAPIException e) {
      System.err.println("Error Cloning repository " + url + " : "+ e.getMessage());
    }
  }
}
