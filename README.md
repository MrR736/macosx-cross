# macosx-cross

`macosx-cross` is a Linux-hosted macOS cross-compilation toolchain based on LLVM/Clang and macOS SDKs.

It provides wrapper commands for compiling, linking, debugging, and configuring macOS software from a non-macOS host.

## Features

- Install and manage multiple macOS SDK versions.
- Cross-compile for macOS from Linux.
- Support multiple Apple architectures and target triples.
- Clang and Clang++ compiler wrappers.
- `clangd` wrapper with macOS SDK configuration.
- LLD linker wrapper.
- macOS library/dependency inspection with `ldd`.
- CMake integration through a dedicated toolchain file.
- Copy bundled development tools into the current directory.
- SDK metadata and download URL management.
- No macOS installation is required on the host.

## Requirements

The host system requires:

- Linux
- Bash
- LLVM/Clang
- LLD
- `curl`
- `jq`
- `tar`
- CMake
- `make`
- `python3`

Depending on the operation, root privileges may be required to install or remove SDKs and system-wide files.

## Installation

Build and install the Debian package:

```bash
dpkg-buildpackage -us -uc
```

Install the resulting package:

```bash
sudo dpkg -i ../macosx-cross_*.deb
```

After installation, the main command is:

```bash
macosx-cross
```

The installation root is:

```text
/usr/lib/macosx-cross
```

Typical layout:

```text
/usr/lib/macosx-cross/
├── MacOSX.sdk/
├── cache/
├── scripts/
├── tools/
└── ...
```

## Main command

```text
macosx-cross [-s|--silent] <command> [options] [SDK_VERSION ...]
```

### Commands

```text
install       Install macOS SDK
reinstall     Reinstall macOS SDK
refresh       Refresh macOS SDK metadata/extraction
remove        Remove macOS SDK
uninstall     Alias for remove
allremove     Remove all installed macOS SDKs
allrefresh    Refresh all installed SDKs
list          List available macOS SDKs
clean         Remove cached SDK archives
--tool        Copy a tool to the current directory
```

### Silent mode

Silent mode must appear before the command:

```bash
sudo macosx-cross --silent allrefresh
```

or:

```bash
sudo macosx-cross -s allrefresh
```

### Skip confirmation

Commands that normally ask for confirmation accept:

```text
-y
```

For example:

```bash
sudo macosx-cross remove -y 14.5
```

## SDK management

List available SDK versions:

```bash
macosx-cross list
```

Install an SDK:

```bash
sudo macosx-cross install 14.5
```

Multiple SDKs can be installed in one command:

```bash
sudo macosx-cross install 13.3 14.5 15.5
```

Refresh one SDK:

```bash
sudo macosx-cross refresh 14.5
```

Refresh all installed SDKs:

```bash
sudo macosx-cross allrefresh
```

Reinstall an SDK:

```bash
sudo macosx-cross reinstall 14.5
```

Remove an SDK:

```bash
sudo macosx-cross remove 14.5
```

Remove several SDKs:

```bash
sudo macosx-cross remove 13.3 14.5
```

Remove all SDKs:

```bash
sudo macosx-cross allremove
```

Remove cached SDK archives:

```bash
sudo macosx-cross clean
```

## SDK versions

The project supports SDK versions published by the upstream SDK repository.

Examples include:

```text
26.1
26.0
15.5
15.4
15.2
15.1
15.0
14.5
14.4
14.2
14.0
13.3
13.1
13.0
12.3
12.1
12.0
11.3
11.1
10.15
10.14
10.13
10.12
10.11
10.10
10.9
```

The available list is obtained from the project's SDK metadata.

## SDK layout

Installed SDKs are stored below:

```text
/usr/lib/macosx-cross/MacOSX.sdk/
```

The default SDK can be exposed as:

```text
MacOSX.sdk/
```

while versioned SDKs are stored below it:

```text
MacOSX.sdk/
├── 10.9/
├── 10.10/
├── 10.11/
├── 13.3/
├── 14.5/
├── 15.5/
└── ...
```

Each SDK contains metadata used by the wrappers to determine supported architectures, deployment targets, and platform information.

## Compiler wrappers

### macosx-cross-clang

The C compiler wrapper is:

```bash
macosx-cross-clang
```

Example:

```bash
macosx-cross-clang \
    --macosx-sdk=14.5 \
    --target=arm64-apple-darwin \
    hello.c \
    -o hello
```

The wrapper configures Clang with the selected SDK and Apple target.

### macosx-cross-clang++

The C++ compiler wrapper is:

```bash
macosx-cross-clang++
```

Example:

