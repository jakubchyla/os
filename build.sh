#! /usr/bin/env bash

export KERNEL_SRC="$(dirname $(realpath -s $0))/kernel"
export KERNEL_BUILD_DIR="$KERNEL_SRC/build"

build_bootloader(){
    if [ -z $EDK_PATH ]; then
        EDK_PATH="$HOME/src/build/edk2"
    fi
    EDK_PATH=$EDK_PATH $KERNEL_SRC/boot/build-efi.sh
}

mkdir $KERNEL_BUILD_DIR

build_bootloader