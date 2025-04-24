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
```bash
cp -r /home/ec2-user/dev/ /opt/dedalus/docker/
```

## Mongo deployment

```bash
cd /opt/dedalus/docker/dev/
```

```bash
mv mongo/compose/mongo.yml ./
```
```bash
mv /opt/dedalus/docker/dev/mongo/compose/mongo.yml /opt/dedalus/docker/dev/
```

```bash
 docker compose -f mongo.yml --env-file env/shared.env --env-file env/routes.env --env-file mongo/env/mongo.env create
```
```bash
docker compose -f /opt/dedalus/docker/dev/mongo.yml --env-file /opt/dedalus/docker/dev/env/shared.env --env-file /opt/dedalus/docker/dev/mongo/env/mongo.env start
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