#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

cd "$(dirname "$0")"
cd ../

while true
do
    find lib/ -name '*.dart' | \
        entr -d -p ./scripts/reload_run_app.sh
done
