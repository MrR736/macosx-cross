# macosx-cross.mk

ifndef MACOSX_CROSS_MK
MACOSX_CROSS_MK := 1

# ------------------------------------------------------------
# macosx-cross configuration
# ------------------------------------------------------------

MACOSX_SDK_VERSION ?=
MACOSX_TARGET      ?=

ifndef MACOSX_SDK_VERSION
$(error MACOSX_SDK_VERSION is not set)
endif

ifndef MACOSX_TARGET
$(error MACOSX_TARGET is not set)
endif


# ------------------------------------------------------------
# Compilers
# ------------------------------------------------------------

MACOSX_CROSS_CLANG   ?= macosx-cross-clang
MACOSX_CROSS_CLANGXX ?= macosx-cross-clang++


# ------------------------------------------------------------
# Compiler flags
# ------------------------------------------------------------

MACOSX_CFLAGS   ?=
MACOSX_CXXFLAGS ?=
MACOSX_LDFLAGS  ?=


# ------------------------------------------------------------
# macosx-cross arguments
# ------------------------------------------------------------

MACOSX_CROSS_FLAGS := \
	--macosx-sdk=$(MACOSX_SDK_VERSION) \
	--target=$(MACOSX_TARGET)


# ------------------------------------------------------------
# C / C++
# ------------------------------------------------------------

CC  := $(MACOSX_CROSS_CLANG) $(MACOSX_CROSS_FLAGS)
CXX := $(MACOSX_CROSS_CLANGXX) $(MACOSX_CROSS_FLAGS)


# ------------------------------------------------------------
# Flags
# ------------------------------------------------------------

CFLAGS   += $(MACOSX_CFLAGS)
CXXFLAGS += $(MACOSX_CXXFLAGS)
LDFLAGS  += $(MACOSX_LDFLAGS)


endif
