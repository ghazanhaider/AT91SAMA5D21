# Compiling Retroarch

```
source /sama5d21/host/environment-setup
git clone https://github.com/libretro/RetroArch.git retroarch
cd retroarch

PKG_CONF_PATH=/sama5d21/host/bin/pkg-config ./configure --prefix=/sama5d21/target --disable-audiomixer --disable-microphone  --disable-cdrom --disable-videocore --disable-langextra --disable-vulkan_display --disable-vulkan --disable-bsv_movie --disable-qt --enable-floathard --disable-alsa --disable-wayland --disable-x11 --disable-sdl2

git clone https://github.com/libretro/libretro-super.git
cd libretro-super

./libretro-fetch.sh picodrive
./libretro-build.sh picodrive

# Add "CC=aarch64-linux-gnu-gcc CXX=aarch64-linux-gnu-g++" after "make" in libretro-picodrive/platform/common/common.mak
# retry build

./libretro-build.sh quicknes
./libretro-fetch.sh quicknes

# Add
DESTDIR=/sama5d21/target/ make install
```
