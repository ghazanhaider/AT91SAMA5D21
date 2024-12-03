# Compiling Retroarch

```
source /sama5d21/host/environment-setup
git clone https://github.com/libretro/RetroArch.git retroarch
cd retroarch

PKG_CONF_PATH=/sama5d21/host/bin/pkg-config ./configure --prefix=/sama5d21/target --disable-audiomixer --disable-microphone --disable-crtswitchres --disable-glx --disable-cdrom --disable-videocore --disable-langextra --disable-audiomixer --disable-vulkan_display --disable-vulkan --disable-bsv_movie --disable-qt --enable-floathard --enable-neon --disable-alsa --disable-egl  --disable-wayland --disable-vg --disable-opengl --disable-opengl1 --disable-x11

PKG_CONF_PATH=/sama5d21/host/bin/pkg-config ./configure --prefix=/sama5d21/target --disable-audiomixer --disable-microphone  --disable-cdrom --disable-videocore --disable-langextra --disable-vulkan_display --disable-vulkan --disable-bsv_movie --disable-qt --enable-floathard --disable-alsa --disable-wayland --disable-x11 --disable-sdl2

-glsl -dynamic +coretext -sd2

make clean
make -j4


./libretro-build.sh picodrive
./libretro-build.sh picodrive
./libretro-build.sh quicknes
git clone https://github.com/libretro/libretro-super.git
cd libretro-super


DESTDIR=/sama5d21/target/ make install
```
