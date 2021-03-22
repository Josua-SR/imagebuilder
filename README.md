# SolidRun System Image Builder

## Install runtime dependencies

    apt-get install debootstrap kpartx libxml2-dev libxslt1-dev python3-pip python3-venv qemu-utils rsync zlib1g-dev
    python3 -m venv --prompt kiwi .venv
    source .venv/bin/activate
    pip3 install wheel
    pip3 install git+git://github.com/Josua-SR/kiwi.git@mine

## Build Image

    sudo mkdir -p /root/.gnupg
    sudo .venv/bin/python3 ./build.py
