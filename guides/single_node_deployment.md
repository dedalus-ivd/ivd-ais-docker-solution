# Docker single node deployment

## Prerequisites

- A node with [these](https://confluence.dedalus.com/display/IAT/Docker+deployment+-+component+requirements) prerequisites
- A user with the authorization of running docker
- A user to log into the node
- A software to conect to a Linux console (the console itself can be good, under windows you can use [PuTTy client](https://www.putty.org/))
- A software to transfer files: the consoel con be good or [WinSCP](https://winscp.net/eng/download.php)
- the ssh key that usually is needed to connect to the node (otherwise can be only username and password, depends on the environment)

## Deployment structure

### dedalus folder
The dedalus folder is placed at:
/opt/dedalus/docker/

### workspace

Each deployment has a target workspace.
the workspaces can be
- prod
- dev
- test
- valid

This can be useful to split services based on workspaces that potentially can coexists on the same node

This results in these possibile root folders

- /opt/dedalus/docker/prod/
- /opt/dedalus/docker/dev/
- /opt/dedalus/docker/test/
- /opt/dedalus/docker/valid/

for the purpose of this document I will write the commands for production and test

### main folders
Under the root folder will be placed the compose files.
Each product will release its own and they will be copied here

example:<br>
/opt/dedalus/docker/prod/ds.yml<br>
/opt/dedalus/docker/prod/mongo.yml

<b>env</b> folder
under the "env" folder there will be the common used variables in the files
- /opt/dedalus/docker/prod/shared.env
- /opt/dedalus/docker/prod/routes.env

### services folders
Each service needs to produce a release compose of these folders
- compose: where to keep the release compose file
- env: where to keep the variables file
- config: for the configuration files, it's reserved for the files that the application may need to read
- data: where the application can write
- scripts: utility scripts if any
- secrets: to keep the secrets


## Configuration upload

For all the following examples I will assume
- The node user that can connect to the node is: <b>ec2-user</b>
- The docker user that can operate on docker is : <b>dedalus_docker</b>
- The workspace we are using is : <b>dev</b>

1. Prepare your deployment on the workstation you are using: that means that you have to put the files under a folder that has one of the workspace names : dev, prod, test, valid.
It has to look like the folder structure you see [here](https://confluence.dedalus.com/display/IAT/Docker+deployment+-+component+requirements#Dockerdeploymentcomponentrequirements-Deploymentstructure)

2. Download the configuration for each service7product you are going to deploy and put it into that folder
3. Copy the compose file under each "compose folder" of the products into the workspace root folder
4. Change the variables into the env files folowing the service instruction 

5. Upload your folder into the node. It should land in the node user's home, in this case: /home/ec2-user/
So you will end up having the configuration under the folder /home/ec2-user/dev (or prod/test/valid)

6. Log into the node using an ssh like tool (like PuTTy or directly using the shell)

7. Switch to the docker user (you will be asked for a password if any)
```bash
su dedalus_docker
```

8. Copy the configuration <br>
<b>dev</b>

```bash
cp -r /opt/dedalus/upload/dev/ /opt/dedalus/docker/
```
<b>prod</b>

```bash
cp -r /opt/dedalus/upload/prod/ /opt/dedalus/docker/
```

## Network creation
As first you need to create a subnetwork
1. Upload the configuration
2. Connect to the node and become the docker user
3. Go to in the workspace folder
```bash
docker compose -f ./network.yml --env-file ./env/shared.env --all-resources create
```

## Mongo deployment
1. Download the mongo configuration and put under the workspace folder
2. Upload the configuration into the node user home
3. Log into the node and become the docker user
```bash
cd /opt/dedalus/docker/dev/
```


```bash
 docker compose -f mongo.yml --env-file env/shared.env --env-file env/routes.env --env-file mongo/env/mongo.env create
```



## DS deployment

### mongo collection creation

- Log into the node
- assume the docker user 
- check if the mongo database is running by typing
```bash
docker container ls
```
It should appear somethign like this: that's the name of the container
![PuTTy Opening](/guides/assets/mongo_install_show_container.png)

if not, start the container

Then enter the container to use the mongoshell
In this example the user is 'admin' and the psw is 'admin': change them according to the deployment
```bash
docker exec -it dev-mongo-1 mongosh -u admin -p admin
```
```bash
mv ds/compose/ds.yml ./
```
The Shell will open
```bash
use admin
```
```bash
db = db.getSiblingDB('xdiscovery')
```
```bash
db.createUser(
   {
     user: "xdiscovery", 
     pwd: "xdiscovery",
     roles: [{"role":"readWrite","db":"xdiscovery"},{"role":"dbAdmin","db":"xdiscovery"}], 
   } 
) 
```

```bash
 docker compose -f ds.yml --env-file env/shared.env --env-file env/routes.env create
```

## HA proxy deployment
```bash
openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout  haproxy_cert.pem.key -out haproxy_cert.pem -config cert.cnf
```