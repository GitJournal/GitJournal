#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

cd "$(dirname "$0")"

kill -USR1 $(cat /tmp/flutter.pid)
echo "-----------------"
echo ""
echo "  APP RELOADED  "
echo ""
echo "-----------------"
