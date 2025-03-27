#!/bin/bash

##
# this is a series of command for creating a new user, let it 
# own a folder so that, from within the container, the user that
# runs the service can access a folder on the host machine
# suppose the user inside the container has the ID 1001
# suppose the user of the host that is used to manage docker is "ec2-user"
# suppose the service we are installing is called "discovery-service"

# create a docker service group
sudo groupadd -g 1001 docker_service
#create a docker service user
sudo useradd docker_service -u 1001 -g 1001
#assign the docker folder and subfolders both to the docker service user and group
sudo chown -R docker_service:docker_service /opt/dedalus/docker/discovery-service
#make sure the group members have the rights
sudo chmod -R 774 /opt/dedalus/docker/
#eventually put the current user into that group
sudo usermod -a -G docker_service ec2-user