# Docker single node deployment

## Prerequisites

- A node with [these](https://confluence.dedalus.com/display/IAT/Docker+deployment+-+component+requirements) prerequisites
- A user with the authorization of running docker: we will call it dedalus_docker
- A user to log into the node
- A software to connect to a Linux console (the console itself can be good, under windows you can use [PuTTy client](https://www.putty.org/))
- A software to transfer files: the console con be good or [WinSCP](https://winscp.net/eng/download.php)
- the ssh key that usually is needed to connect to the node (otherwise can be only username and password, depends on the environment)

## AWS Credentials registration and use
Before pulling the Dedalus images from the repositories it's necessary to register the credentials

The credentials can be found [here](https://confluence.dedalus.com/display/IAT/IVD+Services+-+deployment+info)

- Log into the node and switch user to dedalus_docker 
- type 
```bash
aws configure
```
- The interface will ask for
1. AWS Access Key ID = 
2. AWS Secret Access Key =
3. Default region name = eu-west-1
4. Default output format = json

- Check if correctly set by typing
```bash
aws sts get-caller-identity
```

### AWS Login
Before pulling a new image it's necessary to log in 

```bash
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 350801433917.dkr.ecr.eu-west-1.amazonaws.com
```

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

example:
/opt/dedalus/docker/prod/mongo-compose.yml

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

## Workspace folder setup

- Log into the node with your credentials and create the workspace folders
```bash
mkdir /opt/dedalus/upload/<workspace>
```
- switch to dedalus_docker user and create the same workspace into the docker space
```bash
mkdir  /opt/dedalus/docker/<workspace>
```


## Configuration upload

For all the following examples I will assume
- The node user that can connect to the node is: <b>ec2-user</b>
- The docker user that can operate on docker is : <b>dedalus_docker</b>
- The workspace we are using is : <b>dev</b>

1. Prepare your deployment on the workstation you are using: that means that you have to put the files under a folder that has one of the workspace names : dev, prod, test, valid.
It has to look like the folder structure you see [here](https://confluence.dedalus.com/display/IAT/Docker+deployment+-+component+requirements#Dockerdeploymentcomponentrequirements-Deploymentstructure)

2. Download the docker_single_node.zip that will contain the network, mongo, haproxy, monitoring and the env folder. Unzip it into your pc under the workspace folder you prepared for the deployment

3. Download release zip file for each service product you are going to deploy and put it into the workspace folder (r4c, ds, ld....)\

4. Copy the compose files in the "compose" folder of each product into the workspace folder

5. Configure env/shared.env file variables:
- Set the AIS_WORKSPACE using the correct one (file /env/shared.env)
- Set the SOLUTION_BASE_URL using the solution one (file /env.routesd.env): this should be the base url in front of the solution, not the node one (even thought they can be the same) but if, for example, there is a load balancer in front of two nodes, you need to use the address of the load balancer

6. configure each product: in this guide we will cover the mongo, the haproxy and we take the discovery service as example so configure them before uploading the files

7. Upload your folder into the node. It should land in the upload folder /opt/dedalus/upload, in this case:
So you will end up having the configuration under the folder /opt/dedalus/upload/dev (or prod/test/valid)

8. Log into the node using an ssh like tool (like PuTTy or directly using the shell)

9. Switch to the docker user (you will be asked for a password if any)
```bash
su dedalus_docker
```

10. Copy the configuration <br>
<b>dev</b>

```bash
cp -r /opt/dedalus/upload/dev/ /opt/dedalus/docker/
```
<b>prod</b>

```bash
cp -r /opt/dedalus/upload/prod/ /opt/dedalus/docker/
```

11. Go the workspace folder (prod in the example)

```bash
cd  /opt/dedalus/docker/prod
```

## Network creation
As first you need to create a subnetwork
1. Upload the configuration
2. Connect to the node and become the docker user
3. Go to in the workspace folder
```bash
docker compose -f ./network-compose.yml --env-file ./env/shared.env --all-resources create
```
4. Check the correct creation

```bash
docker network ls
```

## Mongo deployment

### Configurationg mongo
- To change the default mongo port -> env/mongo.env
- To change the default admin user and psw -> env/mongo.env (defaults are admin/admin)

### Create and Distribute Mongo Keyfile

Create a folder keyfile under mongo directory and execute the below commands. 

#### Generate a keyfile on one node:

```bash
    openssl rand -base64 756 > mongo-keyfile
    chmod 400 mongo-keyfile
    chown 999:999 mongo-keyfile
```

Copy the `mongo-keyfile` to the same location on **all 3 nodes**.

### Installing the mongo service

```bash
cd /opt/dedalus/docker/dev/
```

```bash
docker compose -f mongo-compose.yml --env-file env/shared.env --env-file mongo/env/mongo.env create
```

```bash
docker compose -f mongo-compose.yml --env-file env/shared.env --env-file mongo/env/mongo.env start
```

### Initiate Replica Set

Enter mongosh on mongo1:
```bash
docker exec -it mongo1 mongosh -u admin -p admin --authenticationDatabase admin
```

Run:
```bash
rs.initiate({
  _id: "rs",
  members: [
    { _id: 0, host: "ip-<node1>:27017" },
    { _id: 1, host: "ip-<node2>:27018" },
    { _id: 2, host: "ip-<node3>:27019" }
  ]
})
```

Confirm with:
```bash
rs.status()
```


# Single application deployment

To show the steps to follow for every single product deployment we will use the Discovery Service as example.
For each product you need to check its own docker deployment manual



### Mongo Backup and Restore - Automated

The below steps describes how to automate MongoDB backups inside a Docker container, with automatic deletion of backups older than 7 days.

#### Step 1: Create the Backup Script
Create a file named mongo_backup.sh with the following content:
```bash
#!/bin/bash

# Rotate backups older than 7 days inside the container
docker exec CONTAINER_NAME_OR_ID find /tmp -maxdepth 1 -type d -name 'mongodump-*' -mtime +7 -exec rm -rf {} \;

# Load environment variables from .env file
source /opt/dedalus/docker/test/mongo/env/mongo.env

# Generate timestamped backup directory name
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/tmp/mongodump-$TIMESTAMP"

# Run mongodump inside the container
docker exec CONTAINER_NAME_OR_ID mongodump --host HOSTNAME --port 27017 -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --out "$BACKUP_DIR"
```

#### Step 2: Make the Script Executable
```bash
chmod +x /opt/dedalus/docker/test/mongo_backup.sh
```

#### Step 3: Schedule the Cron Job
Edit the crontab using:
```bash
crontab -e
```
Add the following line to run the backup every day at 5 PM, and log the output to a file:
```bash
0 17 * * * /opt/dedalus/docker/test/mongo_backup.sh >> /tmp/mongo_backup.log 2>&1
```

### mongo collection creation

- Log into the node
- assume the docker user 
- check if the mongo database is running by typing
```bash
docker container ls
```
It should appear something like this: that's the name of the container
![PuTTy Opening](/guides/assets/mongo_install_show_container.png)

if not, start the container

You can use whatever tool you may like to connect to the mongo instance.
In here we use an approach without an external tool

Then enter the container to use the mongoshell
In this example the user is 'admin' and the psw is 'admin': change them according to the deployment

- No TLS
```bash
docker exec -it test-mongo-1 mongosh -u admin -p admin
```