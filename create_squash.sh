#!/bin/sh
#
#
#
rm -f new_iso/LiveOS/squashfs.img 
mksquashfs squashfs_root new_iso/LiveOS/squashfs.img

