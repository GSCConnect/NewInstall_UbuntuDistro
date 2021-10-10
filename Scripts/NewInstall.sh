#!/bin/bash

### Functions

## echo colored text 
e()
{
	local color="\033[${2:-34}m"
	local log="${3:-$INSTALL_LOG}"
	echo -e "$color$1\033[0m"
}

## Cleanup
cleanup()
{
	has_dep "dialog"
	[ $? -eq 0 ] && clear
	e "Making sure no trail is left behind c:"
	cd $TMP 2> /dev/null || return 1
	find * -not -name '*.log' | xargs rm -rf
}

## CTRL_C trap
ctrl_c()
{
	echo
	cleanup
	e "Ups sorry boy, you kinda fucked at this point! Can't quit this shit " 31
}
trap ctrl_c INT

## Funtion attempt 
cwp()
{
	fortune | cowsay | lolcat 
	sl
}

e "Another fresh install you fucking Distro Hoper?"
sleep 2
e "First let's update the packages"
e "Welcome Mother Fucker, we need to set up a user that ISN'T root, kindly enter the username you wish to setup with sudo privilages"
read -p "Would you like to set up a new user?  [Yes/No] " Nuser
echo ""

if [[ $Nuser == "yes" ]]; then 
	read -p "Type your username:  " usernew
	echo ""
	useradd -d -m $usernew 
else
	echo "Alright then, fuck you."
fi

e "ight $usernew , lets move on"
sleep 2
e "Updating packages for $usernew"

sudo apt update && sudo apt upgrade -y

e -------------------------------------------------------------------------
e "Done"
read -p "Do you wish to install CLI Tools? [Yes/No]   :  " clitools
echo ""

if [[ $clitools == "yes" ]]; then 
    sudo apt install terminator lynis debsecan python3-pip iptraf-ng htop whois net-tools glances adb fastboot aptitude testdisk android-sdk locate ncdu libpam-tmpdir -y 
else 
    echo 'Then why you running the script?'
fi 

e "Lets move on now."
e -------------------------------------------------------------------------
sleep 4
e "You like gotta have this on yo system brother"
e -------------------------------------------------------------
if [[ $clitools == "yes" ]]; then
	sudo aptitude install lolcat fortune cowsay fail2ban gnome-disk-utility plank git selinux-basics setools terminator rkhunter libpam-google-authenticator libpam-tmpdir libpam-passwdqc libpam-ssh libpam-python libpam-mount libpam-cracklib libpam-mklocaluser libpam-systemd ncdu testdisk debsecan apt-listchanges needrestart debsums debian-goodies  -y
  else 
	cwp
fi

read -p "$usernew Would you like to install the lastest Lynis software?" LynisInstall
echo ""
if [[ $LynisInstall == "yes" ]]; then
	#adding repository key for lynis 
	wget -O - https://packages.cisofy.com/keys/cisofy-software-public.key | sudo apt-key add -
	echo "deb https://packages.cisofy.com/community/lynis/deb/ stable main" | sudo tee /etc/apt/sources.list.d/cisofy-lynis.list
	sudo apt update && apt install apt-transport-https lynis -y
   else
	#Clean any old packages from the system 
	sudo apt autoremove -y && apt autopurge -y
fi

read -p "$RTuser would you like to install the GUI tools?" GUItools
echo ""
if [[ $GUItools == "yes" ]]; then 
	#Stupid shit I like installing
	sudo aptitude install plank gnome-disk-utility gparted minder telegram-desktop yakuake sl cmatrix -y
  else 
	e "Okay then" 
fi

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

#echo -e "Snap Applications"
#sudo snap install norpass termius-app
read -p "Shall we run Lynis to check your score? [Yes/No]:  ' audit
echo ""
sleep 2

if [[ $audit == "yes" ]]; then
    sudo lynis audit system
else 
    echo 'Ok, well you sure are feeling lucky then' && sleep 3
fi
read -p "$usernew please type your GitHub/GitLab username" gituser 
echo ""
read -p "Type the email for $gituser" gitemail
echo""
e "Thank you"
read -p "Now please type your password" gitpassword
echo ""

read -p "Would you like to set this as global configurations for git?  [yes/no]" gitconfig
echo ""
if [[ $gitconfig == "yes" ]]; then
	git config --global user.name "$gituser"
	git config --global user.password "$gitpassword"
	git config --global user.email "$gitemail"
  else 
	e "I like turtles"
fi

if [[ $gitconfig == "yes" ]]; then 
	cd
	git clone https://gitlab.com/snippets/2180426.git
	cd 2180426
	e "---------------------------------------------------------"
	chmod +x jail_user.sh && chmod +x csf.sh
	e "Installing CSF and Adding new User with chroot configuration"
	sleep 4	
	e "Runnng CSF Install Script"
	./csf.sh
	e "done, will now configure the jail"
	./jail_user.sh
	cowsay "Done with that" | lolcat 
	sleep 4
 else 
	e " So hows the weather?"
fi

sudo ufw enable
sudo systemctl enable ufw
read -p "Wanna configure the hostname bro? [yes/no]" hostconfig
echo ""
if [[ $hostconfig == "yes" ]]; then
	read -p "What would you like to be the name of this server?   " hostname
	echo ""
	e "ok, just to confirm your hostname will be: $hostname"
	sudo hostnamectl set-hostname $hostname
else
	echo "well thats a shame $usernew , it is now your hostname"
fi

e "Modifying PAM configurations"

echo "
#%PAM-1.0
auth		required	pam_securetty.so
auth		required	pam_unix.so nullok
auth		required	pam_nologin.so
account		required	pam_unix.so
password	required	pam_cracklib.so retry=3
password	required	pam_unix.so shadow nullok use_authtok
session		required	pam_unix.so" | tee -a /etc/pam.d/login

mv .sshd_config sshd_config && mv sshd_config /etc/ssh/sshd_config
mv .jail.conf jail.conf && mv jail.conf /etc/fail2ban/jail.conf
mv .bashrc /home/$usernew/.bashrc

service ssh restart && service fail2ban restart

read -p "Wanna install GSCyberpanel?" GSCyberpanel
echo ""

if [[ $GSCyberpanel == "yes" ]]; then 
	cd 
	git clone https://github.com/GSCConnect/GS-Cyberpanel.git && cd GS-Cyberpanel
	chmod +x install.sh && ./install.sh
else
	e "ok"
fi


read -p "Would you like to install tripwire?" $tripninja
echo ""

if [ $tripninja == "Yes" ]; then
    sudo apt install tripwire
else 
    cowthink "Is this nigga crazy?" | lolcat
fi 



e "Installation Complete"

sleep 2

cowsay "YOUR INSTALLATION IS DONE" | lolcat
