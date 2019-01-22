#! /bin/bash

desktop="192.168.1.10"
laptop="192.168.1.11"
prefix="/com/stefanolupo"

machine_name=$1
user_name=$2
service_name="ndn-ping-server.service"

if [ "$machine_name" == "" ]
then
  echo "No machine name  given, exiting.."
  exit
fi
if [ "$user_name" == "" ]
then
  echo "No user name given, exiting.."
  exit
fi

## Install NFD
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:named-data/ppa -y
sudo apt update
sudo apt install nfd -y
sudo apt install ndn-tools -y
sudo service nfd status

echo "Successfully installed software, setting up route to desktop.."

## Configure default nodes

## Create UDP tunnel to desktop
nfdc face create udp://$desktop
nfdc route add $prefix/desktop udp://$desktop

## Create UDP tunnel to ndn box
nfdc face create udp://ndn.stefanolupo.com
nfdc route add $prefix/ndnbox udp://ndn.stefanolupo.com

## Try ping the NDN box
ndnping $prefix/ndnbox -c 5

# Create a ping server daemon
echo "Setting up auto start daemon for ping server"
sudo sed -e "s/machine_name/$machine_name/g" ndn-ping-server.service | sed -e "s/user_name/$user_name/g" > /etc/systemd/system/$service_name
sudo systemctl daemon-reload
sudo systemctl start $service_name
sudo systemctl enable $service_name
