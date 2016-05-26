#!/bin/sh
#
# This script downloads, installs and configure the Intel DPDK framework
# on a clean Ubuntu 12.04 installation running in a virtual machine.
# 
# This script has been created based on the following scripts:
#  * https://gist.github.com/ConradIrwin/9077440
#  * http://dpdk.org/doc/quick-start

# Configure hugepages
# You can later check if this change was successful with "cat /proc/meminfo"
# Hugepages setup should be done as early as possible after boot
# Note: hugepages setup does not persist across reboots
HUGEPAGE_MOUNT=/mnt/huge
echo 1024 | sudo tee /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
sudo mkdir ${HUGEPAGE_MOUNT}
sudo mount -t hugetlbfs nodev ${HUGEPAGE_MOUNT}

# Install dependencies
sudo apt-get update
sudo apt-get -y -q install git clang doxygen hugepages build-essential linux-headers-`uname -r` libpcap-dev vim tshark
 
# Get code from Git repo.
#git clone http://dpdk.org/git/dpdk
# Get code from Cody's DPDK repo.
git clone https://github.com/cjdoucette/dpdk

# Move to the DPDK dir
cd dpdk
# For 12.04, checkout the precise version.
git checkout precise

# Path to the build dir
export RTE_SDK=`pwd`

# Target of build process
export RTE_TARGET=x86_64-native-linuxapp-gcc

# Build code
make config T=${RTE_TARGET}
make

# Install kernel modules
sudo modprobe uio
sudo insmod ${RTE_SDK}/build/kmod/igb_uio.ko

# Make uio and igb_uio installations persist across reboots 
sudo ln -s ${RTE_SDK}/build/kmod/igb_uio.ko /lib/modules/`uname -r`
sudo depmod -a
echo "uio" | sudo tee -a /etc/modules
echo "igb_uio" | sudo tee -a /etc/modules
 
# Bind secondary network adapters.
# Note: NIC setup does not persist across reboots
sudo ifconfig eth1 down
sudo ifconfig eth2 down
sudo ${RTE_SDK}/tools/dpdk_nic_bind.py --bind=igb_uio eth1
sudo ${RTE_SDK}/tools/dpdk_nic_bind.py --bind=igb_uio eth2

# Add env variables setting to .profile file so that they are set at each login
echo "export RTE_SDK=${RTE_SDK}" >> ${HOME}/.profile
echo "export RTE_TARGET=${RTE_TARGET}" >> ${HOME}/.profile

# We need to do this to make the examples compile, not sure why.
ln -s ${RTE_SDK}/build ${RTE_SDK}/${RTE_TARGET}
