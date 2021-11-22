#!/bin/bash

#Variables
INSTALL_LOG="$TMP/install.log"
ERROR_LOG="$TMP/error.log"
DIR=$(cd `dirname $0` && pwd)
Server_IP=""
Server_Country="Unknow"
Server_OS=""
Server_OS_Version=""
Total_RAM=$(free -m | awk '/Mem:/ { print $2 }')


# Functions
## echo colored text 

Check_Root() {
echo -e "\nChecking root privileges..."
if [[ $(id -u) != 0 ]] >/dev/null; then
    echo -e "\nYou need to execute the script with sudo or within the root account.\n"
    echo -e "It is recommended to run with sudo instaed of the root account."
    echo -e "\e[31msudo ./NewInstall.sh\e[39m"
    exit 1
  else
    echo -e "\nCorrect privilages detected, prooceding with installation.\n"
  fi
}


Check_Server_IP() {
Server_IP=$(curl --silent --max-time 30 -4 https://cyberpanel.sh/?ip)
  if [[ $Server_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "Valid IP detected...Sending it to the FBI"
    echo -e "Just kidding"
  else
    echo -e "Can not detect IP, exit... You using VPN?"
    Debug_Log "Can not detect IP. [404]"
    exit
  fi
}
 

e()
{
	local color="\033[${2:-34}m"
	local log="${3:-$INSTALL_LOG}"
	echo -e "$color$1\033[0m"
}


#error echo

ee()
{
	local exit_code="${2:-1}"
	local color="${3:-31}"

	has_dep "dialog"
	[ $? -eq 0 ] && clear
	e "$1" "$color" "$ERROR_LOG"
	exit $exit_code
}

cleanup()
{
	has_dep "dialog"
	[ $? -eq 0 ] && clear
	e "Making sure no trail is left behind c:"
	cd $TMP 2> /dev/null || return 1
	find * -not -name '*.log' | xargs rm -rf
}


# CTRL_C trap
ctrl_c()
{
	echo
	cleanup
	e "Installation aborted by user! Stop pressing Cntrl + C " 31
}

ROOT_verify(){
## Checking root access
if [ $EUID -ne 0 ]; then
	ee "This script has to be ran as root!"
	ee "Run this shit as root using sudo su -"
fi
}

CURL_check(){
## Check for wget or curl or fetch
e "Checking for HTTP client..."
if [ `which curl 2> /dev/null` ]; then
	download="$(which curl) -s -O"
elif [ `which wget 2> /dev/null` ]; then
	download="$(which wget) --no-certificate"
elif [ `which fetch 2> /dev/null` ]; then
	download="$(which fetch)"
else
	dep "wget"
	download="$(which wget) --no-certificate"
	e "No HTTP client found, wget added to dependencies" 31
fi
}

package_manager(){
## Check for package manager (apt or yum)
e "Checking for package manager..."
if [ `which apt-get 2> /dev/null` ]; then
	install[0]="apt"
	install[1]="$(which apt-get) -y --force-yes install"
elif [ `which yum 2> /dev/null` ]; then
	install[0]="yum"
	install[1]="$(which yum) -y install"
else
	ee "No package manager found."
fi

## Check for package manager (dpkg or rpm)
if [ `which dpkg 2> /dev/null` ]; then
	install[2]="dpkg"
	install[3]="$(which dpkg)"
elif [ `which rpm 2> /dev/null` ]; then
	install[2]="rpm"
	install[3]="$(which rpm)"
else
	ee "No package manager found."
fi

## Check for init system (update-rc.d or chkconfig)
e "Checking for init system..."
if [ `which update-rc.d 2> /dev/null` ]; then
	init="$(which update-rc.d)"
elif [ `which chkconfig 2> /dev/null` ]; then
	init="$(which chkconfig) --add"
else
	ee "Init system not found, service not started!"
fi
}

Debug_Log() {
echo -e "\n${1}=${2}\n" >> /tmp/install_debug.log
}


e "Another fresh install you fucking Distro Hoper?"
e "First let's update the packages"
e "Welcome Mother Fucker, we need to set up a user that ISN'T root, kindly enter the username you wish to setup with sudo privilages"
read -p 'Type your username:' usernew
echo  ""
adduser $usernew
e "ight $usernew , lets move on"
usermod -aG sudo $usernew
sleep 2
e 'Updating packages'

sudo apt update && sudo apt upgrade -y

e -------------------------------------------------------------------------
e "Done"
read -p 'Do you wish to install CLI Tools? (Yes or No).  :' clitools
echo  ""
if [[ $clitools == "yes"]]; then 
    sudo apt install terminator lynis debsecan python3-pip iptraf-ng htop whois net-tools iwconfig glances adb fastboot testdisk android-sdk locate ncdu libpam-tmpdir libpam-usb -y 
else 
    echo ' Ok well thats gay'
fi 

e "Lets move on now."
e -------------------------------------------------------------------------
sleep 4
e "You like gotta have this on yo system brother"
e -------------------------------------------------------------

sudo apt install lolcat fortune cowsay fail2ban gnome-disk-utility plank git selinux-utils  terminator rkhunter libpam-google-authenticator  libpam-tmpdir libpam-passwdqc libpam-ssh libpam-python libpam-mount libpam-mklocaluser libpam-systemd ncdu testdisk debsecan apt-listchanges aptitude iptraf-ng macchanger parted gparted zsh python3-pip cmatrix telegram-desktop telegram-cli sendmail bind9 apache2 apache2-utils  needrestart debsums  -y


#adding repository key for lynis 
wget -O - https://packages.cisofy.com/keys/cisofy-software-public.key | sudo apt-key add -
echo "deb https://packages.cisofy.com/community/lynis/deb/ stable main" | sudo tee /etc/apt/sources.list.d/cisofy-lynis.list
sudo apt update && apt install apt-transport-https lynis -y

read -p 'Shall we run Lynis to check your score? Yes or No:  ' audit
echo ""
sleep 2
if [[ $audit == "yes" ]]; then
    sudo lynis audit system
else 
    echo 'Ok, well you sure are feeling lucky then' && sleep 3
fi


#Clean any old packages from the system 
sudo apt autoremove -y && apt autopurge -y

#Stupid shit I like installing
sudo apt install plank gnome-disk-utility gparted minder telegram-desktop yakuake sl -y

cowsay "Now lets change some default settings" | lolcat 
sleep 3
e "Changing default nameservers..." 

#adding nordpvn dns and cloudfare
sudo echo "#Cloudare and NordVPN DNS
nameserver 103.86.96.100
nameserver 103.86.99.100
nameserver 1.1.1.1
# this is probably needed for Linode, adding it just to be safe
domain members.linode.com
search members.linode.com
nameserver 66.228.53.5
nameserver 96.126.122.5
nameserver 96.126.124.5
nameserver 96.126.127.5
nameserver 198.58.107.5
nameserver 198.58.111.5
nameserver 23.239.24.5
nameserver 173.255.199.5
nameserver 72.14.179.5
nameserver 72.14.188.5" > /etc/resolv.conf

echo -e "Snap Applications"
e "Would you like to install Snap?"
read -p "Plese enter [Yes/No] and press enter:     " snap-apps
if [[ $snap-apps == "yes" ]]; then
	sudo apt install snap snapd 
	sudo snap install norpass termius-app
fi
e "---------------------------------------------------------"
sudo chmod +x jail_user.sh && sudo chmod +x csf.sh
e "Installing CSF and Adding new User with chroot configuration"

sleep 4
./csf.sh
./jail_user.sh
cowsay "Done with that" | lolcat 

sleep 4

sudo ufw enable
sudo systemctl enable ufw

read -p "What would you like to be the name of this server? \n Type your hostname:  " hostname
echo ""

e "ok, just to confirm your hostname will be: %F{red}$hostname%f"

read -p "Is that correct? Please type yes or no:  [yes/no]   " dumbass
echo ""

if [[ $dumbass == "yes" ]]; then
    sudo hostnamectl set-hostname $hostname
else
    read -p "Type your hostname correctly this time:" dumbass2
	echo ""
else
    sudo hostnamectl set-hostname $dumbass2
fi



sudo echo "
#%PAM-1.0
auth		required	pam_securetty.so
auth		required	pam_unix.so nullok
auth		required	pam_nologin.so
account		required	pam_unix.so
password	required	pam_cracklib.so retry=3
password	required	pam_unix.so shadow nullok use_authtok
session		required	pam_unix.so" >> /etc/pam.d/login

mv .sshd_config sshd_config && mv sshd_config /etc/ssh/sshd_config
mv .jail.conf jail.conf && mv jail.conf /etc/fail2ban/jail.conf
mv .bashrc /home/$usernew/.bashrc

sudo service ssh restart && sudo service fail2ban restart


read --p "wanna install the git preloaded config? uh you fancyyyy" fancy
echo ""

if [[ $fancy == "yes" ]]; then 
	git config --global user.name "gscconnect"
	git config --global user.email "admin@gscloudnetwork.com"
else
    e "fuck you then"	
fi

read --p "what about gs cyberpanel? type 'yeahboy' for yes and 'GS What?' for n" gscp
echo ""

if [[ $gscp == "yeahboy" ]]; the
	git clone https://github.com/GSCConnect/GS-Cyberpanel.git && cd GS-Cyberpanel
	chmod +x install.sh && ./install.sh 
else 
 e "git clone your mom"
 fi

read -p "Would you like to install tripwire?" tripninja
echo ""

if [[ $tripninja == "Yes" ]]; then
    sudo apt install tripwire 
else 
    cowthink "Is this nigga crazy?" | lolcat
fi 



e "Installation Complete"

sleep 2

cowsay "YOUR INSTALLATION IS DONE" | lolcat

