#!/bin/sh
#
# Copiar estrutura para o mock de Instalacao
#

# variables
INSTALL_ROOT="/var/lib/mock/fedora-28-i386/root/"

# Criar estrutura do VRPdv
echo "# Criando estrutura de pastas"
mkdir $INSTALL_ROOT/pdv_vr
mkdir $INSTALL_ROOT/SAT
mkdir $INSTALL_ROOT/pdv
mkdir -p $INSTALL_ROOT/vr
mkdir -p $INSTALL_ROOT/pdv_instalacao

# Copiando arquivos necessarios para a instalacao
echo "# Copinado itens da instalação"
cp -r vrpdv_instalacao/pdv/* $INSTALL_ROOT/pdv/
cp -r vrpdv_instalacao/lib $INSTALL_ROOT/pdv_instalacao/
cp -r vrpdv_instalacao/epson $INSTALL_ROOT/pdv_instalacao/
cp -r vrpdv_instalacao/sitef $INSTALL_ROOT/pdv_instalacao/
cp -r vrpdv_instalacao/driver $INSTALL_ROOT/pdv_instalacao/
cp vrpdv_instalacao/anydesk-4.0.0-1.fc24.i686.rpm $INSTALL_ROOT/pdv_instalacao/
cp vrpdv_instalacao/FirebirdCS-2.5.8.27089-0.i686.rpm $INSTALL_ROOT/pdv_instalacao/
cp -r vrpdv_instalacao/iniciar $INSTALL_ROOT/pdv_instalacao/
cp -r vrpdv_instalacao/home_user $INSTALL_ROOT/pdv_instalacao/
cp vrpdv_instalacao/VRPdv.desktop $INSTALL_ROOT/pdv_instalacao/
cp vrpdv_instalacao/pdvinstall $INSTALL_ROOT/

echo "# Preparando itens do sistema"
# Copiando as definicoes de desktop para o /etc/skel
cp -r vrpdv_instalacao/home_user/.config $INSTALL_ROOT/etc/skel/
cp vrpdv_instalacao/home_user/.xscreensaver $INSTALL_ROOT/etc/skel/

# Configurando o sddm
cp vrpdv_instalacao/iniciar/sddm.conf $INSTALL_ROOT/etc/sddm.conf

# Copiando Background
cp vrpdv_instalacao/img/background.png $INSTALL_ROOT/usr/share/backgrounds/

# Instalando fonts Microsoft
cp -r vrpdv_instalacao/msttcore $INSTALL_ROOT/usr/share/fonts/
