#! /usr/bin/env python3

import sys
from typing import List, Dict

class Loader:
    def __init__(self) -> None:
        self.elf_data: bytes = self.load_file()
        self.file_header: Dict[str, bytes] = self.parse_file_header()

    
    def load_file(self) -> bytes:
        if len(sys.argv) < 2:
            print("specify elf path")
            sys.exit(1)
        with open(sys.argv[1], "rb") as f:
            return f.read()

    def parse_file_header(self) -> Dict[str, int]:
        file_header_data = dict()

        # 0x00-0x03 check magic number
        if self.elf_data[0x00:0x04] != bytes.fromhex("7F 45 4c 46"):
            print("magic number incorrect", file=sys.stderr)
            sys.exit(1)
        
        # 0x04 32 or 64 bit, only 64 supported
        if self.elf_data[0x04] != 0x02:
            print("EI_CLASS incorrect, only 64 bit is supported", file=sys.stderr)
            sys.exit(1)

        # 0x05 endianess, only little endian supported
        if self.elf_data[0x05] != 0x01:
            print("EI_DATA incorrect, only little endian supported", file=sys.stderr)
            sys.exit(1)

        # 0x06 elf version, always 1
        if self.elf_data[0x06] != 0x01:
            print("EI_VERSION incorrect", file=sys.stderr)
            sys.exit(1)

        # 0x07-0x0F size of EI_NIDENT - ignoring

        # 0x10-0x11 file type, expects executable file type (0x02)
        if self.elf_data[0x10:0x12] != bytes.fromhex("02 00"):
            print("wrong file type, only executable files are supported", file=sys.stderr)
            # ignoring in prototype
            # sys.exit(1)
        
        # 0x12-0x13 architecture, expects amd64(0x3E)
        if self.elf_data[0x12:0x14] != bytes.fromhex("3E 00"):
            print("wrong architecture, only amd64 supported", file=sys.stderr)
            sys.exit(1)
        
        # 0x14-0x17 elf version, always 1
        if self.elf_data[0x14:0x18] != bytes.fromhex("01 00 00 00"):
            print("EI_VERSION incorrect", file=sys.stderr)
            sys.exit(1)
        
        # 0x18-0x1F entry point
        file_header_data["e_entry"]     = int(self.elf_data[0x18:0x20].hex(), base=16)

        # 0x20-0x27 e_phoff - program header file table's file offset in bytes
        file_header_data["e_phoff"]     = int(self.elf_data[0x20:0x28].hex(), base=16)

        # 0x28-0x2F e_shoff - section header table's file offset in bytes
        file_header_data["e_shoff"]     = int(self.elf_data[0x28:0x30].hex(), base=16)

        # 0x30-0x33 cpu-specific flags, amd64 defines no flags - ignoring

        # 0x34-0x35 e_ehsize - elf header's size in bytes
        file_header_data["e_ehsize"]    = int(self.elf_data[0x34:0x36].hex(), base=16)

        # 0x36-0x37 e_phentsize - size, in bytes, of a program header table entry
        file_header_data["e_phentsize"] = int(self.elf_data[0x36:0x38].hex(), base=16)

        # 0x38-0x39 e_phnum - number of entries in the program header table
        file_header_data["e_phnum"]     = int(self.elf_data[0x38:0x40].hex(), base=16)

        # 0x3A-0x3B e_shentsize - size, in bytes, of a section header table entry
        file_header_data["e_shentsize"] = int(self.elf_data[0x3A:0x3C].hex(), base=16)

        # 0x3C-0x3D e_shnum - number of entries in the section header table
        file_header_data["e_shnum"]     = int(self.elf_data[0x3C:0x3E].hex(), base=16)

        # 0x3E-0x3F e_shstrndx - section header table index of the section containing the section name string table
        file_header_data["e_shtrndx"]   = int(self.elf_data[0x3E:0x40].hex(), base=16)

        print(file_header_data)

        return file_header_data


def main():
    loader = Loader()


if __name__ == "__main__":
    main()