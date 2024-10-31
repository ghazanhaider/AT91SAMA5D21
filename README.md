# AT91SAMA5D21 Gaming Board

These are config files and steps to run buildroot/Linux on my custom SAMA5D21C board.
What works for me:
- A DDR3L memory chip that is run at DLL-off specs (124MHz bus speed) and 166MHz bus
- HDLCD with backlight (LCDPWM work in progress)
- USB Gadget with ACM+ECM (I can connect to console AND get Internet through my desktop)
- NAND + PMECC ECC and UBI/UBIFS without errors
- JTAG OR SWD + Vcom UART through the MIPI connector (requires J-Link with VCom)
- Linux works at 5.10, 5.15.166/6.1.109/6.10.4-6.10.9 tested
  - Linux kernel 4.19.321 works after re-enabling NAND and LCD drivers and dtb rebuild. LCD still doesnt work, maybe devicetree changed
- Passes memtester/fio/dmatest benchmarks on multiple boards

## Update for V2 board
- Everything works similar to V1. No hardware errors but flux had to be cleaned on the board for NAND to work
- Using memory module W632GU6NB11I, it works exactly with the same settings as D1216ECMDXGJD at 166MHz


Whats broken:
- SAM-BA write to NAND fails occasionally unless board is isolated from surfaces. NAND has no failures through stress tests in Linux etc so it might be how the IO is driven in SAM-BA. Bootstrap, UBOOT and Linux all drive Io at medium IO strength without issues


## Individual config files
br_config                           : Buildroot .config file
linux_config                        : The Linux kernel .config file. Last tested under 6.10.5-6.10.8
linux-linux4microchip-2024.04.patch : Patch that forces JEDEC mode1 speeds for my NAND chip. Last tested 6.10.5-6.10.8
uboot_config                        : UBoot config
uboot.dts                           : The embedded dts for UBoot for my board. It should eventually be merged with Linux's dts
at91bootstrap3_config               : AT91Bootstrap .config file that works with the patch below applied
at91patch         		    : This patch dir enables our DDR3L RAM chip and extra bus speed options
ghazan-sama5d21.dts                 : Devicetree that works for my board
bluetooth-dbus.conf                 : This DBus config file enables Bluetooth for my ASUS BT 400 USB dongle
gadget.sh                           : The old USB gadget script, I no longer use it
fs_overlay                          : Overlaid after filesystem is built. Includes /etc/init.d/ files, inittab, extra bins


## Steps to build

(I will improve on these with proper defconfigs)

- Git clone buildroot
- Make a folder `mkdir /sama5d2`.
- Copy the buildroot config there: `cp AT91SAMA5D21/br_config /sama5d2/.config`
- Do any initial config change if you need to `make O=/sama5d2 nconfig` and save
- Build the toolchain first: `make O=/sama5d2 toolchain`
- Build everything else: `make O=/sama5d2 all`
- <Some errors here are fixed, read next block>
- Copy over boot.bin, ghazan-sama5d21.dtb, rootfs.ubi, u-boot.bin, uImage to a machine with sam-ba 3.8 installed
- Connect a usb-c cable to USB-A port with the BOOT jumper off. Put on the jumper once power light is on
- Sam-ba commands that worked for me, please adjust your directories:
```
./sam-ba_v3.8/sam-ba -p serial -d sama5d2:4:1 -a nandflash:1:8:0xC2605007 -c erase::
./sam-ba_v3.8/sam-ba -p serial -d sama5d2:4:1 -a nandflash:1:8:0xC2605007 -c writeboot:boot.bin
./sam-ba_v3.8/sam-ba -p serial -d sama5d2:4:1 -a nandflash:1:8:0xC2605007 -c write:u-boot.bin:0x80000
./sam-ba_v3.8/sam-ba -p serial -d sama5d2:4:1 -a nandflash:1:8:0xC2605007 -c write:ghazan-sama5d21.dtb:0x180000
./sam-ba_v3.8/sam-ba -p serial -d sama5d2:4:1 -a nandflash:1:8:0xC2605007 -c write:uImage:0x1c0000
./sam-ba_v3.8/sam-ba -p serial -d sama5d2:4:1 -a nandflash:1:8:0xC2605007 -c write:rootfs.ubi:0x800000
```
- Connect a serial cable to the UART4 pins by the SWD port and open a terminal emulator
- Press reset to reset the board
- It SHOULD boot into Linux, the default bootarg works for me.
- The USB host computer should also see a composite USB device: UART, storage and ETH. The console is on this UART at baud 115200

