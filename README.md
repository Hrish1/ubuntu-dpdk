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

# Known Issues

I have not yet been able to get any examples running except for the hello world example. In trying some of the examples, if they fail they may not properly release the pages that they were allocated. You can force them to release by unmounting them and remounting them:

    $ sudo umount /mnt/huge
    $ sudo mount -t hugetlbfs nodev /mnt/huge

# Requirements
 * Vagrant 1.6.3+
 * VirtualBox 3.8+

# License
This project is released under the terms of [BSD License](http://en.wikipedia.org/wiki/BSD_licenses).
