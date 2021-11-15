#!/bin/bash

fdisk /dev/sda

sudo blkid | grep "^/dev/sda3:" | awk -F\" '{ print $2 }' | sudo dd of=/root/NewPartUUID

DISKNAME=$(sudo blkid | grep $(sudo cat /root/NewPartUUID) | awk -F: '{ print $1 }')
mkfs -t ext4 -b 4096 $DISKNAME

dumpe2fs -h $DISKNAME

tune2fs -i 2m -c 2 $DISKNAME

mkdir /mnt/newdisk/
mount $DISKNAME /mnt/newdisk

ln -s /mnt/newdisk ~/nd

mkdir /mnt/newdisk/abc

/dev/sda3 /mnt/newdisk ext4 noexec,noatime  0 0

umount $DISKNAME && fdisk /dev/sda
e2fsck -f /dev/sda3
resize2fs $DISKNAME

e2fsck -fv $DISKNAME

fdisk /dev/sda

fdisk /dev/sdb

lvmdiskscan
pvcreate /dev/sdb1 /dev/sdb2
vgcreate volumeGr /dev/sdb1 /dev/sdb2
lvcreate -L 192M -n lv volumeGr
lvscan
mkfs -t ext4 /dev/volumeGr/lv
mkdir /mnt/supernewdisk && mount /dev/volumeGr/lv /mnt/supernewdisk

mkdir /mnt/share
sudo mount -t fuse.vmhgfs-fuse .host:/share /mnt/share

.host:/share /mnt/share fuse.vmhgfs-fuse defaults 0 0