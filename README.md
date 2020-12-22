# SolidRun System Image Builder

## Build Image

Usage:

    kiwi-ng system build \
    	--description <path-to-description> \
    	--target-dir=<path-to-workspace> \
    	--signing-key=$DESCRIPTION/deb_10_release.key \
    	[...]

Examples:
- i.MX8 Debian 10

       kiwi-ng system build --description sr-imx8-debian-10 --target-dir=/tmp/my-image --signing-key=sr-imx8-debian-10/deb_10_release.key --signing-key=sr-imx8-debian-10/bsp_any.key --signing-key=sr-imx8-debian-10/bsp_imx8v2.key
