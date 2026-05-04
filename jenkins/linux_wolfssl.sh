#!/bin/bash
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.

set -e

build_root=$(cd "$(dirname "$0")/.." && pwd)
cd $build_root

build_folder=$build_root"/cmake/shared-util_linux"

# Set the default cores
CORES=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || sysctl -n hw.ncpu)

rm -r -f $build_folder
mkdir -p $build_folder
pushd $build_folder
cmake $build_root -Drun_unittests:BOOL=ON -Duse_wolfssl:BOOL=ON -Duse_openssl:BOOL=OFF -D CMAKE_C_COMPILER=gcc
make --jobs=$CORES

#use doctored openssl
export LD_LIBRARY_PATH=/usr/local/ssl/lib
ctest -j $CORES --output-on-failure || {
    echo '===== ctest failed; direct invocation =====';
    find . -path '*/Testing*' -prune -o -type f \( -name '*_ut_exe' -o -name '*_ut' \) -executable -print 2>/dev/null | while read t; do
        echo ">>> $t"; "$t" 2>&1 || echo "[exit=$?]";
    done;
    exit 1;
}
export LD_LIBRARY_PATH=

popd
