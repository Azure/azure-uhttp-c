#Copyright (c) Microsoft. All rights reserved.
#Licensed under the MIT license. See LICENSE file in the project root for full license information.

cmake_minimum_required(VERSION 3.5)

usePermissiveRulesForSamplesAndTests()

if (TARGET c_logging_v2)
    link_libraries(c_logging_v2)
endif()

add_unittest_directory(uhttp_ut)