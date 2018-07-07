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
  echo "Issues a user p12 certificate from the specified CA."
  echo
  echo "Currnetly options are mandatory to save implementation time"
  echo
  echo "  -c, --ca-dir       specified directory with ca public cert, key, and"
  echo "                     password file to issue user cert from"
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
cert_directory="signed-user-cert-$(date +%Y-%m-%d_%H%M)"
output_file="${cert_directory}/generate-certs.out"

# set the locations of the generated public and private certs
user_private_key="${cert_directory}/user-private-key.pem"
user_public_cert="${cert_directory}/user-public-cert.pem"
user_public_cert_csr="${cert_directory}/user-public-cert-csr.pem"
user_password_file="${cert_directory}/user-password.txt"
user_pkcs12_cert="${cert_directory}/user-certificate.p12"

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
# generate the user private key
#
echo
echo "Generating the unencrypted user private key."
openssl genrsa -out ${user_private_key} 4096 &>$output_file
exit_on_error "Failed to generate the user private key!!!"

#
# generate the user public cert csr
#
echo
echo "Generating the user cert csr."
read -e -p " > Organization: " -i "simpkins.cloud" user_org
read -e -p " > Organizational Unit: " -i "App User Cert" user_ou
read -e -p " > Email: " -i "youremail@email.cloud" user_email
read -e -p " > Common Name: " -i "First Name Last Name" user_cn

user_subject="/O=${user_org}/OU=${user_ou}/Email=${user_email}/CN=${user_cn}"

openssl req -new -key "${user_private_key}" \
  -out "${user_public_cert_csr}" \
  -days "${cert_days}" \
  -subj "${user_subject}" &>$output_file

exit_on_error "Failed to generate the user cert csr!!!"

#
# generate the user certificate and sign it with the root ca
#
echo
echo "Generating the user's public certificate."

openssl x509 -req -in ${user_public_cert_csr} \
  -out "${user_public_cert}" \
  -CA "${ca_public_cert}" \
  -CAkey "${ca_private_key}" \
  -passin pass:${ca_password} \
  -set_serial "0x$(openssl rand -hex 16)" \
  -days $cert_days &>$output_file

# TODO: look up the freaky voodoo that generates the serial

exit_on_error "Failed to generate the user's public cert!!!"

echo

#
# hash the user private key modulus
#
private_dec_modulus=$(openssl rsa -in ${user_private_key} -modulus \
  -noout 2>$output_file)

exit_on_error "Failed to get the modulus of user private key!!!"

private_key_hash=$(echo $private_dec_modulus | openssl md5 | cut -d' ' -f2 \
  2>$output_file)

exit_on_error "Failed to hash the modulus of user private key!!!"

echo "Hashed modulus of user private key:           ${private_key_hash}"

#
# hash the user csr modulus
#
csr_modulus=$(openssl req -in ${user_public_cert_csr} -modulus -noout \
  2>$output_file)

exit_on_error "Failed to get the modulus of user csr!!!"

csr_hash=$(echo $csr_modulus | openssl md5 | cut -d' ' -f2 2>$output_file)

exit_on_error "Failed to hash the modulus of user csr!!!"

echo "Hashed modulus of the user csr:               ${csr_hash}"


#
# hash the user public cert modulus
#
public_modulus=$(openssl x509 -in ${user_public_cert} -modulus -noout \
  2>$output_file)

exit_on_error "Failed to get the modulus of user public cert!!!"

public_cert_hash=$(echo $public_modulus | openssl md5 | cut -d' ' -f2 \
  2>$output_file)

exit_on_error "Failed to hash the modulus of user public cert!!!"

echo "Hashed modulus of the user public cert:       ${public_cert_hash}"


#
# Assert that the hashes match
#
[ "$private_key_hash" == "$csr_hash" ] && \
  [ "$private_key_hash" == "$public_cert_hash" ] || \
  exit_on_error "Modulus hashes for generated user certs do not match!!!"

echo
echo "Modulus hashes for generated user certificates match."

#
# Create password for the user p12 file
#

user_password=""
while [ -z "$user_password" ]; do

  echo
  echo "Create the password for the user's p12 certificate:"
  read -s -e -p " > Password: " user_password
  echo
  read -s -e -p " > Again: " user_password_again
  echo

  if [ -z "$user_password" ] || \
     [ "$user_password" != "$user_password_again" ]; then

    echo
    echo "ERROR: user passwords don't match!"
    user_password=""
  fi
done
echo "$user_password" > "$user_password_file"

#
# Generate the encyrpted p12 file
#
echo
echo "Generating the user's p12 certificate."

openssl pkcs12 -export -inkey "${user_private_key}" \
  -in "${user_public_cert}" \
  -out "${user_pkcs12_cert}" \
  -passout "pass:${user_password}"

exit_on_error "Failed to generate the user's p12 cert!!!"

#
# Show the end results to the user
#
echo
echo "Created the user certificate: ${user_subject}"
echo
echo "The following user certs, keys, and password files have been created:"
ls -lA ${cert_directory}/*
echo
