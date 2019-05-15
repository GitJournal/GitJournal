#!/usr/bin/env bash

set -euv

clang test.c gitjournal.c -lgit2
