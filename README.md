# tactical-edge-computing

## Features
01. "Cloud Native" application - See: [What Are Cloud-Native Applications?](https://pivotal.io/cloud-native)
    - Created a supply management micro service to handle (issue, receipt,
      stow) operations (e.g. managing inventory).
      - While the [Django Rest Framework](http://www.django-rest-framework.org/)
        might be a bit heavy for some
        to qualify as a "micro service", it provides the following great
        features that are definitely necessary at the enterprise level:
        - ORM / model layer which provides absrtraction from the relational
          database and allows for different database choices.
        - Simplified schema migration management.
        - Automatic created UI useful for navigating the rest services API.
          much easier.
        - Generic views / template capabilties. Significatnly reduces
          boilerplate code.
        - User authentication and authorization.
    - Created a [NGINX](https://www.nginx.com/) reverse proxy layer to server static content / javascript
      based applications and route to the microservices.
      - Static content delivery (HTML + CSS)
      - Dynamic service routing
      - Simple HTTPS configuration and management
      - Built in HTTP request logging and forwarding
      - x509 based client authetication using custom issued user certificates
    - Built on top of [Docker](https://www.docker.com/) to standardize deployments and simplify update managment.
      - The rest service and reverse proxy applications are self contained.
      - The docker images bring their own dependencies.
      - The applications are isolated from the host OS layer which makes OS updates easier.
      - Images are based on the [Alpine Linux Docker Image Distro](https://hub.docker.com/r/library/alpine/)
        which produces extremely small docker image sizes.
        ```
        [ec2-user@farnsworth src]$ docker images
        REPOSITORY            TAG                 IMAGE ID            CREATED             SIZE
        fd-reverse-proxy      latest              fc7d5d528be6        42 minutes ago      26.7MB
        supply-rest-service   latest              d32aedd2575d        19 hours ago        124MB
        postgres              10.4-alpine         9406c495d689        3 weeks ago         40.2MB
        ```
      - Updates are sent out based on 'layer' updates which minimizes bandwidth required for updates.
      - Updates can be deployed via physical media (e.g. DVDs)
02. Deployment envrironment architecture diagrams:
    - [CI /  CD Pipeline](architecture-diagrams/ci-cd-architecture.png)
    - [Enterprise Deployment Architecture](enterprise-supply-architecture.png)
    - [Standalone Deployment Architecture](shipboard-supply-architecture.png)
03. Deploys onto managed AWS infrastructure that provides a turnkey system
    administration experience.
    - Different deployments schemes are managed through envrionment settings
    - AWS Services Used
      - Cloud Formation
      - CodeBuild / CodeDeploy / CodePipeline
      - ECS fargate
      - Multi-AZ Postgres RDS
      - Route 53
04. Deploys onto local infrastructure (e.g. physical server, VM, snowball edge)
    that's running Docker (very similar to local development deployment)..
05. Developed on AWS Infrastructure. See [dev env setup procedures]
    (#Local-Development-Settings)
    - [CodeBuild buildspec.yaml](buildspec.yaml)
    - [CodeBuild Static Analysis yaml file](static-analysis-buildspec.yaml)
07. Cloud formation templates:
    - [Enterprise Application CF Template](cfn-templates/enterprise-app-vpc.template)
06. Development tools and scripts
    - Script to install the latest version of [Docker Compose](https://docs.docker.com/compose/)
    - Script to generate a self signed CA
    - Script to generate a server certificate (from the self signed CA)
    - Script to generate a user certificate p12 (from the self signed CA)

# Features (Not Checked Into Github)
01. Stick built CI / CD Pipeline

## Future Features
01. Cloud formation template for CI / CD Pipeline and Dev env
02. Create development server AMIs / bake in Cloud9.
03. Pull certificates from a secure bucket in S3
04. Store db account passwords in a parameter store
    - Optional use secrets manager to auto rotate RDS credentials

## Accessing The Application
01. Install Root CA onto your local computer.
    - [simpkins.cloud Self Signed Root CA](certificates/App_User_Root_CA_1-2018-07-07_0041-public-cert.pem)
    - [Install a Trusted Root CA on OSX](https://support.untangle.com/hc/en-us/articles/212220648-Manually-installing-root-certificate-on-Mac-OSX)
    - [Install a Trusted Root CA on Windows](https://blogs.technet.microsoft.com/sbs/2008/05/08/installing-a-self-signed-certificate-as-a-trusted-root-ca-in-windows-vista/)
02. Import a user p12 certificate into your profile.
    - [Brandon Simpkins p12 Certificate](certificates/brandon-simpkins.p12)

## AWS Issues That Need Improvement

To be fair, while these issues are annoying in development it seems that cloud
formation and ECS err on the side of caution. No doubt, generating and apply
change sets across distributed infrasture is a challenging task. I'm sure a
slow 3 hour automatic rollback of serices is nice should a deployment go south.

01. Ugh their python distro. makes me want to not use their virtualenv packages
    at all. Definitley not "Enterprise Ready"
    - See my [Python Complaints About VirtualENV on AWS](pip-install-error.txt)
      where I documented my issues with the PYTHON_INSTALL_LAYOUT environment
      variable setting.
02. General lack of Fargate logging. When something goes wrong in ECS is is not
    very apparent what is going on. This problem is worse in Fargate. And it's
    even worse when you dont use Cloud Watch logs (the only log provide)! I had
    to learn that one the hard way.
03. I'm not sure if this is still an issue or not, but a few weeks ago ECS was
    not logging when a ELB shutdown a container due to a healthcheck. When I
    and deploying my app via cloudformation it does. Will need to see if I can
    replicate the issue with code pipeline again. But with no notification
    about containers getting shut down due to health checks, the ECS / Fargate
    deployment will just constantly thrash between INITIAL and UNHEALTHY.
04. Cloud formation deployments don't trigger a rollback when a ECS deployment
    fails. This is the craziest thing of all. Not only will your cloud
    formation deployment just spin waiting for ECS to finish (which doesn't
    happen when you break your deploymenr *cough* security group rules), BUT
    the default rollback timer is 3 hours! And you can't change it!
05. Cloud formation and ECS don't always play nice together. When you try to
    roll back cloud formation changes wheile ECS is trying to stablize,
    cloud formation gets stuck. In trying to fix it I have had to (1) fix the
    issue causing the deployment failure (e.g. change security group rules),
    (2) update the service to have 0 deployed containers (3) trigger a stack
    delete / wait for a timeout.
06. Configuration drift between existing cloud formation stack resources and
    the template is possible. Especially when you edit resources in the
    console. Appropriate steps should be take to prevent that.
    - A Blue / Green deployment model would certainly help with a constant
      refresh of the whole application vpc.

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
16. Set the git commiter info:
    ```bash
    [ec2-user@host ~]$ git commit --amend --reset-author
    ```

##  App Issues
- Django takes ~10 seconds to shutdown, I think this is due to a generic
  timeout, and the SIG isn't getting handled correctly
- NGINX wont start if upstream server is down.



## TODO
- Create reverse proxy and x509 auth for django app
- Create container for processing backups / upload to s3?
- Fix generated certs to include subject alt names for chrome security checks
  - https://www.techrepublic.com/article/how-to-resolve-ssl-certificate-warnings-produced-by-the-latest-chrome-update/
- Create mechanism to securely pull certs from S3 on docker image build or
  container start.

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
- AWS NIST quickstart reference:
  - https://github.com/aws-quickstart/quickstart-compliance-nist
  - checkout command:
    ```bash
    git clone --recurse-submodules https://github.com/aws-quickstart/quickstart-compliance-nist
    ```
- Good ECS / Fargate Templates:
  - https://github.com/nathanpeck/aws-cloudformation-fargate/blob/master/service-stacks/private-subnet-public-loadbalancer.yml
- Overview of conditional x509 authentication based on URL:
  -  https://fardog.io/blog/2017/12/30/client-side-certificate-authentication-with-nginx/



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
