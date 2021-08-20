#! /usr/bin/env python3

import sys
from typing import List, Dict

class Loader:
    def __init__(self) -> None:

        self.p_type_values: Dict[bytes, str] = {
            0                        : "PT_NULL",
            1                        : "PT_LOAD",
            2                        : "PT_DYNAMIC",
            3                        : "PT_INTERP",
            4                        : "PT_NOTE",
            5                        : "PT_SHLIB",
            6                        : "PT_PHDR",
            7                        : "PT_TLS",
            int("6FFFFFFF", base=16) : "PT_LOOS",
            int("70000000", base=16) : "PT_HIOS",
            int("7FFFFFFF", base=16) : "PT_HIPROC"
        }


        self.elf_data: bytes = self.load_file()
        self.file_header: Dict[str, bytes] = self.parse_file_header()

    
    def load_file(self) -> bytes:
        if len(sys.argv) < 2:
            print("specify elf path")
            sys.exit(1)
        with open(sys.argv[1], "rb") as f:
            return f.read()

    def parse_file_header(self) -> Dict[str, bytes]:
        file_header_data = dict()

        # 0x00-0x03 check magic number
        if self.elf_data[:0x04] != bytes.fromhex("7F 45 4c 46"):
            print("magic number incorrect", file=sys.stderr)
            sys.exit(1)
        
        # 0x04 32 or 64 bit, only 64 supported
        if self.elf_data[0x04] != bytes.fromhex("02"):
            print("EI_CLASS incorrect, only 32 bit is supported", file=sys.stderr)
            sys.exit(1)
        file_header_data["EI_CLASS"] = self.elf_data[4]

        # 0x05 endianess, only little supported
        if self.elf_data[0x05] != bytes.fromhex("01"):
            print("EI_DATA incorrect, only little endian supported", file=sys.stderr)
            sys.exit(1)
        file_header_data["EI_DATA"] = self.elf_data[5]       

        # 0x06 elf version, always 1
        if self.elf_data[0x06] != bytes.fromhex("01"):
            print("EI_VERSION incorrect", file=sys.stderr)

        # 0x07-0x0F size of EI_NIDENT - ignoring

        # 0x10-0x11 file type, expects executable file type (0x02)
        if self.elf_data[0x10:0x11] != bytes.fromhex("02"):
            print("wrong file type, only executable files are supported", file=sys.stderr)
            sys.exit(1)
        
        # 0x12-0x13 architecture, expects amd64(0x3E)
        if self.elf_data[0x12:0x14] != bytes.fromhex("3E"):
            print("wrong architecture, only amd64 supported", file=sys.stderr)
            sys.exit(1)
        
        # 0x14-0x17


        return file_header_data

    def parse_program_header(self, offset: int):
        program_header_data = dict()

        program_header_data["pt_type"]  = int(self.elf_data[offset:offset+0x4].hex(), base=16)
        program_header_data["p_flags"]  = int(self.elf_data[offset+0x4:offset+0x8].hex(), base=16)
        program_header_data["p_offset"] = int(self.elf_data[offset+0x8:offset+0x10].hex(), base=16)
        program_header_data["p_vaddr"]  = int(self.elf_data[offset+0x10:offset+0x18].hex(), base=16)
        program_header_data["p_paddr"]  = int(self.elf_data[offset+0x18:offset+0x20].hex(), base=16)
        program_header_data["p_filesz"] = int(self.elf_data[offset+0x20:offset+0x28].hex(), base=16)
        program_header_data["p_memsz"]  = int(self.elf_data[offset+0x28:0x30].hex(), base=16)
        program_header_data["p_align"]  = int(self.elf_data[offset+0x30:offset+0x38].hex(), base=16)

        return program_header_data
        


def main():
    loader = Loader()


if __name__ == "__main__":
    main()