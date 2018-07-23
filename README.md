# tactical-edge-computing

## Local Development Settings

01. Create a vanilla development server (I started with a AL1 EC2 instance), AWS
    Cloud9 instances work well too. I created mine with an Elastic IP just to
    keep my client ssh config static.
    - Update! This works with AL2 as well.
02. Install the following packages:
    ```bash
    [ec2-user@host ~]$ sudo yum install git docker
    ```
03. Clone dot-files onto the dev server (ideally into the home directory):
    ```bash
    [ec2-user@host ~]$ git clone https://github.com/brandonsimpkins/dot-files
    ```
04. Install the dotfiles (note - this sets up a few things in the environment
    that makes the next few steps work - e.g. prepending $HOME/bin to the
    $PATH):
    ```bash
    [ec2-user@host ~]$ ~/dot-files/install.sh
    ```
05. Create a host entry in your workstation ~/.ssh/config file. This allows for
    local port forwarding over 8000.
    ```bash
    Host bender
      Hostname 18.207.62.105
      User ec2-user
      IdentityFile ~/.ssh/keys/bssimpk-dev.pem
      LocalForward 8000 localhost:8000

    ServerAliveInterval 120
    ```
06. Clone this repo:
    ```bash
    [ec2-user@host ~]$ git clone https://github.com/brandonsimpkins/tactical-edge-computing
    ```
07. Install Docker Compose
    ```bash
    [ec2-user@host ~]$ ~/tactical-edge-computing/dev-scripts/get-docker-compose.sh
    ```
08. Following the [Docker installation instructions for Amazon Linux](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html):
    ```bash
    [ec2-user@host ~]$ sudo service docker start
    [ec2-user@host ~]$ sudo usermod -a -G docker ec2-user
    ```
09. Enable the docker service on startup:
    - For Amazon Linux 1:
      ```bash
      [ec2-user@host ~]$ sudo chkconfig docker on
      ```
    - For Amazon Linux 2:
      ```bash
      [ec2-user@host ~]$ sudo systemctl enable docker.service
      ```
10. Log out and log back in again for the usermod command to take effect.
11. Verify you can run docker commands without typing sudo:
    ```bash
    docker info
    ```
12. Change into the tactical computing directory and start the local apps!
    ```bash
    [ec2-user@host ~]$ cd tactical-edge-computing/src/
    [ec2-user@host src]$ docker-compose up
    ```
    Note: currently I dont have a polling mechanism for the apps to wait to see
    if the database is up, so you the first time you run the docker-compose up
    command the app will fail to connect to the database since it has to create
    the database file system and create the ddl.
13. Turn your cattle into a pet! [Set the hostname for your AL1 / AL2  server](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/set-hostname.html)
    - For Amazon Linux 1:
      ```bash
      [ec2-user@host ~]$ sudo vim /etc/sysconfig/network
      ```
      Set the `HOSTNAME` variable to what you want your hostname to be, like so:
      ```bash
      HOSTNAME=bender.dev.simpkins.cloud
      ```
    - For Amazon Linux 2
      ```bash
      [ec2-user@host ~]$ sudo hostnamectl set-hostname ${HOSTNAME}
      ```
    Reboot for the hostname change to take effect.
14. Install python 3.6 for virtualenv.
    ```bash
    [ec2-user@host ~]$ sudo yum install python36-virtualenv -y
    ```
15. Create the python 3.6 virtualenv for local use (this allows you to have the
    same version of python for dev / test use. This will also allow you to
    interact with the django ultilities / code using the same dependencies):
    ```bash
    [ec2-user@host ~]$ cd ~/tactical-edge-computing/src
    [ec2-user@host ~]$ make virtualenv
    [ec2-user@host ~]$ source ~/python-3.6-dev-env/bin/activate
    ```




## TODO
- Create reverse proxy and x509 auth for django app
- Create container for processing backups / upload to s3?
- Fix generated certs to include subject alt names for chrome security checks
  - https://www.techrepublic.com/article/how-to-resolve-ssl-certificate-warnings-produced-by-the-latest-chrome-update/

## Notes / Links
- This looks like the real deal, setting up a nginx reverse proxy and
  forwarding onto a generic wsgi application.
  - https://github.com/peopledoc/django-x509
  - https://medium.com/@joatmon08/using-containers-to-learn-nginx-reverse-proxy-6be8ac75a757
- Django module you install that ties the user management to x509 header
  fields.
  - https://github.com/nimbis/django-x509-auth]
- AWS Reference Architectures:
  - https://github.com/awslabs/ecs-refarch-continuous-deployment
  - https://aws.amazon.com/blogs/compute/nginx-reverse-proxy-sidecar-container-on-amazon-ecs/
- Native django integration with external auth:
  - https://docs.djangoproject.com/en/dev/howto/auth-remote-user/
- Great GitHub README Markdown Cheat Sheet!
  - https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet

## AWS CLI Command Reference:
- Recursive copy into S3
  ```bash
  [ec2-user@host ~]$ aws s3 cp ca-archive/ s3://isengard-tactical-edge-computing-dev-bucket/ca-archive --recursive
  ```

## Git CLI Command Reference:
- Cache GitHub credentials locally:
  ```bash
  git config credential.helper store
  ```
