#!/bin/sh

# Install docker-engine from mit source

sudo apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

sudo cat <<EOF >> /etc/apt/sources.list.d/docker.list
# Ubuntu Wily
deb https://apt.dockerproject.org/repo ubuntu-wily main
EOF

sudo apt-get update
sudo apt-get purge lxc-docker*
sudo apt-cache policy docker-engine

sudo apt-get update
sudo apt-get install docker-engine
sudo systemctl enable docker

sudo usermod -aG docker kevinfu

sudo cp /etc/default/grub /etc/default/grub.orig
sudo sed -i -e 's/^GRUB_CMDLINE_LINUX=.*$/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/' /etc/default/grub
sudo update-grub

sudo cp /etc/default/ufw  /etc/default/ufw.orig
sudo sed -i -e 's/^DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
sudo ufw reload
sudo ufw allow 2375/tcp

sudo cp /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf.orig
sudo sed -i -e 's/^dns=dnsmasq.*$/#dns=dnsmasq/' /etc/NetworkManager/NetworkManager.conf
systemctl restart network-manager

sudo cp /etc/default/docker /etc/default/docker.orig
sudo sed -i -e 's/^#DOCKER_OPTS.*$/DOCKER_OPTS="--dns 8.8.8.8 --dns 10.137.0.253"/' /etc/default/docker
sudo systemctl restart docker

# Install docker-machine

sudo curl -L https://github.com/docker/machine/releases/download/v0.5.0/docker-machine_linux-amd64.zip >machine.zip && \
sudo unzip machine.zip && \
sudo rm machine.zip && \
sudo mv docker-machine* /usr/local/bin

# Install docker-compose

VERSION_NUM=1.5.0
sudo curl -L https://github.com/docker/compose/releases/download/${VERSION_NUM}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod u+x /usr/local/bin/docker-compose
