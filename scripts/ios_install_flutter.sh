#!/usr/bin/env bash

set -eux

wget https://storage.googleapis.com/flutter_infra/releases/stable/macos/flutter_macos_1.22.4-stable.zip
unzip flutter_macos_1.22.4-stable.zip
export PATH="$PATH:$(pwd)/flutter/bin"

flutter precache
flutter doctor
