#!/usr/bin/env bash

set -eu

trap ctrl_c INT

function ctrl_c() {
    echo "To fetch the script run -"
    echo "adb pull /sdcard/video.mp4"
    echo "adb shell rm /sdcard/video.mp4"
}

echo "Recording ..."
adb shell screenrecord --verbose /sdcard/video.mp4

