#!/bin/bash -e

test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

# create ssh keys only on first boot
rm -fv /etc/ssh/*_key*
runonce-helper add generate-ssh-keys /usr/sbin/dpkg-reconfigure openssh-server

# enable watchdog
sed -i "s;^#?RuntimeWatchdogSec=.*;RuntimeWatchdogSec=60;g" /etc/systemd/system.conf

# configure repositories
cat > /etc/apt/sources.list << EOF
deb http://deb.debian.org/debian/ buster main
deb-src http://deb.debian.org/debian/ buster main
deb http://security.debian.org/debian-security buster/updates main
deb-src http://security.debian.org/debian-security buster/updates main
deb http://deb.debian.org/debian/ buster-updates main
deb-src http://deb.debian.org/debian/ buster-updates main

deb https://repo.solid-build.xyz/debian/buster/bsp-any /
deb-src https://repo.solid-build.xyz/debian/buster/bsp-any /
deb https://repo.solid-build.xyz/debian/buster/bsp-imx8v2 /
deb-src https://repo.solid-build.xyz/debian/buster/bsp-imx8v2 /
EOF

# configure first nic
cat > /etc/network/interfaces.d/eth0 << EOF
allow-hotplug eth0
iface eth0 inet dhcp
iface eth0 inet6 auto
EOF
