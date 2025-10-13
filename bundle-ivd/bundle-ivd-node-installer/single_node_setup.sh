echo "creating /opt/dedalus/docker/"
sudo mkdir -p /opt/dedalus/docker/

echo "creating /opt/dedalus/upload/"
sudo mkdir -p /opt/dedalus/upload/

echo "creating /opt/dedalus/docker/bundles"
sudo mkdir -p /opt/dedalus/docker/bundles

echo "creating /opt/dedalus/upload/backups"
sudo mkdir -p /opt/dedalus/upload/backups

echo "creating the dedalus_docker group with ID 1500"
sudo groupadd -g 1500 dedalus_docker

echo "creating the dedalus group with ID 1501"
sudo groupadd -g 1501 dedalus

echo "creating the dedalus_docker user with ID 1500 and default password Dedalus1234"
sudo useradd dedalus_docker -p $(openssl passwd -1 'Dedalus1234') -u 1500 -g dedalus_docker -m -s /bin/bash 

echo "Adding dedalus_docker user to group docker"
sudo usermod -a -G docker dedalus_docker  

echo "Changing owner to dedalus_docker for the /opt/dedalus/docker folder "
sudo chown -R dedalus_docker:dedalus_docker /opt/dedalus/docker

echo "Changing owner to dedalus group for the /opt/dedalus/upload folder "
sudo chown -R :dedalus /opt/dedalus/upload

echo "Adding rights to upload folder for group and owner"
sudo chmod 770 /opt/dedalus/upload

echo "Adding rights to docker folder for group and owner"
sudo chmod 770 /opt/dedalus/docker

echo "Sets that every new file on the upload folder with belong to the dedalus group"
sudo chmod g+s /opt/dedalus/upload

echo "Sets that every new file on the docker folder with belong to the dedalus_docker group"
sudo chmod g+s /opt/dedalus/docker

echo "adding the dedalus_docker user to the dedalus group o read from the upload folder"
sudo usermod -a -G dedalus dedalus_docker 
