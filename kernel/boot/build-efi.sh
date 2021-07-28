#! /usr/bin/env bash

generate_target(){
    printf "%s\n" \
        "ACTIVE_PLATFORM = bootloader/bootloader.dsc" \
        "TARGET          = $TARGET" \
        "TARGET_ARCH     = X64" \
        "TOOL_CHAIN_CONF = Conf/tools_def.txt" \
        "TOOL_CHAIN_TAG  = GCC5" \
        "BUILD_RULE_CONF = Conf/build_rule.txt"
}

if [ -z "$EDK_PATH" ]; then
    printf "EDK_PATH not set\n" >&2
    exit -1
fi
if [ -z $TARGET ]; then
    TARGET="DEBUG"
fi

export WORKSPACE="$KERNEL_SRC/boot"
export EDK_TOOLS_PATH="$EDK_PATH/BaseTools"
export PACKAGES_PATH="$EDK_PATH"

mkdir "$WORKSPACE/Conf"

pushd "$EDK_PATH" > /dev/null
source edksetup.sh
popd > /dev/null

generate_target > "$WORKSPACE/Conf/target.txt"

mkdir -p "$KERNEL_BUILD_DIR/boot"

pushd "$EDK_PATH" > /dev/null
build -n $(nproc) -D "BUILD_DIR=$KERNEL_BUILD_DIR"

