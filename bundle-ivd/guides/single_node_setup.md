# Single node setup

## Description
This scripts will creates the structure for running the docker services

- A docker service user that will run the services called "dedalus_docker" that should not be able to log in from outside
- A worspace directory for docker compose files under called "/opt/dedalus/docker/bundles"
- A directory to host the backups "/opt/dedalus/backups"
- a group named "dedalus_docker" to access the dedalus docker resources
- a group named "dedalus" to access resources shared


## Prerequisites
- Docker engine and docker compose installed
- A user that can be sudoer

It's possible simply to launch the script /guides/single_node_setup.sh or simply copy the commands in the console and apply.
After it you need to do only the step 12

0. Create folders for deployment

This folder will hold everything docker related, data
```bash
sudo mkdir -p /opt/dedalus/docker
```
This folder will only act like a bridge to upload the configuration and then copy it into the docker folder
```bash
sudo mkdir -p /opt/dedalus/upload/
```

1. Create the dedalus docker group
This group will manage all the data related to the docker configuration
```bash
sudo groupadd -g 1500 dedalus_docker
```
This group is to let "dedalus" users exchange data: so a user can upload data and the dedalus_docker user will copy it and vice versa
```bash
sudo groupadd -g 1501 dedalus
```

2. Create the dedalus docker user
```bash
sudo useradd dedalus_docker -u 1500 -g dedalus_docker
```

Assign the password to the user
```bash
sudo passwd dedalus_docker
```
The password will be asked by the promt

3. Assign the dedalus docker user to the docker group
```bash
sudo usermod -a -G docker dedalus_docker  
```

4. Create the workspace folder and backups

```bash
sudo mkdir -p /opt/dedalus/docker/bundles
```
This folder will contains the backup
```bash
sudo mkdir -p /opt/dedalus/docker/backups
```

5. Assign the docker folder to the dedalus_docker user and group
```bash
sudo chown -R dedalus_docker:dedalus_docker /opt/dedalus/docker
```
6. Assign the upload and backups folder to the dedalus group and dedalus_docker

```bash
sudo chown -R :dedalus /opt/dedalus/upload
```

ensure that every new file or dir in this directory has the same group

```bash
sudo chmod g+s /opt/dedalus/upload
```
```bash
sudo chmod g+s /opt/dedalus/docker
```
7. Modify the upload and backups folder so that the group's users can ready and write into it

```bash
 sudo chmod 770 /opt/dedalus/upload/
```

8. Assign the dedalus_docker user to dedalus group and to the backups group

```bash
sudo usermod -a -G dedalus dedalus_docker 
```

9. Install bash-completion
```bash
sudo dnf -y install bash-completion
```
10. Enable the docker completion to docker user
```bash
su dedalus_docker
```
Introduce the password

```bash
cat <<EOT >> ~/.bashrc
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
EOT
```

```bash
source ~/.bashrc
```

11. Bonus: make the default folder switch on dedalus_docker login
```bash
cat <<EOT >> ~/.bashrc
cd /opt/dedalus/docker/bundles
EOT
```

12. Assign every user to the group dedalus to allow him to upload the conf: this should be done for every user that will upload the configuration

```bash
sudo usermod -a -G dedalus <user> 
```