# Docker image management

Once you have your software release built you will need to:

0. Have a registry where to push the image
1. Build the image
2. Test the image
3. Push the image to a repository
4. Pull the image into a docker environment

Since Dedalus has chosen AWS to host its images, first we need to set up the AWS cli profiles to access the repositories.

## Build the image

The registry you have will be something like: 
436593330755.dkr.ecr.eu-west-3.amazonaws.com/service_one


We strongly suggest to use the s2i tool provided here
[s2i tool](https://confluence.dedalus.com/display/DRA/Openshift+Source2Image+Workflow)

You will need to pass to the s2i tool the image name and version you want to produce, like

436593330755.dkr.ecr.eu-west-3.amazonaws.com/service_one:1.0.1

To build and push the image you will need to

1. build the image
2. log to the aws registry
3. push the image

A script could be like this
```bash
export AWS_PROFILE=service_push
export SERVICE_VERSION=1.0.1
export AWS_REPO=436593330755.dkr.ecr.eu-west-3.amazonaws.com
export SERVICE_NAME=service_one

s2i build <application_code/binary> <builder_image>:<tag> ${AWS_REPO}/${PRODUCT_NAME}:${SERVICE_NAME}

aws ecr get-login-password --region eu-west-3 | docker login --username AWS --password-stdin ${AWS_REPO}

docker push ${AWS_REPO}/${PRODUCT_NAME}:${SERVICE_NAME}
```
- at first we set some useful variables
- then we build the image
- then we log into aws
- at the end we push the image

