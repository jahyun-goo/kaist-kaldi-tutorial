# This file was generated using the following command:
# ./configure 

CONFIGURE_VERSION := 9

# Toolchain configuration

CXX = g++
AR = ar
AS = as
RANLIB = ranlib

# Base configuration

DOUBLE_PRECISION = 0
OPENFSTINC = /home/kaist/kaldi/tools/openfst/include
OPENFSTLIBS = /home/kaist/kaldi/tools/openfst/lib/libfst.so
OPENFSTLDFLAGS = -Wl,-rpath=/home/kaist/kaldi/tools/openfst/lib

ATLASINC = /home/kaist/kaldi/tools/ATLAS_headers/include
ATLASLIBS = /usr/lib/x86_64-linux-gnu/liblapack.so /usr/lib/x86_64-linux-gnu/libcblas.so /usr/lib/x86_64-linux-gnu/libatlas.so /usr/lib/x86_64-linux-gnu/libf77blas.so
ATLASLDFLAGS = -Wl,-rpath,/usr/lib/x86_64-linux-gnu

# ATLAS specific Linux configuration

ifndef DOUBLE_PRECISION
$(error DOUBLE_PRECISION not defined.)
endif
ifndef OPENFSTINC
$(error OPENFSTINC not defined.)
endif
ifndef OPENFSTLIBS
$(error OPENFSTLIBS not defined.)
endif
ifndef ATLASINC
$(error ATLASINC not defined.)
endif
ifndef ATLASLIBS
$(error ATLASLIBS not defined.)
endif

CXXFLAGS = -std=c++11 -I.. -isystem $(OPENFSTINC) -O1 $(EXTRA_CXXFLAGS) \
           -Wall -Wno-sign-compare -Wno-unused-local-typedefs \
           -Wno-deprecated-declarations -Winit-self \
           -DKALDI_DOUBLEPRECISION=$(DOUBLE_PRECISION) \
           -DHAVE_EXECINFO_H=1 -DHAVE_CXXABI_H -DHAVE_ATLAS -I$(ATLASINC) \
           -msse -msse2 -pthread \
           -g # -O0 -DKALDI_PARANOID

ifeq ($(KALDI_FLAVOR), dynamic)
CXXFLAGS += -fPIC
endif

# Compiler specific flags
COMPILER = $(shell $(CXX) -v 2>&1)
ifeq ($(findstring clang,$(COMPILER)),clang)
# Suppress annoying clang warnings that are perfectly valid per spec.
CXXFLAGS += -Wno-mismatched-tags
endif

LDFLAGS = $(EXTRA_LDFLAGS) $(OPENFSTLDFLAGS) $(ATLASLDFLAGS) -rdynamic
LDLIBS = $(EXTRA_LDLIBS) $(OPENFSTLIBS) $(ATLASLIBS) -lm -lpthread -ldl

# Environment configuration