```bash
macosx-cross-clang++ \
    --macosx-sdk=14.5 \
    --target=arm64-apple-darwin \
    hello.cpp \
    -o hello
```

### Environment variables

The wrappers can use:

```text
MACOSX_SDK_VERSION
MACOSX_TARGET
MACOSX_ARCH
```

For example:

```bash
export MACOSX_SDK_VERSION=14.5
export MACOSX_TARGET=arm64-apple-darwin
```

Then:

```bash
macosx-cross-clang hello.c -o hello
```

## Target triples

A target triple identifies the architecture, vendor, operating system, and platform.

Examples:

```text
x86-apple-darwin
x86_64-apple-darwin
arm64-apple-darwin
arm64e-apple-darwin
```

The commonly used macOS targets are:

| Target | Architecture |
|---|---|
| `x86-apple-darwin` | 32-bit Intel |
| `x86_64-apple-darwin` | Intel 64-bit |
| `arm64-apple-darwin` | Apple Silicon |
| `arm64e-apple-darwin` | ARM64e |

For example:

```bash
macosx-cross-clang \
    --macosx-sdk=10.9 \
    --target=x86_64-apple-darwin \
    hello.c \
    -o hello
```

## Deployment target

The macOS deployment target can be controlled through:

```text
MACOSX_DEPLOYMENT_TARGET
```

Example:

```bash
export MACOSX_DEPLOYMENT_TARGET=10.13
```

The wrapper uses the SDK version as the fallback when no explicit deployment target is supplied.

## macosx-cross-lld

The linker wrapper is:

```bash
macosx-cross-lld
```

Example:

```bash
macosx-cross-lld \
    --macosx-sdk=14.5 \
    --target=arm64-apple-darwin \
    ...
```

The wrapper configures LLD with:

- SDK sysroot
- target architecture
- platform version
- SDK library paths
- framework search paths
- system library paths

The compiler wrappers normally invoke LLD automatically, so it is usually unnecessary to invoke `macosx-cross-lld` directly.

## macosx-cross-clangd

`macosx-cross-clangd` configures `clangd` for the selected Apple SDK and target.

Example:

```bash
macosx-cross-clangd \
    --macosx-sdk=14.5 \
    --target=arm64-apple-darwin
```

The wrapper automatically configures the Clang driver used by `clangd` through:

```text
--query-driver
```

This allows `clangd` to understand the compiler's target, sysroot, include paths, and SDK configuration.

Environment variables can also be used:

```bash
export MACOSX_SDK_VERSION=14.5
export MACOSX_TARGET=arm64-apple-darwin
```

Then:

```bash
macosx-cross-clangd
```

## macosx-cross-ldd

`macosx-cross-ldd` is provided for inspecting dependencies of cross-compiled macOS binaries.

Example:

```bash
macosx-cross-ldd ./hello
```

It is intended for macOS/Mach-O binaries rather than Linux ELF binaries.

## CMake

The project provides a CMake toolchain file:

```text
cmake/MacOSXClang.cmake
```

Use it with:

```bash
cmake \
    -S . \
    -B build \
    -DCMAKE_TOOLCHAIN_FILE=/path/to/macosx-cross/cmake/MacOSXClang.cmake \
    -DMACOSX_SDK_VERSION=14.5 \
    -DMACOSX_TARGET=arm64-apple-darwin
```

Then build:

```bash
cmake --build build
```

### Example

```bash
cmake \
    -S . \
    -B build \
    -DCMAKE_TOOLCHAIN_FILE=cmake/MacOSXClang.cmake \
    -DMACOSX_SDK_VERSION=14.5 \
    -DMACOSX_TARGET=arm64-apple-darwin

cmake --build build
```

The toolchain configures:

```text
CMAKE_SYSTEM_NAME
CMAKE_SYSTEM_PROCESSOR
CMAKE_OSX_ARCHITECTURES
CMAKE_C_COMPILER
CMAKE_CXX_COMPILER
CMAKE_TRY_COMPILE_TARGET_TYPE
```

and configures CMake's cross-compilation search behavior.

### CMake architecture mapping

The Apple target architecture is mapped to the CMake processor:

```text
x86       -> i386
x86_64    -> x86_64
arm64     -> arm64
arm64e    -> arm64e
```

For example:

```text
arm64-apple-darwin
        |
        v
CMAKE_SYSTEM_PROCESSOR=arm64
CMAKE_OSX_ARCHITECTURES=arm64
```

## Tools

Additional development tools are installed under:

```text
/usr/lib/macosx-cross/tools/
```

Current tools include:

```text
tools/
├── cmake/
└── make/
```

### Copy a tool

