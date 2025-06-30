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