<!--
SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>

SPDX-License-Identifier: CC-BY-4.0
-->

Download them via -

1. Engine version - cat ~/src/flutter/flutter/bin/internal/engine.version

ENGINE_VERSION=$(cat $FLUTTER_HOME/bin/internal/engine.version)

2. wget https://storage.cloud.google.com/flutter_infra/flutter/ee76268252c22f5c11e82a7b87423ca3982e51a7/ios-release/Flutter.dSYM.zip
   
   Replace engine version 

3. Download that file
4. sentry-cli upload-dif --project app  ~/Downloads/flutter_ee76268252c22f5c11e82a7b87423ca3982e51a7_ios-release_Flutter.dSYM.zip

5. Also do it for our own symbols -

   sentry-cli upload-dif --project app Runner.app.dSYM.zip
