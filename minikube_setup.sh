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

# Install packaes to allow apt to use a repository over HTTPS
sudo apt install apt-transport-https ca-certificates curl software-properties-common

# Install Docker

# check if docker exists
sudo docker --help > /dev/null 2>&1

if [ $? ne 0 ]; then
	echo "installing docker"
	sudo apt-get install docker-ce docker-ce-cli containerd.io
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
fi

if [ -z "${LUXOFT_ENV}" ]; then
	echo "LUXOFT_ENV is undefined"
else
  	echo "LUXOFT_ENV is defined: proceed to Luxoft FW Checkpoint login" 	


	if [ -f "cpfw-login_amd64.bin" ]; then
    		
		# Add to path
		sudo install cpfw-login_amd64.bin /usr/local/bin/
    		cpfw-login_amd64.bin --user $1

    		sudo mkdir -p /usr/local/share/ca-certificates/luxoft
   	
		# Generate certificate
    		echo -n | openssl s_client -showcerts -connect dl.k8s.io:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > kube.chain.pem

    		# Extract the last certificate
    		csplit -f htf kube.chain.pem '/-----BEGIN CERTIFICATE-----/' '{*}' | sudo cat $(ls htf* | sort | tail -1) > luxoft_root_ca.crt && rm -rf htf*

    		# Copy certifiates
    		sudo cp luxoft_root_ca.crt /usr/local/share/ca-certificates/luxoft/luxoft_root_ca.crt

    		# Update certificates
    		sudo update-ca-certificates
	else
		echo "cpfw-login_amd64.bin file dose not exist"
		exit 1
	fi
fi

# check if minikube exists
minikube > /dev/null 2>&1

if [ $? -ne 0 ]; then

    echo "minikube is not installed"

    # Download minikube
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/v1.5.2/minikube-linux-amd64
    
    # Give execute rights to minikube
    chmod +x minikube
    
    # Add minikube to path
    sudo mkdir -p /usr/local/bin/
    sudo install minikube /usr/local/bin/
    rm minikube


    if [ -z "$LUXOFT_ENV" ]; then
        echo "LUXOFT_ENV is undefined"
    else
        echo "LUXOFT_ENV is defined: copy Luxoft root CA into minikube"
        mkdir -p $HOME/.minikube/files/etc/ssl/certs
        sudo cp /usr/local/share/ca-certificates/luxoft/luxoft_root_ca.crt ~/.minikube/files/etc/ssl/certs
    fi
fi

# check if kubectl is installed
kubectl > /dev/null 2> $1

if [ $? -ne 0 ]; then
	
	# Install Kubectl
	curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

	# Give Kubectl execute rights
	chmod +x ./kubectl

	# Move kubectl binary to path
	sudo mv ./kubectl /usr/local/bin/kubectl
fi


