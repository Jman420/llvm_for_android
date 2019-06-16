#!/bin/bash

AndroidSdkDir="$LOCALAPPDATA/Android/Sdk"
AndroidCmakeExe="$AndroidSdkDir/cmake/3.10.2.4988404/bin/cmake.exe"
AndroidNinjaExe="$AndroidSdkDir/cmake/3.10.2.4988404/bin/ninja.exe"
NdkBundle="$AndroidSdkDir/ndk-bundle/"
ToolchainFile="$NdkBundle/build/cmake/android.toolchain.cmake"
ArchTargets=( "armeabi-v7a" "arm64-v8a" "x86" "x86_64" )
ArchTriples=( "armv7a-linux-androideabi" "aarch64-linux-android" "i686-linux-android" "x86_64-linux-android" )
LlvmTargets=( "ARM" "AArch64" "X86" "X86" )

ProjectRootPath="android-project"
BuildRootPath="android-build"
SourceRootPath="llvm-src"

ArchsLength=${#ArchTargets[*]}
for (( archCounter=0; archCounter < $ArchsLength; archCounter++ ))
do
    archTarget=${ArchTargets[$archCounter]}
    archTriple=${ArchTriples[$archCounter]}
    llvmTarget=${LlvmTargets[$archCounter]}
    projectDir="$ProjectRootPath/$archTarget"
    buildDir="$BuildRootPath/$archTarget"
    buildFullPath=$(realpath "./$buildDir")
    
    if [ -d $projectDir ]
    then
        echo "Removing existing Project directory : $projectDir ..."
        rm -rf "$projectDir"
    fi
    if [ -d $buildDir ]
    then
        echo "Removing existing Project directory : $buildDir ..."
        rm -rf "$buildDir"
    fi
    
    echo "Creating Project directory : $projectDir ..."
    mkdir -p $projectDir
    echo "Creating Build directory : $buildDir ..."
    mkdir -p $buildDir
    
    echo "Generating Project Files for Architecture : $archTarget ..."
    pushd $projectDir
    $AndroidCmakeExe \
        -DLLVM_BUILD_LLVM_DYLIB=ON \
        -DLLVM_BUILD_BENCHMARKS=OFF \
        -DLLVM_BUILD_EXAMPLES=OFF \
        -DLLVM_BUILD_RUNTIME=ON \
        -DLLVM_BUILD_RUNTIMES=OFF \
        -DLLVM_BUILD_TESTS=OFF \
        -DLLVM_BUILD_TOOLS=OFF \
        -DLLVM_BUILD_UTILS=OFF \
        \
        -DLLVM_INCLUDE_BENCHMARKS=OFF \
        -DLLVM_INCLUDE_DOCS=OFF \
        -DLLVM_INCLUDE_EXAMPLES=OFF \
        -DLLVM_INCLUDE_GO_TESTS=OFF \
        -DLLVM_INCLUDE_RUNTIMES=ON \
        -DLLVM_INCLUDE_TESTS=OFF \
        -DLLVM_INCLUDE_TOOLS=OFF \
        -DLLVM_INCLUDE_UTILS=OFF \
        \
        -DLLVM_DEFAULT_TARGET_TRIPLE="$archTriple" \
        -DLLVM_TARGET_ARCH="$llvmTarget" \
        -DLLVM_TARGETS_TO_BUILD="$llvmTarget" \
        \
        -DLLVM_TABLEGEN="../../host-build/bin/llvm-tblgen.exe" \
        \
        -DPYTHON_EXECUTABLE="$NdkBundle/prebuilt/windows-x86_64/bin/python2.7.exe" \
        -DANDROID_NDK="$NdkBundle" \
        -DANDROID_ABI="$archTarget" \
        \
        -DCMAKE_INSTALL_PREFIX="$buildFullPath" \
        -DCMAKE_CROSSCOMPILING=True \
        -DCMAKE_SYSTEM_NAME=Android \
        -DANDROID_PLATFORM=android-21 \
        -DCMAKE_SYSTEM_VERSION=21 \
        -DCMAKE_ANDROID_NDK="$NdkBundle" \
        -DCMAKE_TOOLCHAIN_FILE="$ToolchainFile" \
        -DCMAKE_MAKE_PROGRAM="$AndroidNinjaExe" \
        -G "Ninja" \
        "../../$SourceRootPath"
    
    echo "Building LLVM for Architecture : $archTarget ..."
    $AndroidCmakeExe --build . --target install
    
    popd
    echo "Successfully built LLVM for Architecture : $archTarget !"
done
echo "Successfully built LLVM for Android!"
