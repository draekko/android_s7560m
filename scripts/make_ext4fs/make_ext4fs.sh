#!/bin/bash

# Create ext4fs tools
# From https://gist.github.com/shakalaca/4942cfb8a4869325cdc9

REVISION="4.4.4"
RELEASE="r2.0.1"

if [ ! -d "source" ]; then
    mkdir source
fi

if [ ! -d "bin" ]; then
    mkdir bin
fi

# clone source
cd source

if [ ! -d "libselinux" ]; then
    git clone --branch "android-"$REVISION"_"$RELEASE https://android.googlesource.com/platform/external/libselinux
fi

if [ ! -d "core" ]; then
    git clone --branch "android-"$REVISION"_"$RELEASE https://android.googlesource.com/platform/system/core
fi

if [ ! -d "zlib" ]; then
    git clone --branch "android-"$REVISION"_"$RELEASE https://android.googlesource.com/platform/external/zlib
fi

if [ ! -d "extras" ]; then
    git clone --branch "android-"$REVISION"_"$RELEASE https://android.googlesource.com/platform/system/extras
fi

if [ ! -d "intel-boot-tools" ]; then
    git clone https://github.com/draekko/intel-boot-tools
fi

# build for make_ext4fs
echo "build for make_ext4fs"
cd libselinux/src
gcc -c callbacks.c check_context.c freecon.c init.c label.c label_file.c label_android_property.c -I../include -I../../core/include
ar rcs libselinux.a *.o
cd ../..

echo "build zlib"
cd zlib/src
gcc -c adler32.c compress.c crc32.c deflate.c gzclose.c gzlib.c gzread.c gzwrite.c infback.c inflate.c inftrees.c inffast.c trees.c uncompr.c zutil.c -O3 -USE_MMAP -I..
ar rcs libz.a *.o
cd ../..

echo "build libparse"
cd core/libsparse
gcc -c backed_block.c output_file.c sparse.c sparse_crc32.c sparse_err.c sparse_read.c -Iinclude
ar rcs libsparse.a *.o

echo "build simg2img"
gcc -o simg2img simg2img.c sparse_crc32.c -Iinclude libsparse.a -I../../zlib ../../zlib/src/libz.a
cp simg2img ../../../bin
cd ../..

echo "build ext4_utils"
cd extras/ext4_utils
gcc -o make_ext4fs make_ext4fs_main.c make_ext4fs.c ext4fixup.c ext4_utils.c allocate.c contents.c extent.c indirect.c uuid.c sha1.c wipe.c crc16.c -I../../libselinux/include -I../../core/libsparse/include -I../../core/include/ ../../libselinux/src/libselinux.a ../../core/libsparse/libsparse.a ../../zlib/src/libz.a -DHOST -DANDROID
cp make_ext4fs ../../../bin
cd ../..

# build for mkbootimg & mkbootfs
echo "build for mkbootimg & mkbootfs"
cd core/libmincrypt
gcc -c *.c -I../include
ar rcs libmincrypt.a *.o
cd ../..

cd core/mkbootimg
gcc mkbootimg.c -o mkbootimg -I../include ../libmincrypt/libmincrypt.a
cp mkbootimg ../../../bin
cd ../..

cd core/cpio
gcc mkbootfs.c  -o mkbootfs -I../include
cp mkbootfs ../../../bin
cd ../..
