# tactical-edge-computing

## Local Development Settings










1. Create a vanilla development server (I started with a AL1 EC2 instance), AWS
   Cloud9 instances work well too. I created mine with an Elastic IP just to
   keep my client ssh config static.
   - Update! This works with AL2 as well.
2. Install the following packages:
   ```
   [ec2-user@ip-10-200-209-79 ~]$ sudo yum install git docker
   ```
2. Clone dotfiles onto the dev server (presumably into the home directory):
   ```
   [ec2-user@ip-10-200-208-28 ~] git clone https://github.com/brandonsimpkins/dot-files
   ```

3. Install the dotfiles (note - this sets up a few things in the environment
   that makes the next few steps work - e.g. prepending $HOME/bin to the
   $PATH):
   ```
   ~/dot-files/install.sh
   ```
4. Create a host entry in your workstation ~/.ssh/config file. This allows for
   local port forwarding over 8000.
   ```
   Host bender
     Hostname 18.207.62.105
     User ec2-user
     IdentityFile ~/.ssh/keys/bssimpk-dev.pem
     LocalForward 8000 localhost:8000

   ServerAliveInterval 120
   ```
5. Clone this repo:
   ```
   [ec2-user@ip-10-200-209-79 ~]$ git clone https://github.com/brandonsimpkins/tactical-edge-computing
   ```
6. Install Docker Compose
   ```
   [ec2-user@ip-10-200-209-79 ~]$ ~/tactical-edge-computing/dev-scripts/get-docker-compose.sh
   ```
7. Following the [https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html]
(Docker installation instructions) for Amazon Linux
   ```
   sudo service docker start
   sudo usermod -a -G docker ec2-user
   ```
8. Log out and log back in again for the usermod command to take effect.
9. Verify you can run docker commands without typing sudo:
   ```
   docker info
   ```
10. Change into the tactical computing directory and start the local apps!
    ```
    [ec2-user@ip-10-200-209-79 ~]$ cd tactical-edge-computing/src/
    [ec2-user@ip-10-200-209-79 src]$ docker-compose up
    ```
    Note: currently I dont have a polling mechanism for the apps to wait to see
    if the database is up, so you the first time you run the docker-compose up
    command the app will fail to connect to the database since it has to create
    the database file system and create the ddl.


## TODO
- Create reverse proxy and x509 auth for django app
- Create container for processing backups / upload to s3?
- Fix generated certs to include subject alt names for chrome security checks
  - https://www.techrepublic.com/article/how-to-resolve-ssl-certificate-warnings-produced-by-the-latest-chrome-update/

## Notes / Links
- This looks like the real deal, setting up a nginx reverse proxy and
  forwarding onto a generic wsgi application.
  - [https://github.com/peopledoc/django-x509]
  - [https://medium.com/@joatmon08/using-containers-to-learn-nginx-reverse-proxy-6be8ac75a757]
- Django module you install that ties the user management to x509 header
  fields.
  - [https://github.com/nimbis/django-x509-auth]
- AWS Reference Architectures:
  - [https://github.com/awslabs/ecs-refarch-continuous-deployment]
  - [https://aws.amazon.com/blogs/compute/nginx-reverse-proxy-sidecar-container-on-amazon-ecs/
- Native django integration with external auth:
  - [https://docs.djangoproject.com/en/dev/howto/auth-remote-user/]

## AWS CLI command references:
- Recursive copy into S3
  ```
  [ec2-user@bender dev-scripts]$ aws s3 cp ca-archive/ s3://isengard-tactical-edge-computing-dev-bucket/ca-archive --recursive
  ```

