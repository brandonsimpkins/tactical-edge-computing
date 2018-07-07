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
    echo ""
    echo "$1"
    echo ""

    # if the command output exists, output it
    if [ -f $output_file ]; then
      echo ""
      echo "Command Output:"
      echo ""
      cat $output_file
      echo ""
    fi

    # exit unsuccessfully
    exit $return_code
  fi

  # delete the command output text file if it exists
  rm -f $output_file
}

#
# Begin Script
#

# set the umask
umask 0077

# configure the number of days that certificates are valid for
cert_days='1095'
cert_directory="self-signed-ca-$(date +%Y-%m-%d_%H%M)"
output_file="${cert_directory}/generate-certs.out"

# set the locations of the generated public and private certs
ca_private_key="${cert_directory}/ca-private-key.pem"
ca_public_cert="${cert_directory}/ca-public-cert.pem"
ca_password_file="${cert_directory}/ca-password.txt"

#
# clean up created files
#
if [ -d "$cert_directory" ]; then

  echo ""
  echo "Deleting existing CA directory: '$cert_directory'"
  rm -rf $cert_directory
fi
mkdir $cert_directory

#
# generate the CA password
#
echo ""
echo "Generating the CA private key password."
ca_password="$(openssl rand 12 | openssl sha1 | awk '{print $2}')"
echo "${ca_password}" > "${ca_password_file}"

#
# generate the ca private key, make sure we encrypt it
#
echo ""
echo "Generating the CA private key."
openssl genrsa -aes128 -out ${ca_private_key} -passout pass:${ca_password} \
  4096 &>$output_file

exit_on_error "Failed to generate the CA private key!!!"

#
# generate the ca public cert (i.e. temp root certificate)
#
echo
echo "Generating the CA public certificate."
read -e -p " > Country: " -i "US" ca_country
read -e -p " > Organization: " -i "Brandon Simpkins" ca_org
read -e -p " > Organizational Unit: " -i "simpkins.cloud" ca_ou
read -e -p " > Common Name: " -i "Self Signed Root CA 1" ca_cn

ca_subject="/C=${ca_country}/O=${ca_org}/OU=${ca_ou}/CN=${ca_cn}"

openssl req -x509 -new -key ${ca_private_key} -passin pass:${ca_password} \
  -out ${ca_public_cert} -days $cert_days \
  -subj "$ca_subject"

exit_on_error "Failed to generate the CA public certificate!!!"


#
# hash the ca private key modulus
#
private_modulus=$(openssl rsa -in ${ca_private_key} -modulus -noout \
  -passin pass:${ca_password} 2>$output_file)

exit_on_error "Failed to get the modulus of CA private key!!!"

private_hash=$(echo $private_modulus | openssl md5 | cut -d' ' -f2 \
  2>$output_file)

exit_on_error "Failed to hash the ca private key modulus!!!"

echo ""
echo "Hashed modulus of CA private key: ${private_hash}"


#
# hash the ca public cert modulus
#
public_modulus=$(openssl x509 -in ${ca_public_cert} -modulus -noout \
  2>$output_file)

exit_on_error "Failed to get the modulus of CA public cert!!!"

public_hash=$(echo $public_modulus | openssl md5 | cut -d' ' -f2 \
  2>$output_file)

exit_on_error "Failed to hash the ca public cert modulus!!!"

echo "Hashed modulus of CA public cert: ${public_hash}"


#
# Assert that the hashes match
#
[ "$private_hash" == "$public_hash" ] || \
  exit_on_error "Modulus hashes for generated CA certs do not match!!!"

echo "Modulus hashes for generated CA certificates match."

#
# Show the end results to the user
#
echo
echo "Created the CA: ${ca_subject}"
echo
echo "The following CA key, cert, and password files have been created:"
ls -lA ${cert_directory}/*
echo
