#!/usr/bin/env bash

set -euv

clang -g test.c gitjournal.c -lgit2
