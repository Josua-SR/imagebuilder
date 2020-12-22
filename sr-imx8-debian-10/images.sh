#!/bin/bash -e

# functions
cpio_create_at() {
	local root
	root="$1"

	cd "$root"
	cpio -H newc -o
	return $?
}

patch_initrd_uuid() {
	local INITRD=$1
	local UUID=$2
	local TEMP=`mktemp -d`
	mkdir -p "$TEMP/conf/conf.d"
	printf "ROOT=\"%s\"\n" "UUID=$FSUUID" > "$TEMP/conf/conf.d/default_root"
	echo conf/conf.d/default_root | cpio_create_at "$TEMP" 2>/dev/null | gzip >> $INITRD
	test $? != 0 && exit 1
	rm -rf "$TEMP"
}

# kiwi state
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

# MAIN

# configure bootargs
sed -E -i "s;^LINUX_KERNEL_CMDLINE=.*$;LINUX_KERNEL_CMDLINE=\"log_level=7 net.ifnames=0\";g" "$buildroot/etc/default/flash-kernel"

# install boot-script for selected image types
if [ "x$kiwi_type" = "xext4" ]; then
	env FK_MACHINE="SolidRun i.MX8MM HummingBoard Pulse" flash-kernel
	env FK_MACHINE="SolidRun i.MX8MP HummingBoard Pulse" flash-kernel
	env FK_MACHINE="SolidRun i.MX8MQ HummingBoard Pulse" flash-kernel
fi

# generate and configure a rootfs uuid
FSUUID=`uuidgen`
echo "UUID=$FSUUID / ext4 defaults 0 0" > /etc/fstab
patch_initrd_uuid /boot/initrd.img-* $FSUUID
# todo: propagate to mkfs
