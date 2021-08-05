#! /usr/bin/env bash

export KERNEL_SRC="$(dirname $(realpath -s $0))/kernel"
export KERNEL_BUILD_DIR="$KERNEL_SRC/build"

build_bootloader()
{
    EDK_PATH=$EDK_PATH "$KERNEL_SRC/boot/build-efi.sh" build
}

clear_build()
{
    "$KERNEL_SRC/boot/build-efi.sh" clear
    rm -rf $KERNEL_BUILD_DIR
}

make_image()
{
    EFI_FILE="${KERNEL_BUILD_DIR}/boot/DEBUG_GCC5/X64/efi_loader.efi"
    if ! [ -f "$EFI_FILE" ]; then
        printf "$EFI_FILE does not exist\n" >&2 
        return 1
    fi
    IMG_FILE="${KERNEL_BUILD_DIR}/os.img"

    dd if=/dev/zero of="${KERNEL_BUILD_DIR}/os.img" bs=1M count=128
    parted --script "$IMG_FILE" \
        mklabel gpt \
        mkpart efi_part fat32 1MiB 65MiB \
        mkpart os_part fat32 65MiB 100% \
        set 1 esp on
    LOOP_DEV=$(sudo losetup -f)
    sudo losetup -Pf "$IMG_FILE"
    sudo mkfs.fat -F32 "${LOOP_DEV}p1"
    sudo mkfs.fat -F32 "${LOOP_DEV}p2"

    MOUNT_DIR="/tmp/$(head /dev/urandom | tr -dc A-za-z0-9 | head -c 10)"
    mkdir "$MOUNT_DIR"
    sudo mount "${LOOP_DEV}p1" "$MOUNT_DIR"
    sudo mkdir -p "${MOUNT_DIR}/EFI/boot/"
    sudo cp "$EFI_FILE" "${MOUNT_DIR}/EFI/boot/bootx64.efi"
    sudo losetup -d "$LOOP_DEV"
    sync
}


main()
{
    if [ ! -d "kernel" ]; then
        printf "run this script from repo's root directory\n" >&2
        exit 1
    fi
    if [ $# -eq 0 ]; then
        printf "no option specified\n" >&2
        exit 1
    fi
    
    COMMAND=$1
    shift

    while [ $# -gt 0 ]; do
        key=$1
        case $key in
            --edk)
                EDK_PATH=$2
                shift; shift
            ;;
            *)
                printf "unknown option\n" >&2
                exit 1
            ;;
        esac
    done

    case $COMMAND in
        build-all|build)
            mkdir $KERNEL_BUILD_DIR 2> /dev/null
            build_bootloader
        ;;
        build-bootloader)
            mkdir $KERNEL_BUILD_DIR 2> /dev/null
            build_bootloader
        ;;
        clear)
            clear_build
        ;;
        rebuild)
            clear_build
            mkdir $KERNEL_BUILD_DIR 2> /dev/null
            build_bootloader
        ;;
        make-image)
            make_image
        ;;
        *)
            printf "unknown command\n" >&2
            exit 1
        ;;
    esac
}


main $@