# fedora-livecd-lxde.ks
#
# Description:
# - Fedora Live Spin with the light-weight LXDE Desktop Environment
#
# Maintainer(s):
# - Christoph Wickert <cwickert@fedoraproject.org>

%packages
### LXDE desktop
@lxde-desktop
@lxde-apps
@networkmanager-submodules

# FIXME: can be omitted once comps is updated
midori

# pam-fprint causes a segfault in LXDM when enabled
-fprintd-pam

# LXDE has lxpolkit. Make sure no other authentication agents end up in the spin.
-polkit-gnome
-polkit-kde

# make sure xfce4-notifyd is not pulled in
notification-daemon
-xfce4-notifyd

# make sure xfwm4 is not pulled in for firstboot
# https://bugzilla.redhat.com/show_bug.cgi?id=643416
metacity

# dictionaries are big
#-man-pages-*
#-words

# save some space
-autofs
-acpid
-gimp*
-xmms2*
-leafpad*
-pidgin*
-sylpheed*
-transmission*
-desktop-backgrounds-basic
-PackageKit*                # we switched to dnfdragora, so we don't need this
-foomatic-db-ppds
-foomatic
-stix-fonts
-ibus-typing-booster
-xscreensaver*

# plymouth
plymouth-theme-spinfinity

#-wqy-zenhei-fonts           # FIXME: Workaround to save space, do this in comps

# drop some system-config things
#-system-config-language
-system-config-network
-system-config-rootpassword
#-system-config-services
-policycoreutils-gui
-gnome-disk-utility

%end
