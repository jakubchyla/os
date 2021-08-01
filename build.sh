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
        *)
            printf "unknown command\n" >&2
            exit 1
        ;;
    esac
}


main $@