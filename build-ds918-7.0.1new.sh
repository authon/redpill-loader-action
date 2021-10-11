#!/bin/bash

# prepare build tools
sudo apt-get update && sudo apt-get install --yes --no-install-recommends ca-certificates build-essential git libssl-dev curl cpio bspatch vim gettext bc bison flex dosfstools kmod jq

root=`pwd`
mkdir ds918-7.0.1
mkdir output
cd ds918-7.0.1

# download redpill
git clone --depth=1 https://github.com/jumkey/redpill-lkm.git
git clone --depth=1 --branch=develop https://github.com/jumkey/redpill-load.git

# download syno toolkit
curl --location "https://sourceforge.net/projects/dsgpl/files/toolkit/DSM7.0/ds.geminilake-7.0.dev.txz/download" --output ds.geminilake-7.0.dev.txz

mkdir geminilake
tar -C./geminilake/ -xf ds.geminilake-7.0.dev.txz usr/local/x86_64-pc-linux-gnu/x86_64-pc-linux-gnu/sys-root/usr/lib/modules/DSM-7.0/build

# build redpill-lkm
cd redpill-lkm
make LINUX_SRC=../geminilake/usr/local/x86_64-pc-linux-gnu/x86_64-pc-linux-gnu/sys-root/usr/lib/modules/DSM-7.0/build test-v7
read -a KVERS <<< "$(sudo modinfo --field=vermagic redpill.ko)" && cp -fv redpill.ko ../redpill-load/ext/rp-lkm/redpill-linux-v${KVERS[0]}.ko || exit 1
cd ..

# build redpill-load
cd redpill-load
cp ${root}/user_config.DS918+.json ./user_config.json
sudo ./build-loader.sh 'DS918+' '7.0.1-42218'
mv images/rp-918-v7.0.1*.img ${root}/output/
cd ${root}
