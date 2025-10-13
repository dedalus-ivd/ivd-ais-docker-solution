#! /bin/bash

#Download the AWS CLI installer
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#Install unzip if not already installed
sudo yum install -y unzip
#Unzip the installer
unzip awscliv2.zip
#Run the installation script
sudo ./aws/install
#Verify the installation
aws --version