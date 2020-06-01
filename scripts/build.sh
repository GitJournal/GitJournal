#!/usr/bin/env bash

set -eux

BUILD_NUM=`git rev-list --count HEAD`
echo "Build Number: $BUILD_NUM"

flutter build appbundle --flavor prod --build-number=$BUILD_NUM --verbose