## Optional

Before building the final image, I also modify these files to make development easier:

- Add this line to inittab to enable login and shell through USB serial:
```
echo "ttyGS0::respawn:/sbin/getty -L ttyGS0 115200 linux" >> /etc/inittab
```

- Allow Root ssh logins:
```
sed -i  's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
```

- Rename services to disable them by default under /etc/init.d:
```
mv /etc/init.d/S30rpcbind /etc/init.d/K30rpcbind
mv /etc/init.d/S40bluetoothd /etc/init.d/K40bluetoothd
mv /etc/init.d/S40xorg /etc/init.d/K40xorg
mv /etc/init.d/S50nginx /etc/init.d/K50nginx
mv /etc/init.d/S97squid /etc/init.d/K97squid
mv /etc/init.d/S99at /etc/init.d/K99at
mv /etc/init.d/S99iiod /etc/init.d/K99iiod
mv /etc/init.d/S99input-event-daemon /etc/init.d/K99input-event-daemon
```

### GCC 14.x incompatible type errors

GCC 14.x throws errors instead of warnings when types do not match, this breaks a few packages.
Here are two fixes that will show up in this config.
Once fixed, re-run `make O=/sama5d2 all`

Dillo package diff:
```
/sama5d2/build/dillo-3.0.5/dpi/https.c

482c482
<          if ((cn = strstr((const char *)X509_get_subject_name(remote_cert), "/CN=")) == NULL) {
---
>          if ((cn = strstr(X509_get_subject_name(remote_cert), "/CN=")) == NULL) {
```

Prboom package diff:
```
/sama5d2/build/prboom-2.5.0/src/SDL/i_main.c

359c359
<   myargv = (const char * const*) argv;
---
>   myargv = argv;
```


## Games and external packages

To enable prboom, change line 359 of file /sama5d2/build/prboom-2.5.0/src/SDL/i_main.c
from:
`myargv = argv;`
to:
`myargv = (const char * const*) argv;`
.. and recompile (re-run make)


To compile picodrive/dgen, pygame modules and other external packages, run `source /sama5d2/host/environment-setup` and then compile the external package. Install binaries back into /sama5d2/target/usr/bin/, or fs_overlay in this git repo


## Gadget fun

To enable USB Gadget serial + ECM Ethernet (works on MACOS without added drivers), follow these steps:
- Copy over the rcS file to /etc/init.d/rcS
- This will load composite module that makes the USB gadget a serial device, storage and ethernet device (3 in 1)
- Make an empty file called '/file' in your filesystem, something like `dd if=/dev/zero of=/sama5d2/target/file count=1k bs=1k`
- Boot

Here's the old manual method of setting up the gadget; I prefer the new kernel-only way above.
- Mount UBI rw: `mount -o remount,rw /`
- Add a line to /etc/fstab to automatically mount configfs:
`none            /sys/kernel/config      configfs        rw      0       0`
- Put the following script in a file on the device:
```
modprobe libcomposite
  cd /sys/kernel/config/usb_gadget
  mkdir g1
  cd g1
  echo "0x04D8" > idVendor
  echo "0x1234" > idProduct
  mkdir strings/0x409
  echo "0123456789" > strings/0x409/serialnumber
  echo "Ghazans USB gadget" > strings/0x409/manufacturer
  echo "Ghazans USB Gadget" > strings/0x409/product
  mkdir functions/ecm.usb0
  mkdir functions/acm.usb0
  mkdir configs/c.1
  mkdir configs/c.1/strings/0x409
  echo "CDC ACM+ECM" > configs/c.1/strings/0x409/configuration
  ln -s functions/ecm.usb0 configs/c.1
  ln -s functions/acm.usb0 configs/c.1
  echo "300000.gadget" > UDC

sleep 3
/sbin/ifconfig usb0 up
/sbin/udhcpc -i usb0 -b
```
- In my case this was /etc/gadget/sh
- Add a line in inittab to serve logins over the USB serial:
`ttyGS0::askfirst:/sbin/getty -L  ttyGS0 115200 xterm-256color`
- Add two lines in /etc/init.d/rcS to run gadget.sh:
```
modprobe libcomposite

/bin/sh /etc/gadget.sh
```
