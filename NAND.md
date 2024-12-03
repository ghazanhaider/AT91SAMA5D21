# NAND

SAM-BA ONFI
Page size 4096
Spare size 256
Page per block 64
Blocks per LUN 2048
ECC 8

## At91bootstrap ONFI:
AT91Bootstrap 4.0.9 (2024-06-13 18:06:27)

All interrupts redirected to AIC
NAND: ONFI flash detected
NAND: Manufacturer ID: 0x2c Chip ID: 0xdc
NAND: Page Bytes: 4096, Spare Bytes: 256
NAND: ECC Correctability Bits: 8, ECC Sector Bytes: 512
PMECC: page_size: 4096, oob_size: 256, pmecc_cap: 8, sector_size: 512
NAND: Initialize PMECC params, cap: 8, sector: 512
NAND: Image: Copy 0xa0000 bytes from 0x40000 to 0x26f00000




## Datasheet:
Page size: 4096 + 256 bytes
Pages per block: 64
Plane size: 1 planes
Device: 2048 blocks (4G)


## HEADER:
eccOffset: 4?
sectorSize/Size of ECC Sector: 0 (We decide 512 bytes per sector)
- 4 sectors per page
- 256 sectors per block
eccBitReq: 8
spareSizeinBytes: 64
- 64bytes per page, or 16 bytes/128bits per sector


= 0xC01044041 (INVALID!)

0xc0119005 FIRST ACCEPTED
0xc0119005
eccOffset: 4
sectorSize/Size of ECC Sector: 1 (1024)
eccBitReq: 4 (24bit ECC)
spareSizeinBytes: 256 (256 bytes)
sectorsPerPage: 2 (4 sectors per page)
PMECC: 1
======================
Now change header to match above!

eccOffset: 4
sectorSize/Size of ECC Sector: 0 (512)
eccBitReq: 2 (8bit ECC)
spareSizeinBytes: 256 (256 bytes)
sectorsPerPage: 3 (8 sectors per page)
PMECC: 1

= 0xC0105007
=====================
Lets make it 1024 sector size and move offset to 8, and 24ECC:

eccOffset: 8
sectorSize/Size of ECC Sector: 1 (1024)
eccBitReq: 4 (24bit ECC)
spareSizeinBytes: 256 (256 bytes)
sectorsPerPage: 3 (8 sectors per page)
PMECC: 1

= C0219005
==========================
crosscheck another part from SAM-BA:
MT29F4G08ABAEA: 0xc1e04e07 (4096+224)

eccOffset: 120 (0x78)
sectorSize/Size of ECC Sector: 0 (512 bytes)
eccBitReq: 2 (8bit ECC)
spareSizeinBytes: 224 (0xe0 224 bytes)
sectorsPerPage: 3 (8 sectors per page)
PMECC: 1

==========================

==========================
Back to 512,8ECC but end of OOB

eccOffset: 152 (0x98, shifted it is 0x260)
sectorSize/Size of ECC Sector: 0 (512)
eccBitReq: 2 (8bit ECC)
spareSizeinBytes: 256 (256 bytes)
sectorsPerPage: 3: (8 sectors per page)
PMECC: 1

= 0xC2605007

SUCCESS !! Keeping this
