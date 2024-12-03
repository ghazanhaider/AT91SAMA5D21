# DDR timings


## D1216ECMDXGJD-U
2k page size
16Mwords x 16bits x 8banks
Row address: A0 - A13
Column Address: A0 to A9

TIMINGS
nRP = 13
nRRD = 6
tREFI = 7.8us

DATASHEET for 1833 (1.071 tCK):
tRAS Active to Precharge Delay: 32+ (JEDEC 38)
tRCD Row to column delay: 13+  (JEDEC 13)
tWR Write Recovery Delay: ? (JEDEC 15)
tRC Row Cycle Delay: 45+ (JEDEC 50)
tRP Row Precharge Delay: 13+ (JEDEC 13)
tRRD Active Bank1 to Active Bank2: 6 (JEDEC 10)
tWTR Internal Write to Read Delay: ?
tMRD Load MR cmd to Activate cmd:  (JEDEC 4)
tRFC Row Cycle Delay: 150
tTXSNR Exit Self Refresh delay: 
tTXSRD Exit Self Refresh delay: 
tTXP Exit pwr down delay to first cmd: 
tTRPA Row Precharge All Delay:
tTRTP Read to Precharge
tTFAW Four Active Windows : 33
RTC Refresh Timer Counter

RECALC above for 124MHz/8.06 ns (x 1.071 / 8.065 = 0.1328):
tRAS Active to Precharge Delay: 5+ (JEDEC 38) (0-15 allowed)
tRCD Row to column delay: 2+  (JEDEC 13) (0-15 allowed)
tWR Write Recovery Delay: ? (JEDEC 15) (1-15 allowed)
tRC Row Cycle Delay: 6+ (JEDEC 50) (0-15 allowed)
tRP Row Precharge Delay: 2+ (JEDEC 13) (0-15 allowed)
tRRD Active Bank1 to Active Bank2: 1 (JEDEC 10) (1-15 allowed)
tRFC Row Cycle Delay: 20 (0-127 allowed)
tMRD Load MR cmd to Activate cmd:  (JEDEC 4) (0-15 allowed)
tWTR Internal Write to Read Delay: ? (1-7 allowed)
tTXSNR Exit Self Refresh delay: same as tXS? (0-255 allowed)
tTXSRD Exit Self Refresh delay: 0 for DLL off
tTXP Exit pwr down delay to first cmd: (0-15 allowed)
tTRPA Row Precharge All Delay: DDR2 only
tTRTP Read to Precharge: (0-7 allowed)
tTFAW Four Active Windows : 5 (0-15 allowed)
RTC Refresh Timer Counter (3.9us): 483 (0x1e3)
TZQIO@124MHz in 600ns: 75 (0-127 allowed)

CAS MUST be set to 5
SHIFT_SAMPLING MUST be set to 2 in MPDDRC_RD_DATA_PATH (0x5c)
ZQCS calibration delay 0-255 clocks in MPDDRC_LPDDR2_LPDDR3_DDR3_TIM_CAL (0x30)
Output impedance 3 or 4 in RDIV in reg MPDDRC_IO_CALIBR (0x34)
Disable off chip scrambling MPDDRC_OCMS

## TESTS
Try DIC_DS 0 (normal drive strength RZQ/6) in MPDDRC_CR (0x8) UNDONE
TRRD 2
ZQCS set to 15+ in MPDDRC_LPDDR2_LPDDR3_DDR3_TIM_CAL (0x30) TESTED 15 and 215
RDIV RZQ_60_RZQ_57_RZQ_55_RZQ_52 in MPDDRC_IO_CALIBR (0x34) FAILED, trying 
TZQIO 75 from 80



EXAMPLE (CONFIG_DDR_MT41K128M16_D2@114MHz)
		.tras = 5,
        .trcd = 2,
        .twr = 4,
        .trc = 6,
        .trp = 2,
        .trrd = 4,
        .twtr = 4,
        .tmrd = 4,
        .trfc = 19,
        .txsnr = 21,
        .txsrd = 0,
        .txp = 10,
        .txard = 0,
        .txards = 0,
        .trpa = 0,
        .trtp = 4,
        .tfaw = 5,

but JEDEC for 800MHz is:
        .tras = 38,
        .trcd = 13,
        .trp = 13,
        .trc = 50,
        .twtr = 8,
        .trrd = 10,
        .twr = 15,
        .tmrd = 4,


From D1216 datasheet for 1833MHz speed bin:
CL = 13ns min
TRCD = 13ns min
TRP = 13ns min
TRAS = 34ns min (9x tREFI max)
TCK@CL6 = (given CWL=5, 303MHz to 400MHz)

TAA = 13.91 to 20ns 
TRC = 47.91ns min






## REGs

MPDDRC_RTR 0x300a21
MPDDRC_CR  0xd0036d  (rows, columns, DLL)
MPDDRC_TPR0 0x40239337


## Order
MPDDRC_MD
MPDDRC_RD_DATA_PATH
gram MPDDRC_LPDDR2_LPDDR3_DDR3_CAL_MR4, MPDDRC_LPDDR2_LPDDR3_DDR3_TIM_CAL,
MPDDRC_IO_CALIBR.
MPDDRC_CR
MPDDRC_TPR0
MPDDRC_TPR1
5. A NOP command is issued to the DDR3-SDRAM. Program the NOP command in the Mode register
(MPDDRC_MR). The application must configure the MODE field to 1 in the MPDDRC_MR. Read the
MPDDRC_MR and add a memory barrier assembler instruction just after the read. Perform a write access
to any DDR3-SDRAM addre
7. A NOP command is issued to the DDR3-SDRAM. Program the NOP command in the MPDDRC_MR. The
application must configure the MODE field to 1 in the MPDDRC_MR. Read the MPDDRC_MR and add
a memory barrier assembler instruction just after the read. Perform a write access to any DDR3-SDRAM
address to acknowledge this command. CKE is now driven high.






## IO CAL
Impedance:
3
AT91C_MPDDRC_RDIV_DDR2_RZQ_50 (default = 4)
AT91C_MPDDRC_RDIV_DDR2_RZQ_66_7 (7)
:q
:q


## TEST
W4 0x20000000 0x55555555
Mem 0x20000000 0x4

