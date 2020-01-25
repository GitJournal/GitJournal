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

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity implements MethodCallHandler {
    private static final String CHANNEL_NAME = "gitjournal.io/git";
    static MethodChannel channel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        channel = new MethodChannel(getFlutterView(), CHANNEL_NAME);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        Context context = getApplicationContext();
        final String filesDir = PathUtils.getFilesDir(context);

        if (call.method.equals("getBaseDirectory")) {
            result.success(filesDir);
            return;
        }

        result.notImplemented();
    }
}
