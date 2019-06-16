# Building LLVM for Android

This repository contains scripts and instructions for cross-compiling LLVM for use on Android Devices.

## Note
Cross-compiling LLVM requires at a minimum that llvm-tblgen be compiled for the Host Machine.  The (build_llvm_host.ps1)[build_llvm_host.ps1] attempts to build the minimum binaries necessary to successfully compile llvm-tblgen for the Host Machine to be used in our Cross-compilation.  That script can be modified to build larger parts of the LLVM Codebase if necessary.

## Requirements
  - CMake - (https://cmake.org/download/)[https://cmake.org/download/]
  - Visual Studio 2019 -or- MSVC Toolchain
  - Bash Command Prompt

## Steps
  - Download latest release of LLVM Source Code from (http://releases.llvm.org/)[http://releases.llvm.org/]
  - Open the LLVM Source Code Archive and extract the contents (not the actual folder) of the 'llvm-x.x.x.src' to /llvm-src/
  - Execute the (build_llvm_host.ps1)[build_llvm_host.ps1] script via PowerShell
  - Execute the (build_llvm_android.sh)[build_llvm_android.sh] script via Bash Prompt
  - Resulting files are in /llvm-build-android/
