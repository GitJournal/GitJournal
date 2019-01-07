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
  private static final String CHANNEL = "gitjournal.io/git";

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

          if (call.method.equals("generateSSHKeys")) {
            String appFilesDir = PathUtils.getFilesDir(getApplicationContext());
            String sshKeysLocation = appFilesDir + "/ssh";

            new GenerateSSHKeysTask(result).execute(sshKeysLocation);
            return;
          }

          result.notImplemented();
        }
      });
  }

}
