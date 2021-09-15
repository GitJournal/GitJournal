#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

set -eu pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$SCRIPT_DIR/.."

touch ~/.android/repositories.cfg

MIN_API_VERSION=21
MAX_API_VERSION=28

# Download all Images
for i in $(seq $MIN_API_VERSION $MAX_API_VERSION); do
    echo "Downling SDK $i"
    sdkmanager "system-images;android-$i;google_apis;x86"
done

for i in $(seq $MIN_API_VERSION $MAX_API_VERSION); do
    echo "Creating device for API $i"

    NAME="gitjournal_test_api_$i"
    echo no | avdmanager create avd -n "$NAME" -f -k "system-images;android-$i;google_apis;x86"

    # Launch the device
    emulator -ports 5570,5571 -avd "$NAME" &
    EMULATOR_PID=$!

    echo
    echo "Waiting for device to boot"
    echo
    adb wait-for-device
    adb -s emulator-5570 shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done; input keyevent 82'

    # Run the test
    echo
    echo "Running the Test"
    echo
    flutter drive --target=test_driver/git.dart

    echo "Shutting down the device"
    adb -s emulator-5570 emu kill
    kill -9 $EMULATOR_PID
    avdmanager delete avd -n "$NAME"
done
