#!/usr/bin/env bash

set -euv

clang git.c -lgit2 -lssh2
