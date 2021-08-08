CC := clang
CFLAGS := -target x86_64-unknown-windows -ffreestanding -fshort-wchar -mno-red-zone -fno-stack-protector
CFLAGS += -I include -I include/X64
LD := lld-link-11
LDFLAGS := -subsystem:efi_application -nodefaultlib -dll -entry:uefi_main
 
default: bootx64.efi

bootx64.efi: efi_loader.o
	$(LD) $(LDFLAGS) /out:bootx64.efi efi_loader.o

efi_loader.o: efi_loader.c
	$(CC) $(CFLAGS) -c -o efi_loader.o efi_loader.c

.PHONY	:	clean
 
clean:
	rm -f bootx64.efi bootx64.lib efi_loader.o