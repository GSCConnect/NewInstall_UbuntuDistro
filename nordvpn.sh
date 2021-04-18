#! /bin/bashs

 sh <(wget -qO - https://downloads.nordcdn.com/apps/linux/install.sh)

# change settings 
 nordvpn set autoconnect enable
 nordvpn set CyberSec Enable
 nordvpn set technology NordLynx
 nordvpn set notify enable



# Additionally, if you receive the following issue: Whoops! Permission denied accessing /run/nordvpn/nordvpnd.sock, 
# all you need to do is write the following command: sudo usermod -aG nordvpn $USER and then reboot your device.



#Lof into NordVPN 
nordvpn login
