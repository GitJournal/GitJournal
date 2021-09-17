#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

set -eu

LATEST_TAG=$(git describe --tags $(git rev-list --tags --max-count=1))
git diff $LATEST_TAG | grep '^+' | grep -e 'Log.[vdiew]' -e print
