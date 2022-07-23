#!/bin/bash
# Ensure service is ready to run
sleep 2 
sudo yum update -y
# Install Docker and git
sudo yum install -y git
sudo amazon-linux-extras install docker -y
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
# Download Lab files (git is preinstalled on machine)
git clone https://github.com/YonyElm/app-simple-stack.git
# Turn on docker
sudo service docker start
# Build and run container
cd app-simple-stack
sudo /usr/local/bin/docker-compose build
sudo /usr/local/bin/docker-compose up