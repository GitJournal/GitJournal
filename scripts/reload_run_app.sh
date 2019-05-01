#!/usr/bin/env bash

cd "$(dirname "$0")"

kill -USR1 $(cat /tmp/flutter.pid)
echo "-----------------"
echo ""
echo "  APP RELOADED  "
echo ""
echo "-----------------"
