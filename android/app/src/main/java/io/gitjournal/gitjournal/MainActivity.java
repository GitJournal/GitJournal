package io.gitjournal.gitjournal;

import android.content.Context;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;
import android.view.WindowManager;

import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.util.PathUtils;

// For MethodChannel

public class MainActivity extends FlutterActivity implements MethodCallHandler {
    private static final String CHANNEL_NAME = "gitjournal.io/git";
    static MethodChannel channel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        channel = new MethodChannel(getFlutterView(), CHANNEL_NAME);
        channel.setMethodCallHandler(this);

        Git g = new Git();
        g.setupLib();
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        Context context = getApplicationContext();
        final String filesDir = PathUtils.getFilesDir(context);
        final String sshKeysLocation = filesDir + "/ssh";
        final String privateKeyPath = sshKeysLocation + "/id_rsa";
        final String publicKeyPath = sshKeysLocation + "/id_rsa.pub";

        Log.d("GitJournalAndroid", "Called method " + call.method);
        if (call.arguments instanceof Map) {
            Map<String, Object> map = (Map<String, Object>) call.arguments;
            for (Map.Entry<String, Object> entry : map.entrySet()) {
                Object val = entry.getValue();
                String objVal = "";
                if (val != null) {
                    objVal = val.toString();
                }
                Log.d("GitJournalAndroid", ".  " + entry.getKey() + ": " + val);
            }
        }

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

            AnyThreadResult anyResult = new AnyThreadResult(result);
            new GitCloneTask(anyResult).execute(cloneUrl, cloneLocation, publicKeyPath, privateKeyPath);
            return;
        } else if (call.method.equals("gitPull")) {
            String folderName = call.argument("folderName");
            String authorName = call.argument("authorName");
            String authorEmail = call.argument("authorEmail");

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

            String cloneLocation = filesDir + "/" + folderName;

            AnyThreadResult anyResult = new AnyThreadResult(result);
            new GitPullTask(anyResult).execute(cloneLocation, publicKeyPath, privateKeyPath, authorName, authorEmail);
            return;
        } else if (call.method.equals("gitPush")) {
            String folderName = call.argument("folderName");

            if (folderName == null || folderName.isEmpty()) {
                result.error("Invalid Parameters", "folderName Invalid", null);
                return;
            }

            String cloneLocation = filesDir + "/" + folderName;

            AnyThreadResult anyResult = new AnyThreadResult(result);
            new GitPushTask(anyResult).execute(cloneLocation, publicKeyPath, privateKeyPath);
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

            AnyThreadResult anyResult = new AnyThreadResult(result);
            new GitAddTask(anyResult).execute(cloneLocation, filePattern);
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

            AnyThreadResult anyResult = new AnyThreadResult(result);
            new GitRmTask(anyResult).execute(cloneLocation, filePattern);
            return;
        } else if (call.method.equals("gitCommit")) {
            String folderName = call.argument("folderName");
            String authorName = call.argument("authorName");
            String authorEmail = call.argument("authorEmail");
            String message = call.argument("message");
            String dateTimeStr = call.argument("when");

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

            AnyThreadResult anyResult = new AnyThreadResult(result);
            new GitCommitTask(anyResult).execute(cloneLocation, authorName, authorEmail, message, dateTimeStr);
            return;
        } else if (call.method.equals("gitInit")) {
            String folderName = call.argument("folderName");

            if (folderName == null || folderName.isEmpty()) {
                result.error("Invalid Parameters", "folderName Invalid", null);
                return;
            }

            String initLocation = filesDir + "/" + folderName;

            AnyThreadResult anyResult = new AnyThreadResult(result);
            new GitInitTask(anyResult).execute(initLocation);
            return;
        } else if (call.method.equals("gitResetLast")) {
            String folderName = call.argument("folderName");

            if (folderName == null || folderName.isEmpty()) {
                result.error("Invalid Parameters", "folderName Invalid", null);
                return;
            }

            String cloneLocation = filesDir + "/" + folderName;

            AnyThreadResult anyResult = new AnyThreadResult(result);
            new GitResetLastTask(anyResult).execute(cloneLocation);
            return;
        } else if (call.method.equals("generateSSHKeys")) {
            String comment = call.argument("comment");
            if (comment == null || comment.isEmpty()) {
                Log.d("generateSSHKeys", "Defaulting to default comment");
                comment = "Generated on Android";
            }

            AnyThreadResult anyResult = new AnyThreadResult(result);
            new GenerateSSHKeysTask(anyResult).execute(sshKeysLocation, comment);
            return;
        } else if (call.method.equals("getSSHPublicKey")) {
            String publicKey = "";
            try {
                publicKey = FileUtils.readFileToString(new File(publicKeyPath), Charset.defaultCharset());
            } catch (IOException ex) {
                Log.d("getSSHPublicKey", ex.toString());
                result.error("FAILED", "Failed to read the public key", null);
                return;
            }

            result.success(publicKey);
            return;
        } else if (call.method.equals("setSshKeys")) {
            String privateKey = call.argument("privateKey");
            String publicKey = call.argument("publicKey");

            if (privateKey == null || privateKey.isEmpty()) {
                result.error("Invalid Parameters", "privateKey Invalid", null);
                return;
            }

            if (publicKey == null || publicKey.isEmpty()) {
                result.error("Invalid Parameters", "publicKey Invalid", null);
                return;
            }

            try {
                FileUtils.writeStringToFile(new File(publicKeyPath), publicKey, Charset.defaultCharset());
                FileUtils.writeStringToFile(new File(privateKeyPath), privateKey, Charset.defaultCharset());
            } catch (IOException ex) {
                Log.d("setSshKeys", ex.toString());
                result.error("FAILED", "Failed to write the ssh keys", null);
                return;
            }

            result.success(publicKey);
            return;
        } else if (call.method.equals("dumpAppLogs")) {
            String filePath = filesDir + "/app-logs.txt";

            try {
                LogDumper.dumpLogs(filePath);
            } catch (Exception e) {
                e.printStackTrace();
                result.error("FAILED", e.toString(), null);
                return;
            }

            result.success(filePath);
            return;
        } else if (call.method.equals("shouldEnableAnalytics")) {
            boolean shouldBe = true;
            String testLabSetting =
                    Settings.System.getString(context.getContentResolver(), "firebase.test.lab");
            if ("true".equals(testLabSetting)) {
                shouldBe = false;
            }

            if (BuildConfig.DEBUG) {
                shouldBe = false;
            }

            result.success(shouldBe);
            return;
        }

        result.notImplemented();
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (BuildConfig.DEBUG) {
            Log.d("SCREEN", "Keeping screen in debug mode");
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        }
    }
}
