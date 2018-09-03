# fedora-live-base.ks
#
# Defines the basics for all kickstarts in the fedora-live branch
# Does not include package selection (other then mandatory)
# Does not include localization packages or configuration
#
# Does includes "default" language configuration (kickstarts including
# this template can override these settings)

# System language
lang pt_BR.UTF-8

# Keyboard layouts
keyboard 'br-abnt2'

# System timezone
timezone America/Sao_Paulo

# Password file auth
auth --useshadow --passalgo=sha512

# SELinux configuration
selinux --disabled

# Firewall configuration
firewall --disabled

xconfig --startxonboot
zerombr
clearpart --all

# Partitions
part / --size 5120 --fstype ext4

# Services
services --enabled=NetworkManager,ModemManager,sshd

# Network information
network --bootproto=dhcp --device=link --activate

# Root password, default pdv
# rootpw --lock --iscrypted locked
rootpw --iscrypted $1$8RwFXZdD$6yjl8psLBQR0AosTi.iXW/

shutdown

# Repos
repo --name=fedora --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch
#repo --name=updates-testing --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-testing-f$releasever&arch=$basearch
url --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch

%packages
@base-x
@standard
@core
@fonts
@input-methods
@hardware-support

# Explicitly specified here:
# <notting> walters: because otherwise dependency loops cause yum issues.
kernel
kernel-modules
kernel-modules-extra

# This was added a while ago, I think it falls into the category of
# "Diagnosis/recovery tool useful from a Live OS image".  Leaving this untouched
# for now.
memtest86+

# The point of a live image is to install
anaconda
@anaconda-tools

# Need aajohan-comfortaa-fonts for the SVG rnotes images
aajohan-comfortaa-fonts

# Without this, initramfs generation during live image creation fails: #1242586
dracut-live
syslinux

# anaconda needs the locales available to run for different locales
glibc-all-langpacks

# Pacotes necessarios
curl
cabextract
xorg-x11-font-utils
fontconfig
pangox-compat
ncurses-compat-libs
mesa-libGLU
gtkglext-libs
ntsysv
java-1.8.0-openjdk
gedit
sddm-themes
%end

%post
# FIXME: it'd be better to get this installed from a package
cat > /etc/rc.d/init.d/livesys << EOF
#!/bin/bash
#
# live: Init script for live image
#
# chkconfig: 345 00 99
# description: Init script for live image.
### BEGIN INIT INFO
# X-Start-Before: display-manager chronyd
### END INIT INFO

. /etc/init.d/functions

if ! strstr "\`cat /proc/cmdline\`" rd.live.image || [ "\$1" != "start" ]; then
    exit 0
fi

if [ -e /.liveimg-configured ] ; then
    configdone=1
fi

exists() {
    which \$1 >/dev/null 2>&1 || return
    \$*
}

