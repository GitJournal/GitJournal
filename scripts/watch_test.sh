#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

set -eu

# Runs the test which is marked with solo

FILENAME=$(grep -rn solo test/* | awk -F ':' '{ print $1 }')
LINE_NUM=$(grep -rn solo test/* | awk -F ':' '{ print $2 }')

FUNC_NAME=""
while [[ -z $FUNC_NAME ]]; do
    LINE_NUM=$((LINE_NUM - 1))
    LINE=$(sed -n ${LINE_NUM}p test/autocompletion/tags_test.dart)
    FUNC_NAME=$(echo "$LINE" | sed -n -E "s#test\([\"'](.+)[\"'].*#\1#p" | xargs)
done

echo flutter test --name "$FUNC_NAME" "$FILENAME"
find . -name '*.dart' | entr flutter test --name "$FUNC_NAME" "$FILENAME"
