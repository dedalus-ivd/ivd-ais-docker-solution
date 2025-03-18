# ivd-ais-docker-solution

## Create the SWARM cluster
1. make sure you have at least three nodes with docker installed
2. make sure in every node you have a user (not root) that can use docker
3. usually we organize files, compose and data under /opt/dedalus/docker
4. make sure that all three nodes have this ports open:
- 2377 TCP for communication among manager nodes
- 7946 TCP/UDP for overlay networking
- 4789 UDP for overlay traffic
- 22 TCP for SSH access: that is not for the SWARM purposes but to configure them

### Swarm setup
1. Choose a node that will be the leader
2. Connect to the leader node and type the command:
```bash
docker swarm init --advertise-addr <LEADER_PRIVATE_IP>
```
that will output something like
```bash
Swarm initialized: current node (bvz81updecsj6wjz393c09vti) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-3pu6hszjas19xyp7ghgosyx9k8atbfcr8p2is99znpy26u2lkl-1awxwuwd3z9j1z3puu7rcgdbx 172.17.0.2:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```
3. Since the minumim configuration to tolerate one node failure is 3 managers we will at least configure 3 managers that in our case should act also like workers
4. copy the token you gained from step 2 and connect to node 2 and 3 and type
```bash
docker swarm join-token manager
```
it will output the instructions to follow to add the node as manager

5. Go on a node and run the command
```bash
docker node ls
```
it should output something like

```bash
ID             HOSTNAME      STATUS  AVAILABILITY  MANAGER STATUS
xxxxx12345678  instance-1    Ready   Active                Leader
yyyyy23456789  instance-2    Ready   Active                Reachable
zzzzz34567890  instance-3    Ready   Active                Reachable
```

## Create the MongoDB/Percona service

1 - Log into one manager node and create the mongo network
```bash
docker network create --driver overlay mongo
```