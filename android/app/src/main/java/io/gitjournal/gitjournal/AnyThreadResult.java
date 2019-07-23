package io.gitjournal.gitjournal;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.Nullable;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

public class AnyThreadResult implements MethodChannel.Result {
    private Result result;

    AnyThreadResult(Result r) {
        result = r;
    }

    public void success(@Nullable Object var1) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                result.success(var1);
            }
        });
    }

    public void error(String var1, @Nullable String var2, @Nullable Object var3) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                result.error(var1, var2, var3);
            }
        });
    }

    public void notImplemented() {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                result.notImplemented();
            }
        });
    }
}
