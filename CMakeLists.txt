#Copyright (c) Microsoft. All rights reserved.
#Licensed under the MIT license. See LICENSE file in the project root for full license information.

cmake_minimum_required(VERSION 2.8.11)

project(uhttp)

option(run_e2e_tests "set run_e2e_tests to ON to run e2e tests (default is OFF)" OFF)
option(run_unittests "set run_unittests to ON to run unittests (default is OFF)" OFF)
option(skip_samples "set skip_samples to ON to skip building samples (default is OFF)[if possible, they are always built]" OFF)

# Include the common build rules for the C SDK
include(deps/c-utility/configs/azure_iot_build_rules.cmake)

if(${use_openssl})
    add_definitions(-DUSE_OPENSSL)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DUSE_OPENSSL")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DUSE_OPENSSL")
endif()

#Use solution folders.
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

enable_testing()

if(MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4")
endif()

compileAsC99()

set(UHTTP_C_INC_FOLDER ${CMAKE_CURRENT_LIST_DIR}/inc CACHE INTERNAL "this is what needs to be included if using sharedLib lib" FORCE)

#do not add or build any tests of the dependencies
set(original_run_e2e_tests ${run_e2e_tests})
set(original_run_unittests ${run_unittests})

set(run_e2e_tests OFF)
set(run_unittests OFF)

if(NOT WIN32)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DUSE_OPENSSL")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DUSE_OPENSSL")
endif()

add_subdirectory(./deps/c-utility)

set(SHARED_UTIL_REAL_TEST_FOLDER ${CMAKE_CURRENT_LIST_DIR}/deps/c-utility/tests/real_test_files CACHE INTERNAL "this is what needs to be included when doing test sources" FORCE)

if (${original_run_e2e_tests} OR ${original_run_unittests})
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/deps/c-utility/testtools)
endif()

set_platform_files(${CMAKE_CURRENT_LIST_DIR}/deps/c-utility)

set(run_e2e_tests ${original_run_e2e_tests})
set(run_unittests ${original_run_unittests})

if (MSVC)
    detect_architecture("_M_AMD64" x86_64)
    detect_architecture("_M_IX86" x86)
    detect_architecture("_M_ARM" ARM)
else()
    detect_architecture("__x86_64__" x86_64)
    detect_architecture("__i386__" x86)
    detect_architecture("__arm__" ARM)
endif()
if (NOT DEFINED ARCHITECTURE OR ARCHITECTURE STREQUAL "")
    set(ARCHITECTURE "GENERIC")
endif()
message(STATUS "target architecture: ${ARCHITECTURE}")

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