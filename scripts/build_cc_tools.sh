#!/bin/bash

# Use provided versions or the defaults
BINUTILS_VERSION="${BINUTILS_VERSION:-2.43}"
GCC_VERSION="${GCC_VERSION:-14.2.0}"

BINUTILS_URL="https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz"
GCC_URL="https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz"

TARGET=x86_64-elf

# ---------------------------

set -e

if [ "$#" != 1 ]; then
   echo "Usage: build_cc_tools.sh [build directory]" 
   echo "Note: build directory must already exist."
   exit 0
fi

TOOLCHAINS_DIR="$1"

pushd "$TOOLCHAINS_DIR"
TOOLCHAIN_PREFIX="$TOOLCHAINS_DIR/$TARGET"

export CC=
export CFLAGS=
export LDFLAGS=
export LIBS=
export CPPFLAGS=
export CXX=
export CXXFLAGS=

# Download and build binutils
BINUTILS_SRC="binutils-${BINUTILS_VERSION}"
BINUTILS_BUILD="binutils-build-${BINUTILS_VERSION}"

wget ${BINUTILS_URL}
tar -xf binutils-${BINUTILS_VERSION}.tar.xz

mkdir -p ${BINUTILS_BUILD}
pushd ${BINUTILS_BUILD}
../binutils-${BINUTILS_VERSION}/configure \
    --prefix="${TOOLCHAIN_PREFIX}"	\
    --target=${TARGET}				\
    --with-sysroot					\
    --disable-nls					\
    --disable-werror
make -j8
make install
popd

# Download and build GCC
GCC_SRC="gcc-${GCC_VERSION}"
GCC_BUILD="gcc-build-${GCC_VERSION}"

wget ${GCC_URL}
tar -xf gcc-${GCC_VERSION}.tar.xz
mkdir -p ${GCC_BUILD}
pushd ${GCC_BUILD}
../gcc-${GCC_VERSION}/configure     \
    --prefix="${TOOLCHAIN_PREFIX}" 	\
    --target=${TARGET}				\
    --disable-nls					\
    --enable-languages=c,c++		\
    --without-headers
make -j8 all-gcc all-target-libgcc
make install-gcc install-target-libgcc
popd
popd
