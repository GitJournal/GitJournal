#!/usr/bin/env bash

set -eux

wget -O flutter.zip https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_2.5.0-stable.zip
unzip flutter.zip
export PATH="$PATH:$(pwd)/flutter/bin"

flutter precache
flutter doctor
