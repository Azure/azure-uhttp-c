#!/bin/bash
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

set -e

script_dir=$(cd "$(dirname "$0")" && pwd)
build_root=$(cd "${script_dir}/.." && pwd)
build_folder=$build_root"/cmake/uhttp"

CORES=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || sysctl -n hw.ncpu)

rm -r -f $build_folder
mkdir -p $build_folder
pushd $build_folder
cmake ../.. -Drun_unittests:bool=ON -DCMAKE_C_FLAGS="-Wno-typedef-redefinition" -G Xcode
cmake --build . -- --jobs=$CORES
ctest -C "debug" -V --output-on-failure || {
    echo '===== ctest failed; direct invocation =====';
    find . -path '*/Testing*' -prune -o -type f \( -name '*_ut_exe' -o -name '*_ut' \) -perm -u+x -print 2>/dev/null | while read t; do
        echo ">>> $t"; "$t" 2>&1 || echo "[exit=$?]";
    done;
    exit 1;
}
popd
