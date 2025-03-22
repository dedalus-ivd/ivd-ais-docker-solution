# AWS registry management

The first thing will be to have 2 or more registries where to push the images you will build. For every image you need to buil you will have 2 repositories, one for production, one for testing usually ending with "SNAPSHOT"

Each image have a name and can have multiple tags (usually the version)
The main difference will be that in the SNAPSHOT repo is possibile to override an image, while in the prod one is not.

For every registry you will receive:
- AWS_ACCESS_KEY_ID (read/write)
- AWS_SECRET_ACCESS_KEY (read/write)
- AWS_ACCESS_KEY_ID (read only)
- AWS_SECRET_ACCESS_KEY (read only)


When working with the AWS cli you need to be able to access AWS services.
To do it you will need an access_key, a password a region
You can set those in many ways


## Setting directly the variables
Open the bash and type
```bash
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_DEFAULT_REGION=us-west-2
```

## Using profiles
Profiles lets you manage multiple AWS access: imagin you are developing the "service one" but, to test it you need the "service two": you will need to log as the first when pushing you image, but as the second when you want to pull the image of the service two.
To do it you can set two profiles:
- service_one_push
- service_two_read

### With command line
Open the bash and type

```bash
aws configure --profile service_one_push
```
you will be asked
1. AWS Access Key ID
2. AWS Secret Access Key
3. Default region name (optional)
4. Default output format (optional)

and repeat this as many time you want

### Edit files

You can directly managed those profiles into the files
- <user_home>/.aws/config
- <user_home>/.aws/credentials

The files have no extension

In the credentials file there will be something like
```
[service_one_pull]
aws_access_key_id = AKIAVDseLFCU65I6R5TVE
aws_secret_access_key = CVbGy7/+DSb01lc+p08IEEwerrDPbeq+ch6tVVrg/
```
Between the square brakets is the profile name.
By adding lines like those ones you will add credentials.

In the config file you will find:
```
[profile service_one_pull]
region = eu-west-3
output = json
```

This is the definition of the profile linked with its own credentials into the credentials file.
### Setting the profile
To set the current profile in use you can simply open the bash and type
```bash
export AWS_PROFILE=service_one_pull
```

To test it
```bash
aws sts get-caller-identity
```
you will get something like

```bash
{
  "Account": "123456789012", 
  "UserId": "AR#####:#####", 
  "Arn": "arn:aws:sts::123456789012:assumed-role/role-name/role-session-name"
}
```

### Using credentials on windows
Editing the files under the Linux OS it's not so comfortable, su you can do the same under the windows os (if you are using the WSL)
1. place the .aws folder under you user home, like "C:\Users\youruser\.aws"
2. place the config and credentials files in there
3. open the bash and go into you user home
```bash
cd ~
```
The ~ could be done by pressing ALT+126
Then do
```bash
ls -a
```
a file called .bashrc should be listed
To edit it write
```bash
vi ./.bashrc 
```
it will open the vi editor which is a command line editor.
Go to the end of the file and add
```bash
export AWS_CONFIG_FILE=/mnt/c/Users/youruser/.aws/config
export AWS_SHARED_CREDENTIALS_FILE=/mnt/c/Users/rpanyourusertieri/.aws/credentials
```
to close VI editor
- press ESC
- digit :wq
- press enter

In this way every time you log into the bash it will add those two variables that say that your actual configuration files are in that position
To test it you will need to re login


