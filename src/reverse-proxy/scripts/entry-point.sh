#!/bin/sh

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
if [ "$DEPLOYMENT_TYPE" == "DEV-LOCAL" ]; then
  echo "Loading DEV-LOCAL Settings"
  echo

  # install the correct certs
  echo "Copying $(hostname -f) certificates"
  cp /opt/reverse-proxy/server-certs/$(hostname -f)-*/server-private-key.pem /etc/nginx/certs/server.key
  cp /opt/reverse-proxy/server-certs/$(hostname -f)-*/server-public-cert.pem /etc/nginx/certs/server.crt
  echo

  # set hostnames
  REVERSE_PROXY_FQDN="$(hostname -f)"
  SUPPLY_SERVICE_FQDN="supply-rest-service.internal.com"

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
echo "Displaying Certificate Information:"
echo
ls -la /etc/nginx/certs/server*
echo

# compute public cert hash
public_modulus=$(openssl x509 -in /etc/nginx/certs/server.crt -modulus -noout)
public_hash=$(echo $public_modulus | openssl md5 | cut -d' ' -f2)
echo "Hashed modulus of public cert: ${public_hash}"

# compute private key hash
private_modulus=$(openssl rsa -in /etc/nginx/certs/server.key -modulus -noout)
private_hash=$(echo $public_modulus | openssl md5 | cut -d' ' -f2)
echo "Hashed modulus of private key: ${public_hash}"
echo

echo "Public Certificate Information:"
openssl x509 -noout -in /etc/nginx/certs/server.crt -issuer -subject -dates | \
  sed 's/^/  /g'
echo

echo "Subject Alternate Name DNS Entries:"
openssl x509 -noout -in /etc/nginx/certs/server.crt -text | \
  grep 'DNS' | \
  tr ',' '\n' | \
  sed 's/^\s*/  /g'
echo

# Start up nginx, save PID so we can reload config inside of run_certbot.sh
echo "Starting Nginx"
nginx -g "daemon off;"

