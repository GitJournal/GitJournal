#!/usr/bin/env bash

while true
do
    find lib/ -name '*.dart' | \
        entr -d -p kill -USR1 $(cat /tmp/flutter.pid)
done
