#!/bin/sh
#
# This script sets up the virtual networks, if needed.

if ! ls /sys/class/net | grep -q "vboxnet0"; then
    VBoxManage hostonlyif create
fi
if ! ls /sys/class/net | grep -q "vboxnet1"; then
    VBoxManage hostonlyif create
fi
if ! ls /sys/class/net | grep -q "vboxnet2"; then
    VBoxManage hostonlyif create
fi
