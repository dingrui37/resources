#!/bin/bash
set -x
#ifName=$1
#ipAddr=$2
#userName=$3

#config network
#sudo echo "auto $ifName" >> /etc/network/interfaces
#sudo echo "iface $ifName inet static" >> /etc/network/interfaces
#sudo echo "address $ipAddr" >> /etc/network/interfaces
#sudo echo "gateway 10.42.94.1" >> /etc/network/interfaces
#sudo echo "netmask 255.255.255.0" >> /etc/network/interfaces
#sudo echo "dns-nameservers 10.30.1.9" >> /etc/network/interfaces

#ifconfig $ifName down
#ifconfig $ifName up

sudo echo "Acquire::http::Proxy::mirrors.zte.com.cn DIRECT;" >> /etc/apt/apt.conf
sudo sed -i "s/^/#/" /etc/apt/sources.list
sudo cat <<EOF >> /etc/apt/sources.list
deb http://mirrors.zte.com.cn/ubuntu/ xenial main multiverse restricted universe
deb http://mirrors.zte.com.cn/ubuntu/ xenial-backports main multiverse restricted universe
deb http://mirrors.zte.com.cn/ubuntu/ xenial-proposed main multiverse restricted universe
deb http://mirrors.zte.com.cn/ubuntu/ xenial-security main multiverse restricted universe
deb http://mirrors.zte.com.cn/ubuntu/ xenial-updates main multiverse restricted universe
deb-src http://mirrors.zte.com.cn/ubuntu/ xenial main multiverse restricted universe
deb-src http://mirrors.zte.com.cn/ubuntu/ xenial-backports main multiverse restricted universe
deb-src http://mirrors.zte.com.cn/ubuntu/ xenial-proposed main multiverse restricted universe
deb-src http://mirrors.zte.com.cn/ubuntu/ xenial-security main multiverse restricted universe
deb-src http://mirrors.zte.com.cn/ubuntu/ xenial-updates main multiverse restricted universe
EOF

yes | sudo apt update
apt | sudo apt upgrade

yes | sudo apt install openssh-server
sudo /etc/init.d/ssh start

yes | sudo apt install maven
#yes | sudo apt install wireshark-qt
yes | sudo apt install mininet
yes | sudo apt install git
yes | sudo apt install vim
yes | sudo apt install firefox
yes | sudo apt install xrdp
yes | sudo apt install vnc4server
yes | sudo apt install xubuntu-desktop
echo "xfce4-session" >~/.xsession
sudo service xrdp restart

echo "export http_proxy='proxynj.zte.com.cn:80'" >> ~/.bashrc
echo "export https_proxy=$http_proxy" >> ~/.bashrc
echo "export no_proxy='zte.com.cn,127.0.0.1,mirrors.zte.com.cn,localhost,$userName'" >> ~/.bashrc
sudo reboot
