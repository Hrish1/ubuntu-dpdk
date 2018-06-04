#!/bin/bash
#
# This script downloads, installs and configure the Intel DPDK framework
# on a clean Ubuntu 16.04 installation running in a virtual machine.
# 
# This script has been created based on the following scripts:
#  * https://gist.github.com/ConradIrwin/9077440
#  * http://dpdk.org/doc/quick-start

# Configure hugepages.
# You can later check if this change was successful with "cat /proc/meminfo"
# Hugepages setup should be done as early as possible after boot
# Note: hugepages setup does not persist across reboots.
HUGEPAGE_MOUNT=/mnt/huge
echo 1024 | sudo tee /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
sudo mkdir ${HUGEPAGE_MOUNT}
sudo mount -t hugetlbfs nodev ${HUGEPAGE_MOUNT}

# Install dependencies.
sudo apt-get update
sudo apt-get -y -q install git clang doxygen hugepages build-essential linux-headers-`uname -r` libmnl-dev libnuma-dev vim
 
# Get code from gatekeeper repository.
git clone -b vm --recursive https://github.com/cjdoucette/gatekeeper

# Move to the gatekeeper directory.
cd gatekeeper

# Setup Gatekeeper.
source setup.sh

# Path to the build dir.
echo "export RTE_SDK=${RTE_SDK}" >> ${HOME}/.profile

# Target of build process.
echo "export RTE_TARGET=${RTE_TARGET}" >> ${HOME}/.profile

# Bind secondary network adapters.
sudo dependencies/dpdk/tools/dpdk-devbind.py --bind=uio_pci_generic enp0s8
sudo dependencies/dpdk/tools/dpdk-devbind.py --bind=uio_pci_generic enp0s9
sudo dependencies/dpdk/tools/dpdk-devbind.py --bind=uio_pci_generic enp0s10
sudo dependencies/dpdk/tools/dpdk-devbind.py --bind=uio_pci_generic enp0s16

# Compile Gatekeeper.
make
