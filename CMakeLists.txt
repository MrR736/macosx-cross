cmake_minimum_required(VERSION 3.20)

project(macosx-cross VERSION 1.0.0)

include(GNUInstallDirs)

set(MACOSX_CROSS_VERSION "v${PROJECT_VERSION}")

set(MACOSX_CFLAGS "-fuse-ld=lld -Wno-unused-command-line-argument")
set(MACOSX_CXXFLAGS "${MACOSX_CFLAGS}")
set(MACOSX_CROSS_LIBDIR "${CMAKE_INSTALL_PREFIX}/lib/${PROJECT_NAME}")

# Generate scripts
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/scripts")
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/man")

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/scripts/remove_macosx.sh.in" "${CMAKE_CURRENT_BINARY_DIR}/scripts/remove_macosx.sh" @ONLY)
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/scripts/refresh_macosx.sh.in" "${CMAKE_CURRENT_BINARY_DIR}/scripts/refresh_macosx.sh" @ONLY)
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/scripts/install_macosx.sh.in" "${CMAKE_CURRENT_BINARY_DIR}/scripts/install_macosx.sh" @ONLY)
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/scripts/macosx_tools.sh.in" "${CMAKE_CURRENT_BINARY_DIR}/scripts/macosx_tools.sh" @ONLY)

# Clang wrapper
set(MACOSX_CROSS_CLANG "clang")
set(MACOSX_CROSS_CLANG_TEXT "Clang")
set(MACOSX_CROSS_CLANG_FILE "c")

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/scripts/macosx-cross-clang.in" "${CMAKE_CURRENT_BINARY_DIR}/scripts/macosx-cross-clang" @ONLY)
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/man/macosx-cross-clang.1" "${CMAKE_CURRENT_BINARY_DIR}/man/macosx-cross-clang.1" @ONLY)

# Clang++ wrapper
set(MACOSX_CROSS_CLANG "clang++")
set(MACOSX_CROSS_CLANG_TEXT "Clang++")
set(MACOSX_CROSS_CLANG_FILE "cpp")

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/scripts/macosx-cross-clang.in" "${CMAKE_CURRENT_BINARY_DIR}/scripts/macosx-cross-clang++" @ONLY)
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/man/macosx-cross-clang.1" "${CMAKE_CURRENT_BINARY_DIR}/man/macosx-cross-clang++.1" @ONLY)

# Main tools
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/scripts/macosx-cross.in" "${CMAKE_CURRENT_BINARY_DIR}/scripts/macosx-cross" @ONLY)
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/scripts/macosx-cross-clangd.in" "${CMAKE_CURRENT_BINARY_DIR}/scripts/macosx-cross-clangd" @ONLY)
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/scripts/macosx-cross-ldd.in" "${CMAKE_CURRENT_BINARY_DIR}/scripts/macosx-cross-ldd" @ONLY)
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/scripts/macosx-cross-lld.in" "${CMAKE_CURRENT_BINARY_DIR}/scripts/macosx-cross-lld" @ONLY)

# Man pages
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/man/macosx-cross.1" "${CMAKE_CURRENT_BINARY_DIR}/man/macosx-cross.1" @ONLY)
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/man/macosx-cross-clangd.1" "${CMAKE_CURRENT_BINARY_DIR}/man/macosx-cross-clangd.1" @ONLY)
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/man/macosx-cross-ldd.1" "${CMAKE_CURRENT_BINARY_DIR}/man/macosx-cross-ldd.1" @ONLY)
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/man/macosx-cross-lld.1" "${CMAKE_CURRENT_BINARY_DIR}/man/macosx-cross-lld.1" @ONLY)

# Install library scripts
install(
	PROGRAMS
		"${CMAKE_CURRENT_BINARY_DIR}/scripts/remove_macosx.sh"
		"${CMAKE_CURRENT_BINARY_DIR}/scripts/refresh_macosx.sh"
		"${CMAKE_CURRENT_BINARY_DIR}/scripts/install_macosx.sh"
		"${CMAKE_CURRENT_BINARY_DIR}/scripts/macosx_tools.sh"
	DESTINATION
		"${MACOSX_CROSS_LIBDIR}/scripts"
)

# Install command-line tools
install(
	PROGRAMS
		"${CMAKE_CURRENT_BINARY_DIR}/scripts/macosx-cross"
		"${CMAKE_CURRENT_BINARY_DIR}/scripts/macosx-cross-clang"
		"${CMAKE_CURRENT_BINARY_DIR}/scripts/macosx-cross-clang++"
		"${CMAKE_CURRENT_BINARY_DIR}/scripts/macosx-cross-clangd"
		"${CMAKE_CURRENT_BINARY_DIR}/scripts/macosx-cross-ldd"
		"${CMAKE_CURRENT_BINARY_DIR}/scripts/macosx-cross-lld"
	DESTINATION
		"${CMAKE_INSTALL_BINDIR}"
)

# Install supporting tools
install(
	DIRECTORY
		"${CMAKE_CURRENT_SOURCE_DIR}/tools/"
	DESTINATION
		"${MACOSX_CROSS_LIBDIR}/tools"
)

# Install man pages
install(
	FILES
		"${CMAKE_CURRENT_BINARY_DIR}/man/macosx-cross.1"
		"${CMAKE_CURRENT_BINARY_DIR}/man/macosx-cross-clang.1"
		"${CMAKE_CURRENT_BINARY_DIR}/man/macosx-cross-clang++.1"
		"${CMAKE_CURRENT_BINARY_DIR}/man/macosx-cross-clangd.1"
		"${CMAKE_CURRENT_BINARY_DIR}/man/macosx-cross-ldd.1"
		"${CMAKE_CURRENT_BINARY_DIR}/man/macosx-cross-lld.1"
	DESTINATION
		"${CMAKE_INSTALL_MANDIR}/man1"
)
