#! /bin/bash

#Before installing Docker Engine, uninstalling any conflicting packages.
sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine \
                  podman \
                  runc

#Install the dnf-plugins-core package (which provides the commands to manage your DNF repositories) and set up the repository.	  
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

#installing specific docker version
sudo dnf -y install docker-ce-3:27.3.1-1.el9 docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin



#starting docker engine
sudo systemctl enable --now docker