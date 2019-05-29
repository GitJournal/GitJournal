#!/usr/bin/env bash

set -eux

LIBGIT2_VERSION="0.28.1"
if [ ! -f "libgit2.tar.gz" ]; then
    curl https://codeload.github.com/libgit2/libgit2/tar.gz/v${LIBGIT2_VERSION} -o libgit2.tar.gz
fi

tar -xzf libgit2.tar.gz
cd libgit2-${LIBGIT2_VERSION}

mkdir build
cd build

cmake ../ \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \

if [ $? -ne 0 ]; then
    echo "Error executing cmake"
    exit 1
fi

cmake --build .

if [ $? -ne 0 ]; then
    echo "Error building"
    exit 1
fi

make install
