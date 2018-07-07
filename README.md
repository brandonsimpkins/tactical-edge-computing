# tactical-edge-computing

## Local Development Settings

1. Create a vanilla development server (I started with a AL1 EC2 instance), AWS
   Cloud9 instances work well too. I created mine with an Elastic IP just to
   keep my client ssh config static.
2. Clone dotfiles onto the dev server (presumably into the home directory):
   ```
   [ec2-user@ip-10-200-208-28 ~] git clone https://github.com/brandonsimpkins/dot-files
   ```

3. Install the dotfiles:
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

