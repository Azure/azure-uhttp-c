@REM Copyright (c) Microsoft. All rights reserved.
@REM Licensed under the MIT license. See LICENSE file in the project root for full license information.

@setlocal EnableExtensions EnableDelayedExpansion
@echo off

set current-path=%~dp0
rem // remove trailing slash
set current-path=%current-path:~0,-1%

echo Current Path: %current-path%

set build-root=%current-path%\..
rem // resolve to fully qualified path
for %%i in ("%build-root%") do set build-root=%%~fi

set repo_root=%build-root%
rem // resolve to fully qualified path
for %%i in ("%repo_root%") do set repo_root=%%~fi

set CMAKE_DIR=uhttp_win32
set build-config=Debug
set build-platform=Win32

echo Build Root: %build-root%
echo Repo Root: %repo_root%

rem //begin building

if EXIST %build-root%\cmake\%CMAKE_DIR% (
    rmdir /s/q %build-root%\cmake\%CMAKE_DIR%
    rem no error checking
)

echo CMAKE Output Path: %build-root%\cmake\%CMAKE_DIR%
mkdir %build-root%\cmake\%CMAKE_DIR%
rem no error checking
pushd %build-root%\cmake\%CMAKE_DIR%

echo ***checking msbuild***
where msbuild

if %build-platform% == x64 (
    echo ***Running CMAKE for Win64***
    cmake %build-root% -LAH -Duse_cppunittest:BOOL=OFF -Drun_unittests:BOOL=ON -A x64 -G %VSVERSION%
) else (
    echo ***Running CMAKE for Win32***
    cmake %build-root% -LAH -Duse_cppunittest:BOOL=OFF -Drun_unittests:BOOL=ON -A Win32 -G %VSVERSION%
)
if not !ERRORLEVEL!==0 exit /b !ERRORLEVEL!

msbuild /m uhttp.sln "/p:Configuration=%build-config%;Platform=%build-platform%"
if !ERRORLEVEL! neq 0 exit /b !ERRORLEVEL!

if %build-platform% neq arm (
    ctest -C "debug" -V
    if not !ERRORLEVEL!==0 exit /b !ERRORLEVEL!
)

popd