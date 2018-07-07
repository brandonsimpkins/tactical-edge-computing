#!/bin/bash

#
# This function prints out an error message and exits the program if the exit
# status of the last command is non-zero.
#
# Args:
# $1: the error message
#
function exit_on_error {

  # capture the previous return code
  return_code=$?

  # if the return code is non zero...
  if [ $return_code != 0 ]; then

    # output the error message
    echo
    echo "$1"
    echo

    # if the command output exists, output it
    if [ -f $output_file ]; then
      echo
      echo "Command Output:"
      echo
      cat $output_file
      echo
    fi

    # exit unsuccessfully
    exit $return_code
  fi

  # delete the command output text file if it exists
  rm -f $output_file
}

#
# This function prints the script usage
#
function usage {
  echo "Usage: $0 [-c CA Dir]"
  echo "Issues a server p12 certificate from the specified CA."
  echo
  echo "Currnetly options are mandatory to save implementation time"
  echo
  echo "  -c, --ca-dir       specified directory with ca public cert, key, and"
  echo "                     password file to issue server cert from"
  echo
  exit 1
}

#
# Begin Script
#

# process arguments
while [[ $# -gt 0 ]]; do

  option="$1"
  shift

  case $option in
    -c|--ca-dir)
      ca_private_key="$1/ca-private-key.pem"
      ca_public_cert="$1/ca-public-cert.pem"
      ca_password="$(cat $1/ca-password.txt)"
      shift
      ;;
    *)
      usage
      ;;
  esac
done

# verify that the ca private key exists
if ! [ -f "$ca_private_key" ]; then
  echo "Error: CA private key does not exist"
  exit 2
fi

# TODO: beef up error checking for individual "options" in the future.

# set the umask
umask 0077

# configure the number of days that certificates are valid for
cert_days='1095'
cert_directory="signed-server-cert-$(date +%Y-%m-%d_%H%M)"
output_file="${cert_directory}/generate-certs.out"

# set the locations of the generated public and private certs
server_private_key="${cert_directory}/server-private-key.pem"
server_public_cert="${cert_directory}/server-public-cert.pem"
server_public_cert_csr="${cert_directory}/server-public-cert-csr.pem"
server_password_file="${cert_directory}/server-password.txt"
server_pkcs12_cert="${cert_directory}/server-certificate.p12"

#
# clean up previously created files
#
if [ -d "$cert_directory" ]; then
  echo
  echo "Deleting existing cert directory: '$cert_directory'"
  rm -rf $cert_directory
fi
mkdir $cert_directory

#
# generate the server private key
#
echo
echo "Generating the unencrypted server private key."
openssl genrsa -out ${server_private_key} 4096 &>$output_file
exit_on_error "Failed to generate the server private key!!!"

#
# generate the server public cert csr
#
echo
echo "Generating the server cert csr."
read -e -p " > Organization: " -i "simpkins.cloud" server_org
read -e -p " > Organizational Unit: " -i "Server Cert" server_ou
read -e -p " > Email: " -i "brandonsimpkins@gmail.com" server_email
read -e -p " > Common Name: " -i "$(hostname)" server_cn

server_subject="/O=${server_org}/OU=${server_ou}/Email=${server_email}/CN=${server_cn}"

openssl req -new -key "${server_private_key}" \
  -out "${server_public_cert_csr}" \
  -days "${cert_days}" \
  -subj "${server_subject}" &>$output_file

exit_on_error "Failed to generate the server cert csr!!!"

#
# generate the server certificate and sign it with the root ca
#
echo
echo "Generating the server's public certificate."

openssl x509 -req -in ${server_public_cert_csr} \
  -out "${server_public_cert}" \
  -CA "${ca_public_cert}" \
  -CAkey "${ca_private_key}" \
  -passin pass:${ca_password} \
  -set_serial "0x$(openssl rand -hex 16)" \
  -days $cert_days &>$output_file

# TODO: look up the freaky voodoo that generates the serial

exit_on_error "Failed to generate the server's public cert!!!"

echo

#
# hash the server private key modulus
#
private_dec_modulus=$(openssl rsa -in ${server_private_key} -modulus \
  -noout 2>$output_file)

exit_on_error "Failed to get the modulus of server private key!!!"

private_key_hash=$(echo $private_dec_modulus | openssl md5 | cut -d' ' -f2 \
  2>$output_file)

exit_on_error "Failed to hash the modulus of server private key!!!"

echo "Hashed modulus of server private key:           ${private_key_hash}"

#
# hash the server csr modulus
#
csr_modulus=$(openssl req -in ${server_public_cert_csr} -modulus -noout \
  2>$output_file)

exit_on_error "Failed to get the modulus of server csr!!!"

csr_hash=$(echo $csr_modulus | openssl md5 | cut -d' ' -f2 2>$output_file)

exit_on_error "Failed to hash the modulus of server csr!!!"

echo "Hashed modulus of the server csr:               ${csr_hash}"


#
# hash the server public cert modulus
#
public_modulus=$(openssl x509 -in ${server_public_cert} -modulus -noout \
  2>$output_file)

exit_on_error "Failed to get the modulus of server public cert!!!"

public_cert_hash=$(echo $public_modulus | openssl md5 | cut -d' ' -f2 \
  2>$output_file)

exit_on_error "Failed to hash the modulus of server public cert!!!"

echo "Hashed modulus of the server public cert:       ${public_cert_hash}"


#
# Assert that the hashes match
#
[ "$private_key_hash" == "$csr_hash" ] && \
  [ "$private_key_hash" == "$public_cert_hash" ] || \
  exit_on_error "Modulus hashes for generated server certs do not match!!!"

echo
echo "Modulus hashes for generated server certificates match."

#
# Show the end results to the server
#
echo
echo "Created the server certificate: ${server_subject}"
echo
echo "The following server certs, keys, and password files have been created:"
ls -lA ${cert_directory}/*
echo
