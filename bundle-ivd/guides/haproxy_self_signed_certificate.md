### Self signed certificate
There is already a cnf file to produce a self signed certificate in the folder /haproxy/conf
The file is called cert.cnf
You need to put the name of the node by decomment the line "DNS.1" or directly the IP address by decomment the line with IP.1
The certificate can be produced directly on the node.

- go to the haproxy/conf folder
```bash
cd  /opt/dedalus/docker/bundles/haproxy/environments/stage/conf
```

- produce the certificate
```bash
openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout  haproxy_cert.pem.key -out haproxy_cert.pem -config cert.cnf
```