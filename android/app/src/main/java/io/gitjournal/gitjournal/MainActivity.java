package io.gitjournal.gitjournal;

import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;

import android.os.Bundle;
import android.util.Log;

import org.apache.commons.io.FileUtils;

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

                            if (cloneUrl == null || cloneUrl.isEmpty()) {
                                result.error("Invalid Parameters", "cloneUrl Invalid", null);
                                return;
                            }
                            if (folderName == null || folderName.isEmpty()) {
                                result.error("Invalid Parameters", "folderName Invalid", null);
                                return;
                            }

                            String cloneLocation = filesDir + "/" + folderName;

                            new GitCloneTask(result).execute(cloneUrl, cloneLocation, privateKeyPath);
                            return;
                        } else if (call.method.equals("gitPull")) {
                            String folderName = call.argument("folderName");

                            if (folderName == null || folderName.isEmpty()) {
                                result.error("Invalid Parameters", "folderName Invalid", null);
                                return;
                            }

                            String cloneLocation = filesDir + "/" + folderName;

                            new GitPullTask(result).execute(cloneLocation, privateKeyPath);
                            return;
                        } else if (call.method.equals("gitPush")) {
                            String folderName = call.argument("folderName");

                            if (folderName == null || folderName.isEmpty()) {
                                result.error("Invalid Parameters", "folderName Invalid", null);
                                return;
                            }

                            String cloneLocation = filesDir + "/" + folderName;

                            new GitPushTask(result).execute(cloneLocation, privateKeyPath);
                            return;
                        } else if (call.method.equals("gitAdd")) {
                            String folderName = call.argument("folderName");
                            String filePattern = call.argument("filePattern");

                            if (folderName == null || folderName.isEmpty()) {
                                result.error("Invalid Parameters", "folderName Invalid", null);
                                return;
                            }
                            if (filePattern == null || filePattern.isEmpty()) {
                                result.error("Invalid Parameters", "filePattern Invalid", null);
                                return;
                            }

                            String cloneLocation = filesDir + "/" + folderName;

                            new GitAddTask(result).execute(cloneLocation, filePattern);
                            return;
                        } else if (call.method.equals("gitRm")) {
                            String folderName = call.argument("folderName");
                            String filePattern = call.argument("filePattern");

                            if (folderName == null || folderName.isEmpty()) {
                                result.error("Invalid Parameters", "folderName Invalid", null);
                                return;
                            }
                            if (filePattern == null || filePattern.isEmpty()) {
                                result.error("Invalid Parameters", "filePattern Invalid", null);
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

                            if (folderName == null || folderName.isEmpty()) {
                                result.error("Invalid Parameters", "folderName Invalid", null);
                                return;
                            }
                            if (authorName == null || authorName.isEmpty()) {
                                result.error("Invalid Parameters", "authorName Invalid", null);
                                return;
                            }
                            if (authorEmail == null || authorEmail.isEmpty()) {
                                result.error("Invalid Parameters", "authorEmail Invalid", null);
                                return;
                            }
                            if (message == null || message.isEmpty()) {
                                result.error("Invalid Parameters", "message Invalid", null);
                                return;
                            }

                            String cloneLocation = filesDir + "/" + folderName;

                            new GitCommitTask(result).execute(cloneLocation, authorName, authorEmail, message);
                            return;
                        } else if (call.method.equals("gitInit")) {
                            String folderName = call.argument("folderName");

                            if (folderName == null || folderName.isEmpty()) {
                                result.error("Invalid Parameters", "folderName Invalid", null);
                                return;
                            }

                            String initLocation = filesDir + "/" + folderName;

                            new GitInitTask(result).execute(initLocation);
                            return;
                        } else if (call.method.equals("generateSSHKeys")) {
                            String comment = call.argument("comment");
                            if (comment == null || comment.isEmpty()) {
                                Log.d("generateSSHKeys", "Defaulting to default comment");
                                comment = "Generated on Android";
                            }

                            new GenerateSSHKeysTask(result).execute(sshKeysLocation, comment);
                            return;
                        } else if (call.method.equals("getSSHPublicKey")) {
                            final String publicKeyPath = sshKeysLocation + "/id_rsa.pub";

                            String publicKey = "";
                            try {
                                publicKey = FileUtils.readFileToString(new File(publicKeyPath), Charset.defaultCharset());
                            } catch (IOException ex) {
                                Log.d("getSSHPublicKey", ex.toString());
                                result.error("FAILED", "Failed to read the public key", null);
                            }

                            result.success(publicKey);
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
