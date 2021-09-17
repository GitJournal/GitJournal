#!/usr/bin/env bash

set -eu

LATEST_TAG=$(git describe --tags $(git rev-list --tags --max-count=1))
git diff $LATEST_TAG | grep '^+' | grep -e 'Log.[vdiew]' -e print
