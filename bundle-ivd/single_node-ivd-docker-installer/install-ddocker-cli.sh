#!/bin/bash
sudo cp ./ddocker /usr/bin/
sudo cp ./ddocker_compl /etc/bash_completion.d/
sudo chown -R :dedalus_docker /usr/bin/ddocker
sudo chmod 770 /usr/bin/ddocker