A tool can be copied into the current directory:

```bash
macosx-cross --tool cmake
```

or:

```bash
macosx-cross --tool=cmake
```

For `make`:

```bash
macosx-cross --tool make
```

### List available tools

If supported by the installed version:

```bash
macosx-cross --list-tool
```

## Man pages

The project provides manual pages for the main commands:

```text
macosx-cross(1)
macosx-cross-clang(1)
macosx-cross-clang++(1)
macosx-cross-clangd(1)
macosx-cross-ldd(1)
macosx-cross-lld(1)
```

View a manual page with:

```bash
man macosx-cross
```

For example:

```bash
man macosx-cross-clang
```

## Building from source

Clone the project and enter the source directory:

```bash
git clone https://github.com/MrR736/macosx-cross.git
cd macosx-cross
```

Configure the project:

```bash
cmake -S . -B build
```

Build:

```bash
cmake --build build
```

Install:

```bash
sudo cmake --install build
```

The installation prefix can be changed:

```bash
cmake \
    -S . \
    -B build \
    -DCMAKE_INSTALL_PREFIX=/usr
```

Then:

```bash
sudo cmake --install build
```

## Debian package

Build the source package:

```bash
dpkg-buildpackage -S -us -uc
```

Build a binary package:

```bash
dpkg-buildpackage -us -uc
```

Install:

```bash
sudo dpkg -i ../macosx-cross_*.deb
```

Check the package with Lintian:

```bash
lintian ../macosx-cross_*.deb
```

## File layout

The source tree is organized approximately as:

```text
macosx-cross/
├── cmake/
│   └── MacOSXClang.cmake
├── debian/
├── man/
│   ├── macosx-cross.1
│   ├── macosx-cross-clang.1
│   ├── macosx-cross-clang++.1
│   ├── macosx-cross-clangd.1
│   ├── macosx-cross-ldd.1
│   └── macosx-cross-lld.1
├── scripts/
├── tools/
│   ├── cmake/
│   └── make/
├── CMakeLists.txt
├── LICENSE
└── README.md
```

## Environment variables

The main configuration variables are:

| Variable | Description |
|---|---|
| `MACOSX_SDK_VERSION` | SDK version |
| `MACOSX_TARGET` | Apple target triple |
| `MACOSX_ARCH` | Target architecture |
| `MACOSX_DEPLOYMENT_TARGET` | macOS deployment target |
| `IPHONEOS_DEPLOYMENT_TARGET` | iOS deployment target |

Example:

```bash
export MACOSX_SDK_VERSION=14.5
export MACOSX_TARGET=arm64-apple-darwin
export MACOSX_DEPLOYMENT_TARGET=14.0
```

## Cross-compilation example

Create a simple C program:

```c
#include <stdio.h>

int main(void) {
    puts("Hello from macOS cross-compilation!");
    return 0;
}
```

Compile it:

```bash
macosx-cross-clang \
    --macosx-sdk=14.5 \
    --target=arm64-apple-darwin \
    hello.c \
    -o hello
```

Inspect the resulting binary:

```bash
file hello
```

The resulting executable is a Mach-O binary for the selected Apple architecture.

## Troubleshooting

### Missing target

If a compiler wrapper is invoked without a target:

```bash
macosx-cross-clang --macosx-sdk=10.9
```

the wrapper reports the missing target and lists targets supported by the SDK.

Specify one explicitly:

```bash
macosx-cross-clang \
    --macosx-sdk=10.9 \
    --target=x86_64-apple-darwin \
    hello.c \
    -o hello
```

### SDK not installed

Check available SDKs:

```bash
macosx-cross list
```

Install the required SDK:

```bash
sudo macosx-cross install 14.5
```

### SDK download cache

Downloaded SDK archives are cached under:

```text
/usr/lib/macosx-cross/cache/
```

Remove cached archives with:

```bash
sudo macosx-cross clean
```

### CMake cannot find the compiler

Verify the wrappers are installed:

```bash
command -v macosx-cross-clang
command -v macosx-cross-clang++
```

Then verify:

```bash
macosx-cross-clang --help
```

If necessary, make sure `/usr/bin` is in `PATH`.

### Unsupported architecture

Check the architectures supported by the selected SDK and use a compatible target:

```text
x86-apple-darwin
x86_64-apple-darwin
arm64-apple-darwin
arm64e-apple-darwin
```

Not every SDK supports every architecture.

## License

`macosx-cross` is licensed under the GNU General Public License, version 3 or later.

See:

```text
LICENSE
```

for the complete license text.

## Author

**MrR736** <[MrR736@users.github.com](mailto:MrR736@users.github.com)>
