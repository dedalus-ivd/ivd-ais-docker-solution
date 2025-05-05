# Single node setup

0. Create folders for deployment

```bash
mkdir -p /opt/dedalus/docker/
```
```bash
mkdir -p /opt/dedalus/upload/
```

1. Create the dedalus docker group

```bash
sudo groupadd -g 1500 dedalus_docker
```

```bash
sudo groupadd -g 1501 dedalus
```

2. Create the dedalus docker user with a password
```bash
sudo useradd dedalus_docker -u 1500 -g dedalus_docker
```

The password will be asked by the promt
```bash
sudo passwd dedalus_docker
```

3. Assign the dedalus docker user to the docker group
```bash
sudo usermod -a -G docker dedalus_docker  
```

4. Create the workspace folder under the /opt/dedalus/docker
It can be dev, test, prod

```bash
sudo chown -R dedalus_docker:dedalus_docker /opt/dedalus/docker
```

5. Assign the dedalus docker user to the group(s) of the node users

```bash
sudo usermod -a -G dedalus dedalus_docker 
```

5. Assign every user to the group dedalus to allow him to upload the conf

```bash
sudo usermod -a -G dedalus <user> 
```
