#! /usr/bin/env bash

while [ $# -gt 0 ]; do
    key=$1
    case $key in
        -e|--efi)
            EFI_FILE="$2"
            shift; shift
        ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift; shift
        ;;
    esac
done

if [ -z "$EFI_FILE" ]; then
    printf "EFI_FILE not specified\n" >&2
    exit 1
fi
if [ -z "$OUTPUT_FILE" ]; then
    printf "OUTPUT_FILE not specified\n" >&2
    exit 1
fi

truncate -s 1M $OUTPUT_FILE
truncate -s 64M efipart
truncate -s 64M ospart

mkfs.fat -F32 efipart
mkfs.fat -F32 ospart

mmd -i efipart ::/EFI
mmd -i efipart ::/EFI/BOOT
mcopy -i efipart "$EFI_FILE" ::/EFI/BOOT/BOOTX64.EFI

cat efipart >> $OUTPUT_FILE
cat ospart >> $OUTPUT_FILE

rm efipart ospart

parted --script "$OUTPUT_FILE" \
    mklabel gpt \
    mkpart efi_part fat32 1MiB 65MiB \
    mkpart os_part fat32 65MiB 100% \
    set 1 esp on

