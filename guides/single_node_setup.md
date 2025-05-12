# Single node setup

Prerequisites
- Docker engine and docker compose installed
- A user that can be sudoer

0. Create folders for deployment

This folder will hold everything docker related, data
```bash
sudo mkdir -p /opt/dedalus/docker/
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

4. Create the workspace folder under the /opt/dedalus/docker
It can be dev, test, prod

```bash
sudo mkdir -p /opt/dedalus/docker/test
```

5. Assign the docker folder to the dedalus_docker user and group
```bash
sudo chown -R dedalus_docker:dedalus_docker /opt/dedalus/docker
```
6. Assign the upload folder to the dedalus group

```bash
sudo chown -R :dedalus /opt/dedalus/upload
```
7. Modify the upload folder so that the group's users can ready and write into it

```bash
 sudo chmod 770 /opt/dedalus/upload/
```
5. Assign the dedalus_docker user to dedalus group

```bash
sudo usermod -a -G dedalus dedalus_docker 
```

5. Assign every user to the group dedalus to allow him to upload the conf: this should be done for every user that will upload the configuration

```bash
sudo usermod -a -G dedalus <user> 
```
