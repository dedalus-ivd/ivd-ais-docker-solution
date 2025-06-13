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

example:<br>
/opt/dedalus/docker/prod/ds-compose.yml<br>
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


## HA proxy deployment

Before deploy the proxy you will need to decide what certificate are you going to use to secure the communications.

### Existing certificate.
If you already have the certificate, please rename the certificate as "haproxy_cert.pem" and the key as "haproxy.pem.key" and place them into the "haproxy/conf" folder before uploading the configuration

### Self signed certificate
There is already a cnf file to produce a self signed certificate in the folder /haproxy/conf
The file is called cert.cnf
You need to put the name of the node by decomment the line "DNS.1" or directly the IP address by decomment the line with IP.1
The certificate can be produced directly on the node.

### Configuration statistics
- It is possibile to change the statitic port , user and psw -> env/haproxy.env
- to change the statistics deployment, you need to change the conf/haproxy.cfg
- Default URL is http://your.solution.env:27101/stats

- go to the haproxy/conf folder
```bash
cd  /opt/dedalus/docker/<workspace>/haproxy/conf
```

- produce the certificate
```bash
openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout  haproxy_cert.pem.key -out haproxy_cert.pem -config cert.cnf
```

- go back to the workspace folder
```bash
cd  /opt/dedalus/docker/<workspace>
```
- create the service
```bash
docker compose -f haproxy-compose.yml --env-file env/shared.env --env-file env/routes.env  --env-file haproxy/env/haproxy.env create
```

- run the service
```bash
docker compose -f haproxy-compose.yml --env-file env/shared.env --env-file env/routes.env  --env-file haproxy/env/haproxy.env start
```

## Monitoring deployment


1. Log into the node
2. Switch to the dedalus_docker user
3. Go to the workspace folder
4. Run 

```bash
docker compose -f monitoring-compose.yml --env-file env/shared.env --env-file env/routes.env  --env-file monitoring/env/monitoring.env create
```

```bash
docker compose -f monitoring-compose.yml --env-file env/shared.env --env-file env/routes.env  --env-file monitoring/env/monitoring.env start
```

### Monitoring configurationg
By default the monitoring interface is under the port 27100

