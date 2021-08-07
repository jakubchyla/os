#! /usr/bin/env bash

generate_target()
{
    printf "%s\n" \
        "ACTIVE_PLATFORM = efi_loader/efi_loader.dsc" \
        "TARGET          = $TARGET" \
        "TARGET_ARCH     = X64" \
        "TOOL_CHAIN_CONF = Conf/tools_def.txt" \
        "TOOL_CHAIN_TAG  = GCC5" \
        "BUILD_RULE_CONF = Conf/build_rule.txt"
}

build_efi()
{
    if [ -z "$EDK_PATH" ]; then
        printf "EDK_PATH not specified\n" >&2
        exit 1
    fi
    if [ ! -d "$EDK_PATH" ]; then
        printf "$EDK_PATH does not exist\n" >&2
        exit 1
    fi
    if [ -z "$BUILD_DIR" ]; then
        printf "BUILD_DIR not specified\n" >&2
        exit 1
    fi
    if [ -z $TARGET ]; then
        TARGET="DEBUG"
    fi

    export EDK_TOOLS_PATH="$EDK_PATH/BaseTools"
    export PACKAGES_PATH="$EDK_PATH"

    mkdir -p "$CONF_PATH"

    pushd "$EDK_PATH" > /dev/null
    source edksetup.sh
    popd > /dev/null

    generate_target > "$WORKSPACE/Conf/target.txt"

    mkdir -p "$BUILD_DIR"

    pushd "$EDK_PATH" > /dev/null
    build -n $(nproc) -D "BUILD_DIR=$BUILD_DIR"
}

clear_conf()
{
    rm -rf "$CONF_PATH"
}

main(){
    export WORKSPACE="$(dirname $(realpath -s $0))"
    export CONF_PATH="$WORKSPACE/Conf"

    if [ $# -eq 0 ]; then
        printf "no command given for build-efi.sh, leaving...\n" >&2
        exit 1
    fi

    case $1 in
        build)
            build_efi
            shift
        ;;
        clear)
            clear_conf
            shift
        ;;
        *)
            printf "unknown command\n" >&2
            exit 1
        ;;
    esac
}


main $@