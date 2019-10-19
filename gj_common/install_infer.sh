#!/usr/bin/env bash

set -eux

export VERSION=0.17.0
curl -sSL "https://github.com/facebook/infer/releases/download/v$VERSION/infer-linux64-v$VERSION.tar.xz" |
    sudo tar -C /opt -xJ &&
    ln -s "/opt/infer-linux64-v$VERSION/bin/infer" /usr/local/bin/infer
