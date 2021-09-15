#!/bin/bash
echo -e "Another fresh install you fucking Distro Hoper?"
echo -e "First let's update the packages"
sudo apt update -y
sudo apt upgrade -y

echo -------------------------------------------------------------------------
echo -e "Done"
echo -e "Installing CLI Tools"
#MUST HAVE CLI RELATED TOOLS
sudo apt install terminator lynis debsecan python3-pip iptraf-ng htop whois net-tools iwconfig glances adb fastboot testdisk android-sdk locate ncdu -y
echo -e "Done"
echo -------------------------------------------------------------------------
echo -e "Installing dumb shit I like"
#I just like pipelining this commands
sudo apt install lolcat fortune cowsay fail2ban tripwire gnome-disk-utility plank lynis git selinux-* terminator clamav-* rkhunter libpam-google-authenticator  libpam-tmpdir libpam-passwdqc libpam-ssh libpam-python libpam-mount libpam-cracklib libpam-mklocaluser libpam-systemd ncdu testdisk --fix-missing -y

#Stupid shit I like installing
sudo apt install plank gnome-disk-utility gparted minder telegram-desktop yakuake sl cmatrix -y

#echo -e "Snap Applications"
#sudo snap install norpass termius-app

echo -e "Installation Complete"

sleep 2

cowsay "YOUR INSTALLATION IS DONE" | lolcat



