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

- Git clone buildroot: `git@github.com:buildroot/buildroot.git`
- Make an output folder `mkdir /sama5d21`
- Go into the buildroot folder: `cd buildroot`
- Setup the output folder for our build: `make BR2_EXTERNAL=/home/user1/AT91SAMA5D21/br2_external O=/sama5d21 AT91SAMA5D21_defconfig`
- Go into the build folder for the rest of the build: `cd /sama5d21`
- Optional: Do any initial config change if you need to `make nconfig` and save
- Build the toolchain first: `make toolchain`
- Build everything else: `make all`
- Go into the images folder to find the resulting images: `cd images`


## Steps to image your board

- Download Microchip sam-ba (I used 3.8.0 and 3.8.1) to image the board
- The Linux version: https://github.com/atmelcorp/sam-ba/releases/download/v3.8.1/sam-ba_v3.8.1-linux_x86_64.tar.gz
- Connect a usb-c cable to USB-A port with the BOOT button pressed, and then release the button
- Sam-ba commands that worked for me, please adjust your directories:
```
./sam-ba_v3.8/sam-ba -p serial -d sama5d2:4:1 -a nandflash:1:8:0xC2605007 -c erase::
./sam-ba_v3.8/sam-ba -p serial -d sama5d2:4:1 -a nandflash:1:8:0xC2605007 -c writeboot:boot.bin
./sam-ba_v3.8/sam-ba -p serial -d sama5d2:4:1 -a nandflash:1:8:0xC2605007 -c write:u-boot.bin:0x80000
./sam-ba_v3.8/sam-ba -p serial -d sama5d2:4:1 -a nandflash:1:8:0xC2605007 -c write:uboot-env.bin:0x140000
./sam-ba_v3.8/sam-ba -p serial -d sama5d2:4:1 -a nandflash:1:8:0xC2605007 -c write:ATSAMA5D21.dtb:0x180000
./sam-ba_v3.8/sam-ba -p serial -d sama5d2:4:1 -a nandflash:1:8:0xC2605007 -c write:uImage:0x1c0000
./sam-ba_v3.8/sam-ba -p serial -d sama5d2:4:1 -a nandflash:1:8:0xC2605007 -c write:rootfs.ubi:0x800000 -L 262144
```
- Connect a serial cable to the UART0 pins (J10 in V1) by the SWD port and open a terminal emulator
- Press reset to reset the board
- It SHOULD boot into Linux, the default bootarg works for me.
- The USB host computer should also see a composite USB device: UART, storage and ETH. The console is on this UART at baud 115200


## Development

As you modify nconifg, linux-nconfig, uboot-nconfig etc, update them after testing them out:

BR2 Config: `make update-defconfig`
Linux: `make linux-update-config`
U-Boot: `uboot-update-config`
AT91Bootstrap3: `at91bootstrap3-update-config`

## Notes

There is a file `/etc/run_once.sh` which is run during the first boot only.
It enables getty login over the USB gadget serial port, disables a few services and runs *picodrive*

- The ethernet device is named `usb0` and no IP config or dhcp is run. If your host has a dhcp server you can run `udhcpc -i usb0 -n` to get an IP
 
- Allow Root ssh logins:
```
sed -i  's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
```

- The environment file is already compiled `u-boot-env.bin`. It was compiled using mkenvimage:
`mkenvimage uboot.env 0x20000 -o u-boot-env.bin`
Run this command if you need to make a change to the uboot environment in uboot.env


### GCC 14.x incompatible type errors

(Update: I've updated the config to use GCC 13.x to bypass these errors)

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


## Gadget fun (Old notes, no longer needed)

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
