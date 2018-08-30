# fedora-lxqt-common.ks
#
# Description:
# – Fedora Live Spin with the LXQt desktop environment
#
# Maintainer(s):
# – Christian Dersch <lupinix@fedoraproject.org>
#

%packages
@lxqt
@lxqt-apps
@networkmanager-submodules
@basic-desktop
@critical-path-apps
@critical-path-base
@critical-path-lxqt
@legacy-software-support
@lxqt-apps
@lxqt-desktop
@networkmanager-submodules
@system-tools
@workstation-product

# for nm applet
gnome-keyring

# l10n
lxqt-l10n
lximage-qt-l10n
obconf-qt-l10n
pavucontrol-qt-l10n

# MP3
gstreamer1-plugin-mpg123

# remove unneeded stuff to get a lightweight system
# fonts (we make no bones about admitting we're english-only)
wqy-microhei-fonts          # a compact CJK font, to replace:
-naver-nanum-gothic-fonts       # Korean
-vlgothic-fonts             # Japanese
-adobe-source-han-sans-cn-fonts     # simplified Chinese
-adobe-source-han-sans-tw-fonts     # traditional Chinese

-paratype-pt-sans-fonts # Cyrillic (already supported by DejaVu), huge
#-stix-fonts        # mathematical symbols

# remove input methods to free space
-@input-methods
-scim*
-m17n*
-ibus*
-iok

# Fix https://bugzilla.redhat.com/show_bug.cgi?id=1429132
# Why is this not pulled in by anaconda???
storaged

# Custom Packages
dejavu-lgc-sans-fonts
dejavu-lgc-sans-mono-fonts
dejavu-lgc-serif-fonts
dracut-config-generic
hddtemp
hdparm
htop
rdesktop
-BackupPC
-NetworkManager-l2tp
-NetworkManager-libreswan
-NetworkManager-openconnect
-NetworkManager-openvpn
-NetworkManager-vpnc
-bonnie++
-jigdo
-openconnect
-openvpn
-thunderbird
-tigervnc
-vpnc

%end
