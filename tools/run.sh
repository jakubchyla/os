#! /usr/bin/env bash

while [ $# -gt 0 ]; do
    key=$1
    case $key in
        -i|--img)
            IMG_FILE="$2"
            shift; shift
        ;;
        -e|--ovmf)
            OVMF_PATH="$2"
            shift; shift
        ;;
    esac
done

if [ -z $IMG_FILE ]; then
    printf "IMG_FILE not specified\n" >&2
    exit 1
fi
if [ -z $OVMF_PATH ]; then
    printf "OVMF_PATH not specified\n" >&2
    exit 1
fi

qemu-system-x86_64 -cpu qemu64 \
    -boot order=d \
    -bios "$OVMF_PATH" \
    -drive file="$IMG_FILE",format=raw
