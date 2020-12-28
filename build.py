#!/usr/bin/env python3
import os
from glob import glob
import logging

from kiwi.command import Command
from kiwi.filesystem import FileSystem
from kiwi.storage.disk import Disk
from kiwi.storage.loop_device import LoopDevice
from kiwi.system.prepare import SystemPrepare
from kiwi.system.setup import SystemSetup
from kiwi.system.size import SystemSize
from kiwi.utils.block import BlockID
from kiwi.xml_description import XMLDescription
from kiwi.xml_state import XMLState

# helper
def calcdisksize(rootdir, fstype):
    size = SystemSize(rootdir)
    return size.customize(size=size.accumulate_mbyte_file_sizes(), requested_filesystem=fstype)

# settings
logging.getLogger('kiwi').setLogLevel(logging.INFO)
basedir = os.path.dirname(os.path.realpath(__file__))
descdir = basedir + '/sr-imx8-debian-10'
builddir = basedir + '/build'
rootdir = builddir + '/root'
repokeys = glob(descdir + '/*.key')
fstype = 'ext4'

# load description
description = XMLDescription(descdir + '/config.xml').load()
state = XMLState(description)

# prepare chroot
system = SystemPrepare(xml_state=state, root_dir=rootdir, allow_existing=True)
pkgmanager = system.setup_repositories(clear_cache=False, signing_keys=repokeys)
system.install_bootstrap(manager=pkgmanager, plus_packages=None)
system.install_system(manager=pkgmanager)

# configure chroot
setup = SystemSetup(xml_state=state, root_dir=rootdir)
setup.import_description()
setup.setup_groups()
setup.setup_users()
setup.call_config_script()

# clean after chroot
del pkgmanager
del setup
del system

# create disk image
lodev = LoopDevice(filename=builddir+'/disk.img', filesize_mbytes=calcdisksize(rootdir, fstype), blocksize_bytes=None)
lodev.create(overwrite=True)
disk = Disk(table_type='msdos', storage_provider=lodev, start_sector=16384)
disk.create_root_partition(mbsize='all_free')
disk.map_partitions()
system = FileSystem.new(name=fstype, device_provider=disk.get_device()['root'], root_dir=rootdir+'/', custom_args=None)
system.create_on_device(label=None)
system.sync_data(exclude=None)
state.set_root_partition_uuid(uuid=BlockID(device=disk.get_device()['root'].get_device()).get_blkid('PARTUUID'))

# run post-image script
setup = SystemSetup(xml_state=state, root_dir=system.get_mountpoint())
setup.import_description()
setup.call_disk_script()

# clean after disk image
del setup
del system
del disk

# insert u-boot binary
Command.run(command=['dd', 'conv=notrunc', 'of='+lodev.get_device(), 'if='+descdir+'/u-boot.bin', 'bs=1K', 'seek=32'])
del lodev
