#!/usr/bin/env bash

set -e

SCRIPT_PATH=$(readlink -f $(dirname "$0"))

BINUTILS_VERSION=2.35.1
GCC_VERSION=10.2.0

CPU_CORES=$(cat /proc/cpuinfo | grep "cpu cores" | head -1 | awk -F ' ' '{print $4}')
[ -z "$JOBS" ] && JOBS=$(expr $CPU_CORES - 1)

cd $SCRIPT_PATH

if [ ! -f binutils-$BINUTILS_VERSION.tar.gz ]; then
	wget https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.gz
fi

if [ ! -f gcc-$GCC_VERSION.tar.gz ]; then
	wget https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz
fi

if [ $NO_PIGZ ]
then
    echo -n Unpacking Binutils
    tar --checkpoint=.1000 -xf binutils-$BINUTILS_VERSION.tar.gz
    echo

    echo -n Unpacking GCC
    tar --checkpoint=.1000 -xf gcc-$GCC_VERSION.tar.gz
    echo
else
    echo -n Unpacking Binutils
    tar --checkpoint=.1000 -I pigz -xf binutils-$BINUTILS_VERSION.tar.gz
    echo

    echo -n Unpacking GCC
    tar --checkpoint=.1000 -I pigz -xf gcc-$GCC_VERSION.tar.gz
    echo
fi

# Build for the i386-elf target.

export TARGET=i386-elf
export PREFIX=$SCRIPT_PATH/$TARGET
export PATH="$PREFIX/bin:$PATH"

mkdir -p build-binutils-$TARGET
pushd build-binutils-$TARGET
    ../binutils-$BINUTILS_VERSION/configure --prefix=$PREFIX --target=$TARGET \
        --with-sysroot --disable-nls --disable-werror
    make -j $JOBS
    make install
popd

mkdir -p build-gcc-$TARGET
pushd build-gcc-$TARGET
    ../gcc-$GCC_VERSION/configure --target=$TARGET --prefix="$PREFIX" \
        --disable-nls --enable-languages=c --without-headers
    make all-gcc -j $JOBS
    make all-target-libgcc -j $JOBS
    make install-gcc
    make install-target-libgcc
popd

rm -rf build-binutils-$TARGET
rm -rf build-gcc-$TARGET

# Build for the x86_64-elf target.

export TARGET=x86_64-elf
export PREFIX=$SCRIPT_PATH/$TARGET
export PATH="$PREFIX/bin:$PATH"

mkdir -p build-binutils-$TARGET
pushd build-binutils-$TARGET
    ../binutils-$BINUTILS_VERSION/configure --prefix=$PREFIX --target=$TARGET \
        --with-sysroot --disable-nls --disable-werror
    make -j $JOBS
    make install
popd

mkdir -p build-gcc-$TARGET
pushd build-gcc-$TARGET
    ../gcc-$GCC_VERSION/configure --target=$TARGET --prefix="$PREFIX" \
        --disable-nls --enable-languages=c --without-headers
    make all-gcc -j $JOBS
    make all-target-libgcc -j $JOBS
    make install-gcc
    make install-target-libgcc
popd

rm -rf build-binutils-$TARGET
rm -rf build-gcc-$TARGET
