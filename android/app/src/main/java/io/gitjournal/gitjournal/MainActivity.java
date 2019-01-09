package io.gitjournal.gitjournal;

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
                        final String filesDir = PathUtils.getFilesDir(getApplicationContext());
                        final String sshKeysLocation = filesDir + "/ssh";
                        final String privateKeyPath = sshKeysLocation + "/id_rsa";

                        if (call.method.equals("getBaseDirectory")) {
                            result.success(filesDir);
                            return;
                        } else if (call.method.equals("gitClone")) {
                            String cloneUrl = call.argument("cloneUrl");
                            String folderName = call.argument("folderName");

                            if (cloneUrl.isEmpty() || folderName.isEmpty()) {
                                result.error("Invalid Parameters", "Arguments Invalid", null);
                                return;
                            }

                            String cloneLocation = filesDir + "/" + folderName;

                            new GitCloneTask(result).execute(cloneUrl, cloneLocation, privateKeyPath);
                            return;
                        } else if (call.method.equals("gitPull")) {
                            String folderName = call.argument("folderName");

                            if (folderName.isEmpty()) {
                                result.error("Invalid Parameters", "Arguments Invalid", null);
                                return;
                            }

                            String cloneLocation = filesDir + "/" + folderName;

                            new GitPullTask(result).execute(cloneLocation, privateKeyPath);
                            return;
                        } else if (call.method.equals("gitPush")) {
                            String folderName = call.argument("folderName");

                            if (folderName.isEmpty()) {
                                result.error("Invalid Parameters", "Arguments Invalid", null);
                                return;
                            }

                            String cloneLocation = filesDir + "/" + folderName;

                            new GitPushTask(result).execute(cloneLocation, privateKeyPath);
                            return;
                        } else if (call.method.equals("gitAdd")) {
                            String folderName = call.argument("folderName");
                            String filePattern = call.argument("filePattern");

                            if (folderName.isEmpty() || filePattern.isEmpty()) {
                                result.error("Invalid Parameters", "Arguments Invalid", null);
                                return;
                            }

                            String cloneLocation = filesDir + "/" + folderName;

                            new GitAddTask(result).execute(cloneLocation, filePattern);
                            return;
                        } else if (call.method.equals("gitRm")) {
                            String folderName = call.argument("folderName");
                            String filePattern = call.argument("filePattern");

                            if (folderName.isEmpty() || filePattern.isEmpty()) {
                                result.error("Invalid Parameters", "Arguments Invalid", null);
                                return;
                            }

                            String cloneLocation = filesDir + "/" + folderName;

                            new GitRmTask(result).execute(cloneLocation, filePattern);
                            return;
                        } else if (call.method.equals("gitCommit")) {
                            String folderName = call.argument("folderName");
                            String authorName = call.argument("authorName");
                            String authorEmail = call.argument("authorEmail");
                            String message = call.argument("message");

                            if (folderName.isEmpty() || authorName.isEmpty() || authorEmail.isEmpty() || message.isEmpty()) {
                                result.error("Invalid Parameters", "Arguments Invalid", null);
                                return;
                            }

                            String cloneLocation = filesDir + "/" + folderName;

                            new GitCommitTask(result).execute(cloneLocation, authorName, authorEmail, message);
                            return;
                        } else if (call.method.equals("generateSSHKeys")) {
                            String comment = call.argument("comment");
                            if (comment == null || comment.isEmpty()) {
                                comment = "Generated on Android";
                            }

                            new GenerateSSHKeysTask(result).execute(sshKeysLocation, comment);
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
