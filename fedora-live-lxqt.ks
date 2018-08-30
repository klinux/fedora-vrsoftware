# fedora-live-lxqt.ks
#
# Description:
# – Fedora Live Spin with the LXQt desktop environment
#
# Maintainer(s):
# – Christian Dersch <lupinix@fedoraproject.org>
#

%include fedora-live-base.ks
%include fedora-live-minimization.ks
%include fedora-lxqt-common.ks

%post
# add initscript
cat >> /etc/rc.d/init.d/livesys << EOF

# set up autologin for user liveuser
if [ -f /etc/sddm.conf ]; then
sed -i 's/^#User=.*/User=liveuser/' /etc/sddm.conf
sed -i 's/^#Session=.*/Session=lxqt.desktop/' /etc/sddm.conf
else
cat > /etc/sddm.conf << SDDM_EOF
[Autologin]
User=liveuser
Session=lxqt.desktop
SDDM_EOF
fi

# show liveinst.desktop on desktop and in menu
sed -i 's/NoDisplay=true/NoDisplay=false/' /usr/share/applications/liveinst.desktop
mkdir /home/liveuser/Desktop
cp -a /usr/share/applications/liveinst.desktop /home/liveuser/Desktop/

# set up preferred apps
cat > /etc/xdg/libfm/pref-apps.conf << FOE
[Preferred Applications]
WebBrowser=qupzilla.desktop
FOE

# no updater applet in live environment
rm -f /etc/xdg/autostart/org.mageia.dnfdragora-updater.desktop

# make sure to set the right permissions and selinux contexts
chown -R liveuser:liveuser /home/liveuser/
restorecon -R /home/liveuser/

EOF

%end

%post --nochroot
# adicionar arquivos pdv
cp -r $INSTALL_ROOT/$(pwd)/vrpdv_instalacao/pdv/* $LIVE_ROOT/pdv/
cp -r $INSTALL_ROOT/$(pwd)/vrpdv_instalacao/lib/* $LIVE_ROOT/pdv_instalacao/lib/
cp -r $INSTALL_ROOT/$(pwd)/vrpdv_instalacao/epson/* $LIVE_ROOT/pdv_instalacao/epson/
cp -r $INSTALL_ROOT/$(pwd)/vrpdv_instalacao/sitef/CliSiTef.ini $LIVE_ROOT/pdv_instalacao/sitef/
cp -r $INSTALL_ROOT/$(pwd)/vrpdv_instalacao/jre-7u65-linux-i586.rpm $LIVE_ROOT/pdv_instalacao/tools/
cp -r $INSTALL_ROOT/$(pwd)/vrpdv_instalacao/anydesk-4.0.0-1.fc24.i686.rpm $LIVE_ROOT/pdv_instalacao/tools/
cp -r $INSTALL_ROOT/$(pwd)/vrpdv_instalacao/scripts/* $LIVE_ROOT/pdv_instalacao/scripts/
cp -r $INSTALL_ROOT/$(pwd)/vrpdv_instalacao/firebird/* $LIVE_ROOT/pdv_instalacao/firebird/
cp -r $INSTALL_ROOT/$(pwd)/vrpdv_instalacao/vrpdv.desktop $LIVE_ROOT/pdv_instalacao/links/vrpdv.desktop


%end
