#!/bin/sh

# global variables
NGINX_PRIVATE_KEY=/etc/nginx/certs/private-key.pem
NGINX_PUBLIC_CERT=/etc/nginx/certs/public-cert.pem

# check to see if the DEBUG variable is set
if [ "$DEBUG" ]; then
  echo
  echo "DEGUG mode is enabled!"
  echo
  env
  echo
fi

# check to see if the DEPLOYMENT_TYPE variable is set
if [ "$DEPLOYMENT_TYPE" ]; then
  echo "Detected $DEPLOYMENT_TYPE Deployment Type"
  echo
else
  echo "Did not detect a deployment type! Exiting!"
  exit 1
fi

# configure based on different deployment types
if [ "$DEPLOYMENT_TYPE" == "DEV-LOCAL" ] || \
   [ "$DEPLOYMENT_TYPE" == "DEV-REMOTE" ]; then

  echo "Loading DEV-LOCAL Settings"
  echo

  # install the correct certs
  echo "Copying $(hostname -f) certificates"
  cp /opt/reverse-proxy/server-certs/$(hostname -f)-*/server-private-key.pem $NGINX_PRIVATE_KEY
  cp /opt/reverse-proxy/server-certs/$(hostname -f)-*/server-public-cert.pem $NGINX_PUBLIC_CERT
  echo

  # set hostnames
  REVERSE_PROXY_FQDN="$(hostname -f)"
  SUPPLY_SERVICE_FQDN="supply-rest-service.internal.com"

elif [ "$DEPLOYMENT_TYPE" == "PRODUCTION" ] || \
     [ "$DEPLOYMENT_TYPE" == "TEST-PIPELINE" ] || \
     [ "$DEPLOYMENT_TYPE" == "DEV-PIPELINE" ]; then

  # REVERSE_PROXY_FQDN and SUPPLY_SERVICE_FQDN are set by the ECS cluster

  if [ -z "$REVERSE_PROXY_FQDN" ]; then
    echo "REVERSE_PROXY_FQDN env variable is not set!"
    exit 3
  fi

  if [ -z "$SUPPLY_SERVICE_FQDN" ]; then
    echo "SUPPLY_SERVICE_FQDN env variable is not set!"
    exit 4
  fi

  echo "REVERSE_PROXY_FQDN originally set to: $REVERSE_PROXY_FQDN"

  # Process the passed in FQDN. Convert upper case to lower case, and strip off
  # a trailing period. I'm trimming the last period off the FQDN since the
  # cloud formation template requires dns zone names to have them.
  REVERSE_PROXY_FQDN="$(echo $REVERSE_PROXY_FQDN | \
    tr '[:upper:]' '[:lower:]' |  \
    sed 's/\.$//g')"

  echo "REVERSE_PROXY_FQDN updated to: $REVERSE_PROXY_FQDN"

  # install the correct certs
  echo "Copying $REVERSE_PROXY_FQDN certificates"
  cp /opt/reverse-proxy/server-certs/$REVERSE_PROXY_FQDN-*/server-private-key.pem $NGINX_PRIVATE_KEY
  cp /opt/reverse-proxy/server-certs/$REVERSE_PROXY_FQDN-*/server-public-cert.pem $NGINX_PUBLIC_CERT
  echo

else
  echo "ERROR: Failed to load $DEPLOYMENT_TYPE settings!"
  exit 2
fi

# copy and process the /etc/nginx/nginx.conf template
echo "Nginx Dynamic Environment Configuration Settings"
echo
echo "REVERSE_PROXY_FQDN: $REVERSE_PROXY_FQDN"
echo "SUPPLY_SERVICE_FQDN: $SUPPLY_SERVICE_FQDN"
echo

cp /opt/reverse-proxy/config-templates/nginx.conf /etc/nginx/nginx.conf
sed -i "s/\[REVERSE_PROXY_FQDN\]/$REVERSE_PROXY_FQDN/g" /etc/nginx/nginx.conf
sed -i "s/\[SUPPLY_SERVICE_FQDN\]/$SUPPLY_SERVICE_FQDN/g" /etc/nginx/nginx.conf

# verify cert info
echo "Displaying Certificate/Key Pair Information:"
echo
ls -la $NGINX_PRIVATE_KEY
ls -la $NGINX_PUBLIC_CERT
echo

# compute public cert hash
public_modulus=$(openssl x509 -in $NGINX_PUBLIC_CERT -modulus -noout)
public_hash=$(echo $public_modulus | openssl md5 | cut -d' ' -f2)
echo "Hashed modulus of public cert: ${public_hash}"

# compute private key hash
private_modulus=$(openssl rsa -in $NGINX_PRIVATE_KEY -modulus -noout)
private_hash=$(echo $public_modulus | openssl md5 | cut -d' ' -f2)
echo "Hashed modulus of private key: ${public_hash}"
echo

echo "Public Certificate Information:"
openssl x509 -noout -in $NGINX_PUBLIC_CERT -issuer -subject -dates | \
  sed 's/^/  /g'
echo

echo "Subject Alternate Name DNS Entries:"
openssl x509 -noout -in $NGINX_PUBLIC_CERT -text | \
  grep 'DNS' | \
  tr ',' '\n' | \
  sed 's/^\s*/  /g'
echo


/opt/reverse-proxy/scripts/get-host-metadata.sh > /usr/local/nginx/html/host-metadata.html &
ls -la /usr/local/nginx/html/host-metadata.html

# Start up nginx, save PID so we can reload config inside of run_certbot.sh
echo "Starting Nginx"
nginx -g "daemon off;"

