#/bin/sh
#
# Build Live Image based on LXQT
#

# vars
ks_file=teste.ks
image_name="LXQTFedora"

# Check livecd-creator
which livecd-creator 2> /dev/null
if [ $? == 1 ]; then
	sudo dnf install -y livecd-tools livecd-iso-to-mediums
fi

sudo setarch i686 livecd-creator --verbose --config=$ks_file --fslabel=$image_name --cache=/var/cache/live
