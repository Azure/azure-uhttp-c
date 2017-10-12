#Copyright (c) Microsoft. All rights reserved.
#Licensed under the MIT license. See LICENSE file in the project root for full license information.

cmake_minimum_required(VERSION 2.8.11)

project(uhttp)

option(run_e2e_tests "set run_e2e_tests to ON to run e2e tests (default is OFF)" OFF)
option(run_unittests "set run_unittests to ON to run unittests (default is OFF)" OFF)
option(skip_samples "set skip_samples to ON to skip building samples (default is OFF)[if possible, they are always built]" OFF)

# Include the common build rules for the C SDK
include(deps/c-utility/configs/azure_iot_build_rules.cmake)

set(UHTTP_C_INC_FOLDER ${CMAKE_CURRENT_LIST_DIR}/inc CACHE INTERNAL "this is what needs to be included if using sharedLib lib" FORCE)

add_subdirectory(./deps/c-utility)
set_platform_files(${CMAKE_CURRENT_LIST_DIR}/deps/c-utility)

set(uhttp_c_files
    ./src/uhttp.c
)

set(uhttp_h_files
    ./inc/azure_uhttp_c/uhttp.h
)

include_directories(./inc)
include_directories(${SHARED_UTIL_INC_FOLDER})

include("configs/azure_uhttpFunctions.cmake")

add_library(uhttp ${uhttp_c_files} ${uhttp_h_files})
target_link_libraries(uhttp aziotsharedutil)

if (${run_unittests})
    add_subdirectory(tests)
endif()

if (NOT ${skip_samples})
    add_subdirectory(samples)
endif()