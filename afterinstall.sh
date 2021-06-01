#! /bin/bash/

sudo apt update -y
sudo apt upgrade -y

#MUST HAVE CLI RELATED TOOLS
sudo apt install terminator lolcat fortune cowsay lynis debsecan snapd python3-pip iptraf-ng htop whois net-tools iwconfig glances adb fastboot testdisk android-sdk locate ncdu -y

#Stupid shit I like installing
sudo apt install plank gnome-disk-utility gparted minder telegram-desktop yakuake sl cmatrix -y

#PC HARDENING
sudo apt install fail2ban -y

sudo snap install norpass termius-app

cowsay "YOUR INSTALLATION IS DONE" | lolcat


# other shit

sudo apt install etcd 

