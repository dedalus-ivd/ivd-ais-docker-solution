# IVD Development for docker guide

This document has the purpose of guiding the development of our solution targeting the containerization of the solution/product/service itself

## Install development environment on developer pc

### Windows
If you are developing under windows you need to enable the WSL2 subsystem.
Usually it suggest Ubuntu, follow these instructions

[Install WSL2 under windows](https://learn.microsoft.com/en-us/windows/wsl/install)

### Linux
You are already in the right place :)


## Install docker
In order to test docker on your on machine you need...to have the docker engine which is able to run docker containers

### Windows WSL

[Docker Engine Setup into the WSL2](https://confluence.dedalus.com/display/DRA/HOWTO+-+Docker+Engine+Setup+into+the+WSL2#expand-cleaningtheenvironment)

### Linux

[Install docker engine](https://docs.docker.com/engine/install/)

To not use the root user you should enable you user to run docker

```bash
sudo usermod -aG docker $USER
```

reload it so not to have to log out

```bash
newgrp docker
```

## Install AWS Cli v2
AWS Cli command line is needed to access to our docker images since we host them on AWS

Under linux just follow the istructions in this link

[Install AWS Cli v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
