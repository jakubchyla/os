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
        
        # 0x14-0x17d


        return file_header_data


def main():
    loader = Loader()


if __name__ == "__main__":
    main()