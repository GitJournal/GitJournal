// SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

package io.gitjournal.gitjournal;

import android.os.Bundle;
import android.util.Log;
import android.app.Activity;
import android.net.*;

import android.content.Intent;

import java.util.HashMap;
import java.util.Map;

public class UriReceiverActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Uri data = getIntent().getData();

        Map<String, Object> map = new HashMap<>();
        map.put("URL", data.toString());

        MainActivity.channel.invokeMethod("onURL", map);

        // Now that all data has been sent back to Dart-land, we should re-open the Flutter
        // activity. Due to the manifest-setting of the MainActivity ("singleTop), only a single
        // instance will exist, popping the old one back up and destroying the preceding
        // activities on the backstack, such as the custom tab.
        // Flags taken from how the AppAuth-library accomplishes the same thing
        Intent mainIntent = new Intent(this, MainActivity.class);
        mainIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        startActivity(mainIntent);
        finish();
    }

}
