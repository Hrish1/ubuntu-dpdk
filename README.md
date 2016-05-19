# DPDK Ubuntu 14.04 Vagrant VM
This project contains scripts and configuration files to create a Ubuntu 14.04 virtual machine with the Intel DPDK framework installed and fully configured.

## Setup
To set up a Vagrant virtual machine, first make sure that you have [Vagrant](http://www.vagrantup.com) installed and configured (this code has been tested with version 1.6.3).

On an Ubuntu host, you can get vagrant using:

    $ sudo apt-get install vagrant

At this stage, you are ready to set up the virtual machine with Intel DPDK.
Open a shell, move to the directory where this README file is located and type:

    $ vagrant up

This will create a Vagrant VM according to the configuration contained in `Vagrantfile` and then it will provision it by running the `provision.sh` script.

Provisioning is only automatically run at the very first boot (when the machine gets created). In order to properly configure the NICs for DPDK, this provision step should be done on every subsequent `up`, in which you need to explicitly provision:

    $ vagrant up --provision

This step will try to completely provision the machine and build DPDK fresh each time, which is not optimal. I soon hope to change this so that the only items that are executed when provisioning after the first  `up`, which is setting up the hugepages and configuring the NIC.

Once the machine is running, you can then SSH to it by executing:

    $ vagrant ssh

The virtual machine can then be suspended with:

    $ vagrant suspend

or shut down with:

    $ vagrant halt

or destroyed with:

    $ vagrant destory

Further information about the specific steps executed during this process can be found in the comments of the `provision.sh` and `Vagrantfile` files.

More information about the various sample applications can be found here: <http://dpdk.org/doc/guides/sample_app_ug/index.html>.

## Running pktgen

`pktgen` is a tool used to generate traffic on devices for DPDK applications. It's important to get it running so that we can quickly and easily test the DPDK code we write. More information is available here: <http://pktgen.readthedocs.io/en/latest/getting_started.html>.

It is a separate repository from the DPDK code. Theoretically, the setup steps for it could be put in the `provision.sh` file, but we need to fix a bug and move a file to get it to work, which is easier to do manually.

So after you have provisioned the VM, SSH into it:

    $ vagrant ssh

Then acquire the `pktgen-dpdk` repository and compile it:

    $ git clone http://dpdk.org/git/apps/pktgen-dpdk
    $ cd pktgen-dpdk
    $ make

At this step, I needed to change one file because `pktgen-dpdk` is not up-to-date with `dpdk`:

In `app/pktgen-pcap.c`, on line 268 replace:

    RTE_MBUF_ASSERT(mp->elt_size >= sizeof(struct rte_mbuf));

with (remove `MBUF_`):

    RTE_ASSERT(mp->elt_size >= sizeof(struct rte_mbuf));

Once it compiles, then do a setup step:

    $ sudo ./setup.sh

I again encountered a problem here. You need to make sure the `Pktgen.lua` file is in the same directory as the `pktgen` executable, which is kind of buried in `app/app/x86_64-native-linuxapp-gcc`. So still within the `pktgen-dpdk` directory:

    $ cp Pktgen.lua app/app/x86_64-native-linuxapp-gcc/
    $ cd app/app/x86_64-native-linuxapp-gcc/

To run, use the following command (you might be able to get others to do work depending on your configuration. More information about the command-line paramters here: <http://pktgen.readthedocs.io/en/latest/usage_pktgen.html>).

    $ sudo ./pktgen -c 0x3 -n 2 -- -P -m "1.0"

This command runs pktgen with lcores 0 and 1. "1:0" specifies that lcore1 will handle the traffic on port 0. lcore 0 is automatically assigned to the pktgen program. When you run it, some text will flash by showing the setup, and then only the packet generation numbers will be displayed. However, if you scroll up, you can verify the setup and should see "Display processing on lcore 0" means that lcore 0 will handle processing the pktgen program itself, and "RX/TX processing lcore  1 rxcnt 1 txcnt 1 port/qid, 0/0" means that lcore 1 is handling rx/tx traffic on port 0.

## Known Issues

In trying some of the examples, if they fail they may not properly release the pages that they were allocated. You can check how many hugepages you've allocated and how many are free by executing this command:

    $ grep -i huge /proc/meminfo
    AnonHugePages:         0 kB
    HugePages_Total:     912
    HugePages_Free:      912
    HugePages_Rsvd:        0
    HugePages_Surp:        0
    Hugepagesize:       2048 kB

Note that the provision.sh script tries to allocate 1024 of these 2048 kB hugepages, but if there's not enough space then fewer may be allocated, as in the case above.

To free all of the pages, you can force them to release by unmounting them and remounting them:

    $ sudo umount /mnt/huge
    $ sudo mount -t hugetlbfs nodev /mnt/huge

## Requirements
 * Vagrant 1.6.3+
 * VirtualBox 3.8+

## License
This project is released under the terms of [BSD License](http://en.wikipedia.org/wiki/BSD_licenses).
