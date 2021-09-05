#!/bin/bash 

echo -e "Adding the Spotify Repositories to /etc/sources.list"
#Add pubkey & repository
echo  "--------------------------------------------------------------------------"
curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key add - 
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sleep 4

echo -e "Done"
Sleep 6
echo "----------------------------------------------------------------------------"
echo -e "Installing Spotify... Please wait"
#Install
sudo apt-get update && sudo apt-get install spotify-client

echo -e  "Spotify has been installed, I hope LOL"
sleep 5
echo "----------------------------------------------------------------------------"
echo -e "NordVPN Install Script Initializing..."

sh <(wget -qO - https://downloads.nordcdn.com/apps/linux/install.sh)

echo -e "Install Script COMPLETED"
sleep 2
echo -e "Modifiying Stock Configuration for better security"
# change settings 
 nordvpn set autoconnect enable
 nordvpn set CyberSec Enable
 nordvpn set technology NordLynx
 nordvpn set notify enable

echo -e "Great, now all that's left for you to do, is login! :) "
echo -e "Installing some more not necessary at all programs"

sudo apt install fortune lolcat cowsay 

echo alias fun='fortune | cowsay | lolcat' >> ~/.bash

# Additionally, if you receive the following issue: Whoops! Permission denied accessing /run/nordvpn/nordvpnd.sock, 
# all you need to do is write the following command: sudo usermod -aG nordvpn $USER and then reboot your device.

sleep 5
echo "---------------------------------------------------------------------"
#Lof into NordVPN 
nordvpn login

