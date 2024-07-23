#!/usr/bin/bash

DOCKER_USERNAME=${1:-docker}

apt update
apt upgrade -y

export DEBIAN_FRONTEND=noninteractive
apt install -y ruby ruby-dev wget tzdata locales g++ autotools-dev make cmake sudo git

export LANGUAGE=de_DE.UTF-8
export LANG=de_DE.UTF-8
export LC_ALL=de_DE.UTF-8
export SHELL /bin/bash
locale-gen de_DE.UTF-8

echo "Europe/Berlin" > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata
dpkg-reconfigure locales

useradd -ms /bin/bash $DOCKER_USERNAME

echo "$DOCKER_USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

