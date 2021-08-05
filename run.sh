#! /usr/bin/env bash

export KERNEL_SRC="$(dirname $(realpath -s $0))/kernel"
export KERNEL_BUILD_DIR="$KERNEL_SRC/build"

if [ -z $OVMF_PATH ]; then
    OVMF_PATH="/usr/share/OVMF/OVMF_CODE.fd"
fi
if [ -z $IMG_FILE ]; then
    IMG_FILE="$KERNEL_BUILD_DIR/os.img"
fi

qemu-system-x86_64 -cpu qemu64 \
    -boot order=d \
    -bios "$OVMF_PATH" \
    -drive file="$IMG_FILE",format=raw
