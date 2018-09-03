#platform=x86, AMD64, or Intel EM64T
#version=DEVEL
# Keyboard layouts
keyboard 'br-abnt2'
# Root password
rootpw --iscrypted $1$YdtWyShE$tZhz.DdyCFlBBXESgugNS.
# System language
lang pt_BR
# Reboot after installation
reboot
# System timezone
timezone America/New_York
# Use graphical install
graphical
# System authorization information
auth  --useshadow  --passalgo=sha512
# Firewall configuration
firewall --disabled
# Use CDROM installation media
cdrom
firstboot --disable
# SELinux configuration
selinux --disabled

# System bootloader configuration
bootloader --location=mbr
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --all
# Disk partitioning information
part /boot --asprimary --fstype="ext4" --size=1024
part swap --fstype="swap" --recommended
part / --fstype="ext4" --grow --size=8192

# Repos
repo --name=fedora --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch
#repo --name=updates-testing --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-testing-f$releasever&arch=$basearch
url --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch

%packages
@base-x
@core
@fonts
@lxqt-apps
@lxqt-desktop
@standard
@system-tools
@networkmanager-submodules
@hardware-support
@printing
-@input-methods
-scim*
-m17n*
-ibus*
-iok
-BackupPC
-mpage
-sox
-hplip
-numactl
-isdn4k-utils
-autofs
-coolkey
-xsane
-xsane-gimp
-sane-backends
storaged
gnome-keyring
lxqt-l10n
lximage-qt-l10n
obconf-qt-l10n
pavucontrol-qt-l10n
gstreamer1-plugin-mpg123
wqy-microhei-fonts          # a compact CJK font, to replace:
-naver-nanum-gothic-fonts       # Korean
-vlgothic-fonts             # Japanese
-adobe-source-han-sans-cn-fonts     # simplified Chinese
-adobe-source-han-sans-tw-fonts     # traditional Chinese
-paratype-pt-sans-fonts # Cyrillic (already supported by DejaVu), huge

%end

%post --nochroot

# adicionar arquivos pdv
mkdir $INSTALL_ROOT/pdv_vr
mkdir $INSTALL_ROOT/SAT
mkdir $INSTALL_ROOT/pdv
mkdir -p $INSTALL_ROOT/pdv_instalacao/lib
mkdir -p $INSTALL_ROOT/pdv_instalacao/epson
mkdir -p $INSTALL_ROOT/pdv_instalacao/sitef
mkdir -p $INSTALL_ROOT/pdv_instalacao/tools
mkdir -p $INSTALL_ROOT/pdv_instalacao/iniciar
mkdir -p $INSTALL_ROOT/pdv_instalacao/links

cp -r /home/kleber/Dados/fedora-vrsoftware/vrpdv_instalacao/pdv/* $INSTALL_ROOT/pdv/
cp -r /home/kleber/Dados/fedora-vrsoftware/vrpdv_instalacao/lib/* $INSTALL_ROOT/pdv_instalacao/lib/
cp -r /home/kleber/Dados/fedora-vrsoftware/vrpdv_instalacao/epson/* $INSTALL_ROOT/pdv_instalacao/epson/
cp /home/kleber/Dados/fedora-vrsoftware/vrpdv_instalacao/sitef/CliSiTef.ini $INSTALL_ROOT/pdv_instalacao/sitef/
cp /home/kleber/Dados/fedora-vrsoftware/vrpdv_instalacao/jre-7u65-linux-i586.rpm $INSTALL_ROOT/pdv_instalacao/tools/
cp /home/kleber/Dados/fedora-vrsoftware/vrpdv_instalacao/anydesk-4.0.0-1.fc24.i686.rpm $INSTALL_ROOT/pdv_instalacao/tools/
cp /home/kleber/Dados/fedora-vrsoftware/vrpdv_instalacao/FirebirdCS-2.5.8.27089-0.i686.rpm $INSTALL_ROOT/pdv_instalacao/tools/
cp -r /home/kleber/Dados/fedora-vrsoftware/vrpdv_instalacao/iniciar/* $INSTALL_ROOT/pdv_instalacao/iniciar/
cp /home/kleber/Dados/fedora-vrsoftware/vrpdv_instalacao/VRPdv.desktop $INSTALL_ROOT/pdv_instalacao/links/VRPdv.desktop

%end
