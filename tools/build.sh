#! /usr/bin/env bash

build_bootloader()
{
    EDK_PATH=$EDK_PATH \
    BUILD_DIR=$BUILD_DIR \
    "$SRC_DIR/boot/build-efi.sh" build
}

clear_build()
{
    "$SRC_DIR/boot/build-efi.sh" clear
    rm -rf $BUILD_DIR
}

make_image()
{
    EFI_FILE="$BUILD_DIR/boot/DEBUG_GCC5/X64/efi_loader.efi" \
    OUTPUT_FILE="$BUILD_DIR/os.img" \
    "$TOOLS_DIR/make-image.sh"
}


main()
{
    export SRC_DIR="$(dirname $(realpath -s $0))/.."
    export BUILD_DIR="$SRC_DIR/build"
    TOOLS_DIR="$SRC_DIR/tools"

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
                EDK_PATH="$2"
                shift; shift
            ;;
            --efi)
                EFI_FILE="$2"
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
            mkdir $BUILD_DIR 2> /dev/null
            build_bootloader
        ;;
        build-bootloader)
            mkdir $BUILD_DIR 2> /dev/null
            build_bootloader
        ;;
        clear)
            clear_build
        ;;
        rebuild)
            clear_build
            mkdir $BUILD_DIR 2> /dev/null
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