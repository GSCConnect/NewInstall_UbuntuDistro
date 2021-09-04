#!/bin/bash

sudo apt update && apt upgrade -y 
sudo apt install fortune lolcat cowsay 

fortune | cowsay | lolcat