1. Log into the page https://your.soulution.env:27100
2. Sign in with the creation username and password (admin / admin)
3. The interface will ask to change the password
4. Follow the guide [here](https://confluence.dedalus.com/display/IAT/Enterprise+Log+Monitoring+Solution+with+Loki%2C+Promtail%2C+and+Grafana+on+Docker+Swarm) at Step 3: configure Grafana.

## Mongo deployment

### Configurationg mongo
- To change the default mongo port -> env/mongo.env
- To change the default admin user and psw -> env/mongo.env (defaults are admin/admin)

### MongoDB SSL Setup (optional)
- uncomment the "tls lines" in the "mongo-compose.yml" file
- in the "tlsMode" line, pick up "requireTLS" or "preferTLS" mode 
- place the certificate "ca.pem" inside the folder mongo/conf
- place the "key.pem" file with both the certificate and the key inside the folder mongo/conf
- to use the self signed certificate refer to the section below

1. Download the mongo configuration and put under the workspace folder
2. Upload the configuration into the node user home
3. Log into the node and become the docker user
4. Copy the configuration into the workspace folder

### using the haproxy self signed certificate
In this example we assume that we are in a test/deployment environment where we use self-signed certificates
So we assume to use the one from haproxy
- From the workspace folder
- copy the certificate
```bash
cp haproxy/conf/haproxy_cert.pem mongo/conf/ca.pem
```
- copy the key and the certificate together
```bash
cat haproxy/conf/haproxy_cert.pem.key haproxy/conf/haproxy_cert.pem > mongo/conf/key.pem
```

### Installing the mongo service

```bash
cd /opt/dedalus/docker/dev/
```

```bash
 docker compose -f mongo-compose.yml --env-file env/shared.env --env-file env/proxy-map.env --env-file env/routes.env --env-file mongo/env/mongo.env create
```

```bash
 docker compose -f mongo-compose.yml --env-file env/shared.env --env-file env/routes.env --env-file mongo/env/mongo.env start
```


# Single application deployment

To show the steps to follow for every single product deployment we will use the Discovery Service as example.
For each product you need to check its own docker deployment manual

## DS deployment

- Look at the global instruction from DS, so we llok into the confluence page of the DS, [here](https://confluence.dedalus.com/pages/viewpage.action?spaceKey=XVAL&title=xdiscovery-service+-+5.1.x#xdiscoveryservice5.1.x-DeployDiscoveryServiceonDockerusingDockerCompose)
- in this case we are asked to download the zip file from [here](http://ci-assetrepo.noemalife.loc/artifactory/releases/eu/dedalus/x1v1/xdiscovery-service/5.1.3/xdiscovery-service-5.1.3.zip)
- since the deployment does not follow the standards we need to arrange it.

### Making the folder
- create a new folder DS inside the deployment folder with the subfolders conf and env
- from the release, copy the xdiscovery-service-5.1.3\x1v1\conf\xdiscovery-service into the conf folder
- from the relase, copy the xdiscovery-service-5.1.3\x1v1\docker\.env file into the env folder and rename it ds.env

### Check the proxy configuration

- Every service should be proxied by the HAProxy set up in the node.
- The configuration of the proxy should handle every AIS service.
- Check the file haproxy/conf/haproxy.conf to be sure you service is correctly handled [here](https://confluence.dedalus.com/display/IAT/IVD+Services+-+deployment+info) in the table where you see the column HAproxy configuration ready. Otherwise check the documentation of the product


### Setting the deployment info
- into the ds.env file set the deployment info, in this case we assume xdiscovery as user, psw and db name
- the MONGODB_CONN_STRING with the url of the mongo , in our case mongo:27017
- the MONGODB_CONN_OPT: in this case true&tlsAllowInvalidHostnames=true&tlsAllowInvalidCertificates=true
- application.properties according to the ds settings
- in the application properties set the "iana.tld.additional" property to handle the name of the base solution image
ex: the solution is at https://your.solution.dedalus set iana.tld.additional=dedalus
- configuration.json with the identity provider

### Mongo Backup and Restore - Manual

Use the following commands to perform backups and restores on a standalone MongoDB instance running inside a Docker container. These examples assume authentication is enabled and the backup is stored in /tmp.

- Replace CONTAINER_NAME_OR_ID, HOSTNAME, USERNAME, PASSWORD, and the date as needed.
- Use the --drop option during restore if you want to overwrite existing collections.

#### Backup from the host environment
```bash
docker exec CONTAINER_NAME_OR_ID mongodump --host HOSTNAME --port 27017 -u USERNAME -p PASSWORD --authenticationDatabase admin --out /tmp/mongodump-$(date +%Y%m%d_%H%M%S)
```

#### Backup from inside the container environment
```bash
mongodump --host HOSTNAME --port 27017 -u USERNAME -p PASSWORD --authenticationDatabase admin --out /tmp/mongodump-$(date +%Y%m%d_%H%M%S)
```

#### Restore from the host environment
```bash
docker exec CONTAINER_NAME_OR_ID mongorestore --host HOSTNAME --port 27017 -u USERNAME -p PASSWORD --authenticationDatabase admin /tmp/mongodump-TIMESTAMP
```

#### Restore from inside the container environment
```bash
mongorestore --host HOSTNAME --port 27017 -u USERNAME -p PASSWORD --authenticationDatabase admin /tmp/mongodump-TIMESTAMP
```

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

- Self signed TLS
```bash
docker exec -it test-mongo-1 mongosh -u admin -p admin --tls  --tlsAllowInvalidHostnames --tlsAllowInvalidCertificates
```

### commands to create the collection for the Disovery Service
In here we are using this data:
dbname = xdiscovery
user = xdiscovery
psw = xdiscovery

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
exit
```

### create the service

Before creating a new service, to pull an image it necessary to [log in](#aws-login)

```bash
 docker compose -f ds-compose.yml --env-file env/shared.env --env-file env/routes.env create
```
```bash
 docker compose -f ds-compose.yml --env-file env/shared.env --env-file env/routes.env start
```
