#!/usr/bin/env bash

set -eu
genhtml -o coverage coverage/lcov.info
