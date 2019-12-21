package io.gitjournal.gitjournal;

import androidx.annotation.NonNull;

import android.content.Context;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;
import android.view.WindowManager;

import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.util.PathUtils;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity implements MethodCallHandler {
    private static final String CHANNEL_NAME = "gitjournal.io/git";
    static MethodChannel channel;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_NAME);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        Context context = getApplicationContext();
        final String filesDir = PathUtils.getFilesDir(context);

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
