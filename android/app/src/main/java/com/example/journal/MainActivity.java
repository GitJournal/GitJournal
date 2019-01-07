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


// For EventChannel
import io.flutter.plugin.common.EventChannel;

import io.flutter.util.PathUtils;


public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "gitjournal.io/git";
    private static final String STREAM_CLONE_CHANNEL = "gitjournal.io/gitClone";

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
                            String folderName = call.argument("folderName");

                            if (cloneUrl.isEmpty() || folderName.isEmpty()) {
                                result.error("Invalid Parameters", "Arguments Invalid", null);
                                return;
                            }

                            String filesDir = PathUtils.getFilesDir(getApplicationContext());
                            String cloneLocation = filesDir + "/" + folderName;

                            final String privateKeyPath = filesDir + "/ssh/id_rsa";
                            new GitCloneTask(result).execute(cloneUrl, cloneLocation, privateKeyPath);
                            return;
                        }

                        if (call.method.equals("gitPull")) {
                            String folderName = call.argument("folderName");

                            if (folderName.isEmpty()) {
                                result.error("Invalid Parameters", "Arguments Invalid", null);
                                return;
                            }

                            String filesDir = PathUtils.getFilesDir(getApplicationContext());
                            String cloneLocation = filesDir + "/" + folderName;

                            final String privateKeyPath = filesDir + "/ssh/id_rsa";
                            new GitPullTask(result).execute(cloneLocation, privateKeyPath);
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

        new EventChannel(getFlutterView(), STREAM_CLONE_CHANNEL).setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object args, final EventChannel.EventSink events) {
                        Log.w("CloneStream", "adding listener");
                    }

                    @Override
                    public void onCancel(Object args) {
                        Log.w("CloneStream", "cancelling listener");
                    }
                }
        );
    }

}
