# Single node setup

## Description
This scripts will creates the structure for running the docker services

- A docker service user that will run the services called "dedalus_docker" that should not be able to log in from outside
- A directory for docker compose files under called "/opt/dedalus/docker/bundles"
- A directory where to upload files "/opt/dedalus/upload"
- A directory to host the backups "/opt/dedalus/upload/backups"
- a group named "dedalus_docker" to access the dedalus docker resources
- a group named "dedalus" to access resources shared

Main idea
- The dedalus_docker group will be the only entitled to run docker commands
- The dedalus_docker group will be the acual executor of the docker services
- Every file under the /opt/dedalus/docker folder needs to belong to the dedalus_user to let the services, run as dedalus_docker user, to acess , write those folder and files
- The dedalus group is created to have a bridge from the files uploaded from outside but not directly put into the docker folder
- Every user, to upload files, connects and put them on the upload folder
- Only the dedalus_docker user can copy the files into the docker folder
- To be able to access the system a person needs to have a user that is in the dedalus group to upload the configuration files
- Once connected, it's mandatory to switch to the dedalus_docker user

NB
- the dedalus_docker user and group by default has the 1500 ID, if you need to change it you need to change the scripts or the commands.
- the dedalus group by default has the 1501 ID, if you need to change it you need to change the scripts or the commands


## Prerequisites
- Docker engine and docker compose installed
- A user that can be sudoer

It's possible simply to launch the script single_node_setup.sh or simply copy the commands in the console and apply.
After it you need to do only the steps from the 10th

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

2. Create the dedalus docker user (default passwd Dedalus1234, change it if you want)
```bash
sudo useradd dedalus_docker -p $(openssl passwd -1 'Dedalus1234') -u 1500 -g dedalus_docker -m -s /bin/bash 
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
sudo mkdir -p /opt/dedalus/upload/backups
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
7. Modify the docker,upload ,backups folder so that the group's users can ready and write into it

```bash
 sudo chmod 770 /opt/dedalus/upload
```
```bash
 sudo chmod 770 /opt/dedalus/upload/backup
```
```bash
 sudo chmod 770 /opt/dedalus/docker
```

8. Assign the dedalus_docker user to dedalus group and to the backups group

```bash
sudo usermod -a -G dedalus dedalus_docker 
```

9. Assign every user to the group dedalus to allow him to upload the conf: this should be done for every user that will upload the configuration

```bash
sudo usermod -a -G dedalus <user> 
```

10. Install bash-completion
```bash
sudo dnf -y install bash-completion
```
11. Enable the docker completion to docker user
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

12. Bonus: make the default folder switch on dedalus_docker login
```bash
cat <<EOT >> ~/.bashrc
cd /opt/dedalus/docker/bundles
EOT
```
