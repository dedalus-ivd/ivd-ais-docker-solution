sudo mkdir -p /opt/dedalus/docker/
sudo mkdir -p /opt/dedalus/upload/
sudo groupadd -g 1500 dedalus_docker
sudo groupadd -g 1501 dedalus
sudo useradd dedalus_docker -p $(openssl passwd -1 'Dedalus1234') -u 1500 -g dedalus_docker
sudo usermod -a -G docker dedalus_docker  
sudo chown -R dedalus_docker:dedalus_docker /opt/dedalus/docker
sudo chown -R :dedalus /opt/dedalus/upload
sudo chmod 770 /opt/dedalus/upload/
sudo chmod g+s /opt/dedalus/upload
sudo usermod -a -G dedalus dedalus_docker 
sudo dnf -y install bash-completion
cat <<EOT >> ~dedalus_docker/.bashrc

if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

EOT
cat <<EOT >> ~dedalus_docker/.bashrc

cd /opt/dedalus/docker

EOT