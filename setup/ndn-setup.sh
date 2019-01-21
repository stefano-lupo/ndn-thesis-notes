#! /bin/bash

desktop="192.168.1.10"
laptop="192.168.1.11"
prefix="/com/stefanolupo"

machine_name=$1
service_name="ndn-ping-server.service"

if [ "$machine_name" == "" ]
then
  echo "No machine name  given, exiting.."
  exit
fi


## Install NFD
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:named-data/ppa -y
sudo apt update
sudo apt install nfd -y
sudo service nfd status

## Grab the CXX Library, prereqs and NDN Tools
sudo apt install ndn-tools -y

echo "Successfully installed software, setting up route to desktop.."

## Configure default nodes

## Create UDP tunnel to desktop
ndfc face create udp://$desktop
ndfc route add $prefix udp://$desktop
ndnping $prefix -c 5

# Create a ping server daemon
echo "Setting up auto start daemon for ping server"
sudo sed -e "s/machine_name/$machine_name/g" ndn-ping-server.service > /etc/systemd/system/$service_name
sudo systemctl daemon-reload
sudo systemctl start $service_name
sudo systemctl enable $service_name