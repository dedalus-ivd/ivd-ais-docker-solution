# Docker single node deployment

## Prerequisites

- A node with [these](https://confluence.dedalus.com/display/IAT/Docker+deployment+-+component+requirements) prerequisites
- A user with the authorization of running docker: we will call it dedalus_docker
- A user to log into the node
- A software to connect to a Linux console (the console itself can be good, under windows you can use [PuTTy client](https://www.putty.org/))
- A software to transfer files: the console con be good or [WinSCP](https://winscp.net/eng/download.php)
- the ssh key that usually is needed to connect to the node (otherwise can be only username and password, depends on the environment)

## Switch to dedalus docker user
To run the docker instructions you need to become the "dedalus_docker" user

```bash
su dedalus_docker
```
Then type the password

## AWS Credentials registration and use
Before pulling the Dedalus images from the repositories it's necessary to register the credentials

The credentials can be found [here](https://confluence.dedalus.com/display/IAT/IVD+Services+-+deployment+info)

- Log into the node and [switch to deadlus_docker user](#switch_to_dedalus_docker_user)
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

The workspace where we will put our bundles is

/opt/dedalus/docker/bundles

### main folders
Each service will release its own package that will be, in the and, a directory to put under the directlry "bundles"

example:<br>
/opt/dedalus/docker/prod/ds-compose.yml<br>
/opt/dedalus/docker/prod/mongo-compose.yml

<b>env</b> folder
under the "global-env" folder there will be the common used variables in the files
- /opt/dedalus/docker/bundles/global-env/stage/shared.env
- /opt/dedalus/docker/bundles/global-env/stage/routes.env

### services folders
Each service needs to produce a release compose of these folders
- compose file: a file named "compose-docker.yaml" that contains the definition of the service
- scripts: where there are utily scripts
- environments folder: in here there is everything will be splitted by environment
- by default each service will release the "environments/stage" directory as default
- under every environment directory there will be other dicretories:
- env: where to keep the variables file
- config: for the configuration files, it's reserved for the files that the application may need to read
- data: where the application can write
- secrets: to keep the secrets

Example:<br>
ivdservice_AAA/<br>
├── docker-compose.yaml<br>
├── environments<br>
│   ├── prod<br>
│   └── stage<br>
│       ├── conf<br>
│       │   ├── conf-file-AAA-1.xml<br>
│       │   └── conf-file-AAA-2.xml<br>
│       ├── data<br>
│       ├── env<br>
│       │   └── ivdservice_AAA.env<br>
│       └── secrets<br>
└── scripts<br>


## Workspace folder setup


- [switch to deadlus_docker user](#switch_to_dedalus_docker_user) user and create the same workspace into the docker space
```bash
mkdir  /opt/dedalus/docker/bundles
```


## Configuration upload

For all the following examples I will assume
- The node user that can connect to the node is: <b>ec2-user</b>
- The docker user that can operate on docker is : <b>dedalus_docker</b>
- The environemnt we are using is : <b>stage</b>

1. Prepare your deployment on the workstation you are using: that means that you have to put the files under a folder that is called "bundles"
It has to look like the folder structure you see [here](https://confluence.dedalus.com/display/IAT/Docker+deployment+-+component+requirements#Dockerdeploymentcomponentrequirements-Deploymentstructure)

2. Download the [bundle-ivd](https://github.com/dedalus-ivd/ivd-ais-docker-solution/releases/download/v1.0/bundle-ivd.zip) that will contain the network, mongo, haproxy, monitoring and the env folder. Unzip it into your pc under the workspace folder you prepared for the deployment

3. Download release zip file for each service product you are going to deploy and put it into the workspace folder (r4c, ds, ld....)

4. Configure global-env/environments/stage/shared.env (this goes for "stage" environment) file variables:
- Set the AIS_WORKSPACE using the correct one (file global-env/environments/stage/shared.env)
- Set the SOLUTION_BASE_URL using the solution one (file global-env/environments/stage/routes.env): this should be the base url in front of the solution, not the node one (even thought they can be the same) but if, for example, there is a load balancer in front of two nodes, you need to use the address of the load balancer

5. configure each product: in this guide we will cover the mongo, the haproxy and we take the discovery service as example so configure them before uploading the files

6. Upload your folder into the node. It should land in the upload folder /opt/dedalus/upload, in this case:
So you will end up having the configuration under the folder /opt/dedalus/upload/dev (or prod/test/valid)

9. Log into the node using an ssh like tool (like PuTTy or directly using the shell)

10. Switch to the docker user (you will be asked for a password if any)
```bash
su dedalus_docker
```

11. Copy the configuration <br>

```bash
cp -r /opt/dedalus/upload/bundles /opt/dedalus/docker/
```

11. Go the bundles folder 

```bash
cd  /opt/dedalus/docker/bundles
```

## Network creation
As first you need to create a subnetwork
1. Upload the configuration
2. Connect to the node and become the docker user
3. Go to in the network folder 
```bash
cd /opt/dedalus/docker/bundles/network
```

```bash
bash scripts/network.sh stage create
```
4. Check the correct creation

```bash
docker network ls
```
it should appear a list like
```bash
NETWORK ID     NAME                       DRIVER    SCOPE
5eae029b2e93   GLOBAL_AIS_NETWORK_stage   bridge    local
69f94a45149e   bridge                     bridge    local
8891f5f105b6   host                       host      local
d88f2bb5658e   none                       null      local
```
GLOBAL_AIS_NETWORK_stage is what we have just created



## HA proxy deployment

Before deploy the proxy you will need to decide what certificate are you going to use to secure the communications.

### Existing certificate.
If you already have the certificate, please rename the certificate as "haproxy_cert.pem" and the key as "haproxy.pem.key" and place them into the "haproxy/conf" folder before uploading the configuration

### Configuration statistics
- It is possibile to change the statitic port , user and psw -> env/haproxy.env
- to change the statistics deployment, you need to change the conf/haproxy.cfg
- Default URL is http://your.solution.env:27101/stats
- go back to the haproxy folder
```bash
cd  /opt/dedalus/docker/bundles/haproxy
```
- create the service
```bash
bash scripts/haproxy.sh stage create
```

- check the deployment
go to the page http://your.solution.env:27101/stats and check the stats page with the user and psw you set
```bash
docker container ls
```

You should have an haproxy container running



## Monitoring deployment

1. Log into the node
2. Switch to the dedalus_docker user
3. go to the monitoring folder

```bash
cd  /opt/dedalus/docker/bundles/monitoring
```
- create the service
```bash
bash scripts/monitoring.sh stage create
```

### Monitoring configurationg
By default the monitoring interface is under the port 27100

1. Log into the page https://your.soulution.env:27100
2. Sign in with the creation username and password (admin / admin)
3. The interface will ask to change the password
4. Follow the guide [here](https://confluence.dedalus.com/display/IAT/Enterprise+Log+Monitoring+Solution+with+Loki%2C+Promtail%2C+and+Grafana+on+Docker+Swarm) at Step 3: configure Grafana.

## Mongo deployment

### Configurationg mongo
- To change the default mongo port -> environments/stage/mongo.env
- To change the default admin user and psw -> environments/stage/mongo.env (defaults are admin/admin)


### Installing the mongo service
- go to the mongo folder

```bash
cd  /opt/dedalus/docker/bundles/mongo
```
- create the service
```bash
bash scripts/mongo.sh stage create
```

# Single application deployment

To show the steps to follow for every single product deployment we will use the Discovery Service as example.
For each product you need to check its own docker deployment manual

Basic steps
- Download the service bundle (the zip fila that should respect the bundle structure)
- Place it under the "bundles" folder among the others
- Follow the service docs to deploy and run it

To know if a services has already bundled correctly its solution check the table [here](https://confluence.dedalus.com/display/IAT/IVD+Services+-+deployment+info)

## DS deployment
In the first release of the IVD Bundle we cover the deployment of the Discovery Service 5.1.2

- Look at the global instruction from DS, so we llok into the confluence page of the DS, [here](https://confluence.dedalus.com/pages/viewpage.action?spaceKey=XVAL&title=xdiscovery-service+-+5.1.x#xdiscoveryservice5.1.x-DeployDiscoveryServiceonDockerusingDockerCompose)
- in this case we are asked to download the zip file from [here](http://ci-assetrepo.noemalife.loc/artifactory/releases/eu/dedalus/x1v1/xdiscovery-service/5.1.3/xdiscovery-service-5.1.2.zip)
- since the deployment does not follow the standards we need to arrange it.

### Making the folder
- create a new folder DS inside the bundles folder with the subfolders conf and env
- from the release, copy the xdiscovery-service-5.1.2\x1v1\conf\xdiscovery-service into the conf folder
- from the relase, copy the xdiscovery-service-5.1.2\x1v1\docker\.env file into the env folder and rename it ds.env

### Check the proxy configuration

- Every service should be proxied by the HAProxy set up in the node.
- The configuration of the proxy should handle every AIS service.
- Check the file haproxy/conf/haproxy.conf to be sure you service is correctly handled [here](https://confluence.dedalus.com/display/IAT/IVD+Services+-+deployment+info) in the table where you see the column HAproxy configuration ready. Otherwise check the documentation of the product


### Setting the deployment info
- into the ds.env file set the deployment info, in this case we assume xdiscovery as user, psw and db name
- the MONGODB_CONN_STRING with the url of the mongo , in our case mongo:27017
- application.properties according to the ds settings
- in the application properties set the "iana.tld.additional" property to handle the name of the base solution image
ex: the solution is at https://your.solution.dedalus set iana.tld.additional=dedalus
- configuration.json with the identity provider


### mongo collection creation

- Log into the node
- assume the docker user 
- check if the mongo database is running by typing
```bash
docker container ls
```
It should appear something like this: that's the name of the container
![PuTTy Opening](./guides/assets/mongo_install_show_container.png)

if not, start the container

You can use whatever tool you may like to connect to the mongo instance.
In here we use an approach without an external tool

Then enter the container to use the mongoshell
In this example the user is 'admin' and the psw is 'admin': change them according to the deployment

```bash
docker exec -it mongo-mongo-1 mongosh -u admin -p admin
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
cd  /opt/dedalus/docker/bundles/ds
```
- create the service
```bash
bash scripts/ds.sh stage create
```

Now we check for the serviec to be up
1. Open the haproxy stats , you will see a green row on the DISCOVERY row
2. run "docker container ls" and see the container running
3. Open the page "https://your.solution.com/xdiscovery-service/admin"
