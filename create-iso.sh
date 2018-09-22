#!/bin/sh
#
# Create iso file
#

# vars
ISO_FILENAME="Fedora-i386-28.iso"
ISO_LABEL="Fedora-i386-28"

echo -n "Gerando novo ISO: "
sudo genisoimage -U -r -v -T -J -joliet-long -V $ISO_LABEL \
      -volset $ISO_LABEL -A $ISO_LABEL \
      -hide-rr-moved -hide-joliet-trans-tbl \
      -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
      -boot-load-size 4 -boot-info-table -no-emul-boot -o $ISO_FILENAME new_iso/

sudo implantisomd5 $ISO_FILENAME

echo -n "Testando a nova ISO: "
sudo qemu-kvm -m 1024 -cdrom $ISO_FILENAME -boot d
echo -e "OK"
