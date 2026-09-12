# cmake/MacOSXClang.cmake

if(_MACOSX_CLANG_CMAKE)
	return()
endif()

set(_MACOSX_CLANG_CMAKE 1)

# Propagate macosx-cross configuration into CMake try_compile() projects.
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES MACOSX_SDK_VERSION MACOSX_TARGET)

set(CMAKE_SYSTEM_NAME Darwin)
set(APPLE 1)

if(NOT DEFINED MACOSX_SDK_VERSION OR MACOSX_SDK_VERSION STREQUAL "")
	if(DEFINED ENV{MACOSX_SDK_VERSION})
		set(MACOSX_SDK_VERSION "$ENV{MACOSX_SDK_VERSION}" CACHE STRING "macOS SDK version")
    else()
		message(FATAL_ERROR "MACOSX_SDK_VERSION is not set")
	endif()
else()
	set(ENV{MACOSX_SDK_VERSION} "${MACOSX_SDK_VERSION}")
endif()

if(NOT DEFINED MACOSX_TARGET OR MACOSX_TARGET STREQUAL "")
	if(DEFINED ENV{MACOSX_TARGET})
		set(MACOSX_TARGET "$ENV{MACOSX_TARGET}" CACHE STRING "macOS target")
	else()
		message(FATAL_ERROR "MACOSX_TARGET is not set")
	endif()
else()
	set(ENV{MACOSX_TARGET} "${MACOSX_TARGET}")
endif()

# C Compiler
find_program(MACOSX_CROSS_CLANG NAMES macosx-cross-clang REQUIRED)

if(NOT MACOSX_CROSS_CLANG)
	message(FATAL_ERROR "Unable to find macosx-cross-clang.")
endif()

# C++ Compiler
find_program(MACOSX_CROSS_CLANGXX NAMES macosx-cross-clang++ REQUIRED)

if(NOT MACOSX_CROSS_CLANGXX)
	message(FATAL_ERROR "Unable to find macosx-cross-clang++.")
endif()

# Configuration
if(NOT DEFINED MACOSX_SDK_VERSION OR "${MACOSX_SDK_VERSION}" STREQUAL "")
	message(FATAL_ERROR "MACOSX_SDK_VERSION is not set.\nExample:\n\t-DMACOSX_SDK_VERSION=14.5")
endif()

if(NOT DEFINED MACOSX_TARGET OR "${MACOSX_TARGET}" STREQUAL "")
	message(FATAL_ERROR "MACOSX_TARGET is not set.\nExample:\n\t-DMACOSX_TARGET=arm64-apple-darwin")
endif()

set(CMAKE_C_COMPILER "${MACOSX_CROSS_CLANG};--macosx-sdk=${MACOSX_SDK_VERSION};--target=${MACOSX_TARGET}" CACHE STRING "macosx-cross C Compiler")
set(CMAKE_CXX_COMPILER "${MACOSX_CROSS_CLANGXX};--macosx-sdk=${MACOSX_SDK_VERSION};--target=${MACOSX_TARGET}" CACHE STRING "macosx-cross C++ Compiler")
set(CMAKE_ASM_COMPILER "${MACOSX_CROSS_CLANG}" CACHE FILEPATH "macosx-cross assembler")

# Target
string(REGEX REPLACE "-apple-.*$" "" MACOSX_ARCH "${MACOSX_TARGET}")

if(MACOSX_ARCH STREQUAL "")
	message(FATAL_ERROR "Unable to determine architecture from MACOSX_TARGET='${MACOSX_TARGET}'")
endif()

if(MACOSX_ARCH STREQUAL "x86_64")
	set(MACOSX_CMAKE_ARCH "x86_64")
elseif(MACOSX_ARCH STREQUAL "x86_64h")
	set(MACOSX_CMAKE_ARCH "x86_64h")
elseif(MACOSX_ARCH STREQUAL "arm64")
	set(MACOSX_CMAKE_ARCH "arm64")
elseif(MACOSX_ARCH STREQUAL "arm64e")
	set(MACOSX_CMAKE_ARCH "arm64e")
elseif(MACOSX_ARCH STREQUAL "x86")
	set(MACOSX_CMAKE_ARCH "i386")
else()
	message(FATAL_ERROR "Unsupported macOS target architecture: ${MACOSX_ARCH}")
endif()

set(CMAKE_SYSTEM_PROCESSOR "${MACOSX_CMAKE_ARCH}" CACHE STRING "macOS target architecture" FORCE)
set(CMAKE_OSX_ARCHITECTURES "${MACOSX_CMAKE_ARCH}" CACHE STRING "macOS target architecture" FORCE)

# Cross compilation
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Find behavior
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Diagnostics
message(STATUS "macosx-cross")
message(STATUS "  C compiler     : ${MACOSX_CROSS_CLANG}")
message(STATUS "  C++ compiler   : ${MACOSX_CROSS_CLANGXX}")
message(STATUS "  SDK version    : ${MACOSX_SDK_VERSION}")
message(STATUS "  Target         : ${MACOSX_TARGET}")
message(STATUS "  Architecture   : ${MACOSX_ARCH}")
