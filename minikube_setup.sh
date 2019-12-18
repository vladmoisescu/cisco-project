#!/bin/bash
#
# This script purpose is to make it easier to install minikube
# 
# Please take into consideration that you will need to introduce
# two passwords, the first one is the root password and the second
# one is the luxoft account pasword.
#
# Another requirement is to have cpfw-login_amd64.bin file in the
# same directory with this script
#

# Install curl
sudo apt-get install curl

# Uninstall docker first
sudo apt-get remove docker docker-engine docker.io containerd runc

# Install packaes to allow apt to use a repository over HTTPS
sudo apt install apt-transport-https ca-certificates curl software-properties-common

# Install Docker
sudo apt-get install docker-ce docker-ce-cli containerd.io
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Download minikube
sudo curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Give execute rightes
sudo chmod +x minikube

# Add minikube to path
sudo mkdir -p /usr/local/bin/
sudo install minikube /usr/local/bin/

# Add to path
sudo install cpfw-login_amd64.bin /usr/local/bin/
cpfw-login_amd64.bin --user vmoisescu

# Create directories and their parent directories if necessary
sudo mkdir -p /usr/local/share/ca-certificates/luxoft
sudo mkdir -p ~/.minikube/files/etc/ssl/certs

# Generate certificate
echo -n | openssl s_client -showcerts -connect dl.k8s.io:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > kube.chain.pem

# Extract the last certificate
csplit -f htf kube.chain.pem '/-----BEGIN CERTIFICATE-----/' '{*}' | sudo cat $(ls htf* | sort | tail -1) > luxoft_root_ca.crt && rm -rf htf*

# Copy certifiates
sudo cp luxoft_root_ca.crt /usr/local/share/ca-certificates/luxoft/luxoft_root_ca.crt
sudo cp luxoft_root_ca.crt ~/.minikube/files/etc/ssl/certs/luxoft_root_ca.crt

# Update certificates
sudo update-ca-certificates

# Install Kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

# Give Kubectl execute rights
chmod +x ./kubectl

# Move kubectl binary to path
sudo mv ./kubectl /usr/local/bin/kubectl



