# HAPROXY Details

## Introduction
The proxy configuration is based on the assumption that the services respects some standards we gave ourself.<br>
- each service is deployed under the same subnetwork
- each service container has the standard name registered durig developments
- proxy takes the 443 port and redirects the calls to the services

## Security
The first two lines of comments are reporting the guidelines from the security team regarding the HAPROXY and how to secure the communication.<br>
The first one is how to set the accepted certificate: for now we accept from TLS 1.2 by default 'couse we observed some troubles with the 1.3

The secondo comment is about the security for every service

## Global
In here we have
- TSL definitions
- standard log definition

## Resolvers
Those lines are referred to the default DNS ip inside a docker subnetwork.
This is mandatory to let HAPROXY resolve a name "after" the start if not found during the startup

## Stats
Normal stats definition

## Health check
Simple health check, useful if there is another proxy or load balancer in front of the node

## Grafana frontend
Dedicated frontend for grafana service

## Secure FE
This is the main frontend that takes the 443 port and redirects all the calls to services backends  

- first it defines an ACL for every registere and known services.
- some services has path that are subpaths of other, so more than on ACL can be true at the same time
- to handle this it's important that "use_backend" directive are in the right order, from the more specific to the less one. Exameple. If I have 1 ACL for the path "/mydomain" and another for "/mydomain-app" when the second one is called also the first one is matched. So it's important to redirect first the second one.

## BACKENDS
WE have a backend for every service. The address is based on the container name of the service and the internal port exposed: when a container is created inside a network it registers 3 names to be found in the DNS
- the container name
- the service name (the one inside the compose)
- the container id.

For example, if in the compose file we have a service called "ivais" for the environment "stage" the services will have "ivais", "stage-ivais-1" and something like "8asdjoij34pjpoj" as DNS names.

The variables you see at the end of each backend in the address can be found in the "global-env" bundle:<br>
/opt/dedalus/docker/bundles/global-env/environments/env/proxy-map.env

At the server line, in the end  , there is how to resolve the name.

For each backend we applied the standard suggestions from the security team EXCEPT for the <br>
#http-response set-header Content-Security-Policy "default-src 'none';script-src 'self';img-src 'self';style-src 'self';"<br>
because no GUI seems to work with tha
