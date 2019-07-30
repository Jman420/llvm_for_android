#!/bin/bash

AndroidSystemVersion="21"
AndroidSdkDir="$LOCALAPPDATA/Android/Sdk"
AndroidCmakeExe="$AndroidSdkDir/cmake/3.10.2.4988404/bin/cmake.exe"
AndroidNinjaExe="$AndroidSdkDir/cmake/3.10.2.4988404/bin/ninja.exe"
NdkBundle="$AndroidSdkDir/ndk-bundle/"
ToolchainFile="$NdkBundle/build/cmake/android.toolchain.cmake"
ArchTargets=( "armeabi-v7a" ) #"arm64-v8a" "x86" "x86_64" )
ArchTriples=( "armv7a-linux-androideabi" "aarch64-linux-android" "i686-linux-android" "x86_64-linux-android" )
LlvmTargets=( "ARM" "AArch64" "X86" "X86" )

ProjectRootPath="android-project"
BuildRootPath="android-build"
SourceRootPath="llvm-src"

PatchableSourceFiles=( "$SourceRootPath/lib/Transforms/CMakeLists.txt" )
SourcePatchReplacePatterns=( "^add_subdirectory(Hello)$" )
SourcePatchReplaceValues=( "#add_subdirectory(Hello)" )

echo "Patching LLVM Source Files..."
PatchesLength=${#PatchableSourceFiles[*]}
for (( patchCounter=0; patchCounter < $PatchesLength; patchCounter++ ))
do
    patchFile=${PatchableSourceFiles[$patchCounter]}
    replacePattern=${SourcePatchReplacePatterns[$patchCounter]}
    replaceValue=${SourcePatchReplaceValues[$patchCounter]}
    
    echo "Patching Source File : $patchFile ..."
    if [ ! -f "$patchFile.orig" ]
    then
        cp "$patchFile" "$patchFile.orig"
    fi
    
    echo "Replacing $replacePattern with $replaceValue ..."
    sed -i "s/$replacePattern/$replaceValue/" "$patchFile"
    echo "Successfully patched Source File : $patchFile !"
done
echo "Successfully patched LLVM Source Files!"

echo "Building LLVM for Android..."
ArchsLength=${#ArchTargets[*]}
for (( archCounter=0; archCounter < $ArchsLength; archCounter++ ))
do
    archTarget=${ArchTargets[$archCounter]}
    archTriple=${ArchTriples[$archCounter]}
    llvmTarget=${LlvmTargets[$archCounter]}
    projectDir="$ProjectRootPath/$archTarget"
    buildDir="$BuildRootPath/$archTarget"
    
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
    buildFullPath=$(realpath "./$buildDir")
    
    echo "Generating Project Files for Architecture : $archTarget ..."
    pushd $projectDir > /dev/null
    $AndroidCmakeExe \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="$buildFullPath" \
        -DCMAKE_TOOLCHAIN_FILE="$ToolchainFile" \
        -DCMAKE_MAKE_PROGRAM="$AndroidNinjaExe" \
        \
        -DANDROID_ABI="$archTarget" \
        -DANDROID_PLATFORM="$AndroidSystemVersion" \
        \
        -DLLVM_DEFAULT_TARGET_TRIPLE="$archTriple" \
        -DLLVM_TARGETS_TO_BUILD="$llvmTarget" \
        \
        -DLLVM_TABLEGEN="../../host-build/bin/llvm-tblgen.exe" \
        -DPYTHON_EXECUTABLE="$NdkBundle/prebuilt/windows-x86_64/bin/python2.7.exe" \
        \
        -DLLVM_INCLUDE_BENCHMARKS=OFF \
        -DLLVM_INCLUDE_DOCS=OFF \
        -DLLVM_INCLUDE_EXAMPLES=OFF \
        -DLLVM_INCLUDE_RUNTIMES=OFF \
        -DLLVM_INCLUDE_TESTS=OFF \
        -DLLVM_INCLUDE_GO_TESTS=OFF \
        -DLLVM_INCLUDE_TOOLS=OFF \
        -DLLVM_INCLUDE_UTILS=OFF \
        \
        -DLLVM_BUILD_BENCHMARKS=OFF \
        -DLLVM_BUILD_EXAMPLES=OFF \
        -DLLVM_BUILD_RUNTIME=OFF \
        -DLLVM_BUILD_RUNTIMES=OFF \
        -DLLVM_BUILD_TESTS=OFF \
        -DLLVM_BUILD_TOOLS=OFF \
        -DLLVM_BUILD_UTILS=OFF \
        \
        -DLLVM_BUILD_LLVM_DYLIB=OFF \
        \
        -DLLVM_ENABLE_PIC=False \
        \
        -G "Ninja" \
        \
        "../../$SourceRootPath"
    if [ $? -ne 0 ]; then
        echo "Project Generation failed for Architecture : $archTarget !"
        popd > /dev/null
        exit 1
    fi
    
    echo "Building LLVM for Architecture : $archTarget ..."
    $AndroidCmakeExe --build . --target install
    if [ $? -ne 0 ]; then
        echo "Compilation failed for Architecture : $archTarget !"
        popd > /dev/null
        exit 1
    fi
    popd > /dev/null
    
    #echo "Stripping libLLVM for Architecture : $archTarget ..."
    #strip --strip-unneeded $buildFullPath\lib\libLLVM.so
    #if [ $? -ne 0 ]; then
    #    echo "Stripping failed for Architecture : $archTarget !"
    #    exit 1
    #fi
    
    echo "Successfully built LLVM for Architecture : $archTarget !"
done
echo "Successfully built LLVM for Android!"
