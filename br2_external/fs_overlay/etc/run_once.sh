#!/bin/sh
echo "Running run_once.sh"
echo "ttyGS0::respawn:/sbin/getty -L ttyGS0 115200 linux" >> /etc/inittab
echo "tty1::once:/root/picodrive" >> /etc/inittab
mv /etc/init.d/S40xorg /etc/init.d/K40xorg
mv /etc/init.d/S97squid /etc/init.d/K97squid
mv /etc/init.d/S50nginx /etc/init.d/K50nginx
mv /etc/init.d/S99at /etc/init.d/K99at
mv /etc/init.d/S99iiod /etc/init.d/K99iiod
mv /etc/init.d/S30rpcbind /etc/init.d/K30rpcbind
echo "Sending SIGHUP to init"
kill -HUP 1
chmod -x /etc/run_once.sh
