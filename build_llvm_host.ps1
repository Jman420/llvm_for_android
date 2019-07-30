$SourceDir = "llvm-src"
$ProjectDir = "host-project"
$BuildDir = "host-build"

$CmakeCmd = "cmake"

# Remove build & output directories
if (Test-Path $ProjectDir) {
    Write-Output "Removing existing Host Project Directory..."
    Remove-Item $ProjectDir -Force -Recurse
}
if (Test-Path $BuildDir) {
    Write-Output "Removing existing Host Build Directory..."
    Remove-Item $BuildDir -Force -Recurse
}

Write-Output "Creating Host Project & Build Directories..."
New-Item -ItemType directory -Force -Path $ProjectDir
New-Item -ItemType directory -Force -Path $BuildDir
$FullBuildPath = Resolve-Path $BuildDir

Write-Output "Generating Host Project..."
Push-Location $ProjectDir
. $CmakeCmd `
    `
    -DCMAKE_INSTALL_PREFIX="$FullBuildPath" `
    `
    -DLLVM_TARGETS_TO_BUILD=X86 `
    `
    -DLLVM_INCLUDE_BENCHMARKS=OFF `
    -DLLVM_INCLUDE_DOCS=OFF `
    -DLLVM_INCLUDE_EXAMPLES=OFF `
    -DLLVM_INCLUDE_RUNTIMES=ON `
    -DLLVM_INCLUDE_TESTS=OFF `
    -DLLVM_INCLUDE_GO_TESTS=OFF `
    -DLLVM_INCLUDE_TOOLS=OFF `
    -DLLVM_INCLUDE_UTILS=OFF `
    `
    -DLLVM_BUILD_BENCHMARKS=OFF `
    -DLLVM_BUILD_DOCS=OFF `
    -DLLVM_BUILD_EXAMPLES=OFF `
    -DLLVM_BUILD_RUNTIME=OFF `
    -DLLVM_BUILD_RUNTIMES=ON `
    -DLLVM_BUILD_TESTS=OFF `
    -DLLVM_BUILD_TOOLS=OFF `
    -DLLVM_BUILD_LLVM_DYLIB=OFF `
    -DLLVM_BUILD_UTILS=OFF `
    `
    -G "Visual Studio 16 2019" `
    -Thost=x64 `
    `
    ../$SourceDir

Write-Output "Building & Installing Host Binaries..."
. $CmakeCmd --build . --target install
Pop-Location
Write-Output "Successfully Built and Installed Host Binaries!"