livedir="LiveOS"
for arg in \`cat /proc/cmdline\` ; do
  if [ "\${arg##rd.live.dir=}" != "\${arg}" ]; then
    livedir=\${arg##rd.live.dir=}
    return
  fi
  if [ "\${arg##live_dir=}" != "\${arg}" ]; then
    livedir=\${arg##live_dir=}
    return
  fi
done

# enable swaps unless requested otherwise
swaps=\`blkid -t TYPE=swap -o device\`
if ! strstr "\`cat /proc/cmdline\`" noswap && [ -n "\$swaps" ] ; then
  for s in \$swaps ; do
    action "Enabling swap partition \$s" swapon \$s
  done
fi
if ! strstr "\`cat /proc/cmdline\`" noswap && [ -f /run/initramfs/live/\${livedir}/swap.img ] ; then
  action "Enabling swap file" swapon /run/initramfs/live/\${livedir}/swap.img
fi

mountPersistentHome() {
  # support label/uuid
  if [ "\${homedev##LABEL=}" != "\${homedev}" -o "\${homedev##UUID=}" != "\${homedev}" ]; then
    homedev=\`/sbin/blkid -o device -t "\$homedev"\`
  fi

  # if we're given a file rather than a blockdev, loopback it
  if [ "\${homedev##mtd}" != "\${homedev}" ]; then
    # mtd devs don't have a block device but get magic-mounted with -t jffs2
    mountopts="-t jffs2"
  elif [ ! -b "\$homedev" ]; then
    loopdev=\`losetup -f\`
    if [ "\${homedev##/run/initramfs/live}" != "\${homedev}" ]; then
      action "Remounting live store r/w" mount -o remount,rw /run/initramfs/live
    fi
    losetup \$loopdev \$homedev
    homedev=\$loopdev
  fi

  # if it's encrypted, we need to unlock it
  if [ "\$(/sbin/blkid -s TYPE -o value \$homedev 2>/dev/null)" = "crypto_LUKS" ]; then
    echo
    echo "Setting up encrypted /home device"
    plymouth ask-for-password --command="cryptsetup luksOpen \$homedev EncHome"
    homedev=/dev/mapper/EncHome
  fi

  # and finally do the mount
  mount \$mountopts \$homedev /home
  # if we have /home under what's passed for persistent home, then
  # we should make that the real /home.  useful for mtd device on olpc
  if [ -d /home/home ]; then mount --bind /home/home /home ; fi
  [ -x /sbin/restorecon ] && /sbin/restorecon /home
  if [ -d /home/liveuser ]; then USERADDARGS="-M" ; fi
}

findPersistentHome() {
  for arg in \`cat /proc/cmdline\` ; do
    if [ "\${arg##persistenthome=}" != "\${arg}" ]; then
      homedev=\${arg##persistenthome=}
      return
    fi
  done
}

if strstr "\`cat /proc/cmdline\`" persistenthome= ; then
  findPersistentHome
elif [ -e /run/initramfs/live/\${livedir}/home.img ]; then
  homedev=/run/initramfs/live/\${livedir}/home.img
fi

# if we have a persistent /home, then we want to go ahead and mount it
if ! strstr "\`cat /proc/cmdline\`" nopersistenthome && [ -n "\$homedev" ] ; then
  action "Mounting persistent /home" mountPersistentHome
fi

if [ -n "\$configdone" ]; then
  exit 0
fi

# add liveuser user with no passwd
action "Adding live user" useradd \$USERADDARGS -c "Live System User" liveuser
passwd -d liveuser > /dev/null
usermod -aG wheel liveuser > /dev/null

# Remove root password lock
passwd -d root > /dev/null

# turn off firstboot for livecd boots
systemctl --no-reload disable firstboot-text.service 2> /dev/null || :
systemctl --no-reload disable firstboot-graphical.service 2> /dev/null || :
systemctl stop firstboot-text.service 2> /dev/null || :
systemctl stop firstboot-graphical.service 2> /dev/null || :

# don't use prelink on a running live image
sed -i 's/PRELINKING=yes/PRELINKING=no/' /etc/sysconfig/prelink &>/dev/null || :

# turn off mdmonitor by default
systemctl --no-reload disable mdmonitor.service 2> /dev/null || :
systemctl --no-reload disable mdmonitor-takeover.service 2> /dev/null || :
systemctl stop mdmonitor.service 2> /dev/null || :
systemctl stop mdmonitor-takeover.service 2> /dev/null || :

# don't enable the gnome-settings-daemon packagekit plugin
gsettings set org.gnome.software download-updates 'false' || :

# don't start cron/at as they tend to spawn things which are
# disk intensive that are painful on a live image
systemctl --no-reload disable crond.service 2> /dev/null || :
systemctl --no-reload disable atd.service 2> /dev/null || :
systemctl stop crond.service 2> /dev/null || :
systemctl stop atd.service 2> /dev/null || :

# Don't sync the system clock when running live (RHBZ #1018162)
sed -i 's/rtcsync//' /etc/chrony.conf

# Mark things as configured
touch /.liveimg-configured

# add static hostname to work around xauth bug
# https://bugzilla.redhat.com/show_bug.cgi?id=679486
# the hostname must be something else than 'localhost'
# https://bugzilla.redhat.com/show_bug.cgi?id=1370222
echo "localhost-live" > /etc/hostname

EOF

# bah, hal starts way too late
cat > /etc/rc.d/init.d/livesys-late << EOF
#!/bin/bash
#
# live: Late init script for live image
#
# chkconfig: 345 99 01
# description: Late init script for live image.

. /etc/init.d/functions

if ! strstr "\`cat /proc/cmdline\`" rd.live.image || [ "\$1" != "start" ] || [ -e /.liveimg-late-configured ] ; then
    exit 0
fi

exists() {
    which \$1 >/dev/null 2>&1 || return
    \$*
}

touch /.liveimg-late-configured

# read some variables out of /proc/cmdline
for o in \`cat /proc/cmdline\` ; do
    case \$o in
    ks=*)
        ks="--kickstart=\${o#ks=}"
        ;;
    xdriver=*)
        xdriver="\${o#xdriver=}"
        ;;
    esac
done

# if liveinst or textinst is given, start anaconda
if strstr "\`cat /proc/cmdline\`" liveinst ; then
   plymouth --quit
   /usr/sbin/liveinst \$ks
fi
if strstr "\`cat /proc/cmdline\`" textinst ; then
   plymouth --quit
   /usr/sbin/liveinst --text \$ks
fi

# configure X, allowing user to override xdriver
if [ -n "\$xdriver" ]; then
   cat > /etc/X11/xorg.conf.d/00-xdriver.conf <<FOE
Section "Device"
	Identifier	"Videocard0"
	Driver	"\$xdriver"
EndSection
FOE
fi

EOF

chmod 755 /etc/rc.d/init.d/livesys
/sbin/restorecon /etc/rc.d/init.d/livesys
/sbin/chkconfig --add livesys

chmod 755 /etc/rc.d/init.d/livesys-late
/sbin/restorecon /etc/rc.d/init.d/livesys-late
/sbin/chkconfig --add livesys-late

# enable tmpfs for /tmp
systemctl enable tmp.mount

# make it so that we don't do writing to the overlay for things which
# are just tmpdirs/caches
# note https://bugzilla.redhat.com/show_bug.cgi?id=1135475
cat >> /etc/fstab << EOF
vartmp   /var/tmp    tmpfs   defaults   0  0
EOF

# work around for poor key import UI in PackageKit
rm -f /var/lib/rpm/__db*
releasever=$(rpm -q --qf '%{version}\n' --whatprovides system-release)
basearch=$(uname -i)
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch
echo "Packages within this LiveCD"
rpm -qa
# Note that running rpm recreates the rpm db files which aren't needed or wanted
rm -f /var/lib/rpm/__db*

# go ahead and pre-make the man -k cache (#455968)
/usr/bin/mandb

# make sure there aren't core files lying around
rm -f /core*

# remove random seed, the newly installed instance should make it's own
rm -f /var/lib/systemd/random-seed

# convince readahead not to collect
# FIXME: for systemd

echo 'File created by kickstart. See systemd-update-done.service(8).' \
    | tee /etc/.updated >/var/.updated

# Drop the rescue kernel and initramfs, we don't need them on the live media itself.
# See bug 1317709
rm -f /boot/*-rescue*

# Disable network service here, as doing it in the services line
# fails due to RHBZ #1369794
/sbin/chkconfig network off

# Remove machine-id on pre generated images
rm -f /etc/machine-id
touch /etc/machine-id

# Instalacao de pacotes locais
rpm -ivh /pdv_instalacao/anydesk-4.0.0-1.fc24.i686.rpm
rpm -ivh /pdv_instalacao/FirebirdCS-2.5.8.27089-0.i686.rpm

# Configuracao do Firebird
cp /pdv_instalacao/iniciar/firebird /etc/init.d/
chmod 755 /etc/init.d/firebird
cp /pdv_instalacao/iniciar/firebird.conf /opt/firebird/
chkconfig --add /etc/init.d/firebird

# Subindo libs
cp -r /pdv_instalacao/lib/* /usr/lib/

# Copinando as rules do udev
cp -r /pdv_instalacao/iniciar/vr.rules /etc/udev/rules.d/
cp /pdv_instalacao/iniciar/40-veridis-biometric.rules /etc/udev/rules.d/

# Copiando os arquivos pra forcar a resolucao
cp /pdv_instalacao/forceresolution.desktop /etc/xdg/autostart/
cp /pdv_instalacao/forceresolution.sh /pdv/

%end

%post --nochroot

# only works on x86, x86_64
if [ "$(uname -i)" = "i386" -o "$(uname -i)" = "x86_64" ]; then
  if [ ! -d $LIVE_ROOT/LiveOS ]; then mkdir -p $LIVE_ROOT/LiveOS ; fi
  cp /usr/bin/livecd-iso-to-disk $LIVE_ROOT/LiveOS
fi

# Criar estrutura do VRPdv
mkdir $INSTALL_ROOT/pdv_vr
mkdir $INSTALL_ROOT/SAT
mkdir $INSTALL_ROOT/pdv
mkdir -p $INSTALL_ROOT/vr
mkdir -p $INSTALL_ROOT/pdv_instalacao

# Copiando arquivos necessarios para a instalacao
cp -r ~/Dados/fedora-vrsoftware/vrpdv_instalacao/pdv/* $INSTALL_ROOT/pdv/
cp -r ~/Dados/fedora-vrsoftware/vrpdv_instalacao/lib $INSTALL_ROOT/pdv_instalacao/
cp -r ~/Dados/fedora-vrsoftware/vrpdv_instalacao/epson $INSTALL_ROOT/pdv_instalacao/
cp ~/Dados/fedora-vrsoftware/vrpdv_instalacao/sitef $INSTALL_ROOT/pdv_instalacao/
cp ~/Dados/fedora-vrsoftware/vrpdv_instalacao/driver $INSTALL_ROOT/pdv_instalacao/
cp ~/Dados/fedora-vrsoftware/vrpdv_instalacao/anydesk-4.0.0-1.fc24.i686.rpm $INSTALL_ROOT/pdv_instalacao/
cp ~/Dados/fedora-vrsoftware/vrpdv_instalacao/FirebirdCS-2.5.8.27089-0.i686.rpm $INSTALL_ROOT/pdv_instalacao/
cp -r ~/Dados/fedora-vrsoftware/vrpdv_instalacao/iniciar $INSTALL_ROOT/pdv_instalacao/
cp -r ~/Dados/fedora-vrsoftware/vrpdv_instalacao/home_user $INSTALL_ROOT/pdv_instalacao/
cp ~/Dados/fedora-vrsoftware/vrpdv_instalacao/VRPdv.desktop $INSTALL_ROOT/pdv_instalacao/
cp ~/Dados/fedora-vrsoftware/vrpdv_instalacao/pdvinstall $INSTALL_ROOT/

# Configurando um resolv.conf
cp ~/Dados/fedora-vrsoftware/vrpdv_instalacao/resolv.conf $INSTALL_ROOT/etc/resolv.conf

# Copiando as definicoes de desktop para o /etc/skel
cp -r ~/Dados/fedora-vrsoftware/vrpdv_instalacao/home_user/.* $INSTALL_ROOT/etc/skel/

# Copiando Background
cp ~/Dados/fedora-vrsoftware/vrpdv_instalacaoimg/background.png $INSTALL_ROOT/usr/share/backgrounds/

# Instalando fonts Microsoft
cp -r ~/Dados/fedora-vrsoftware/vrpdv_instalacao/msttcore $INSTALL_ROOT/usr/share/fonts/

# Configurando o sddm
cp -r ~/Dados/fedora-vrsoftware/vrpdv_instalacao/iniciar/sddm.conf $INSTALL_ROOT/etc/sddm.conf

%end
