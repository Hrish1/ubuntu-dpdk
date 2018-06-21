#!/bin/bash
#
# This script sets up the virtual networks, if needed.

if ! ls /sys/class/net | grep -q "vboxnet0"; then
    VBoxManage hostonlyif create
    VBoxManage hostonlyif ipconfig vboxnet0 -ip 10.0.10.254
fi
if ! ls /sys/class/net | grep -q "vboxnet1"; then
    VBoxManage hostonlyif create
    VBoxManage hostonlyif ipconfig vboxnet1 -ip 10.0.11.254
fi
if ! ls /sys/class/net | grep -q "vboxnet2"; then
    VBoxManage hostonlyif create
    VBoxManage hostonlyif ipconfig vboxnet2 -ip 10.0.12.254
fi
if ! ls /sys/class/net | grep -q "vboxnet3"; then
    VBoxManage hostonlyif create
    VBoxManage hostonlyif ipconfig vboxnet3 -ip 10.0.13.254
fi
