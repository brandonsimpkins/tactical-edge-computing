#!/bin/bash

# enforce strict mode
set -e

export COMPOSE_VERSION="1.21.2"
export OS="$(uname -s)"
export ARCH="$(uname -m)"
export COMPOSE_URI="https://github.com/docker/compose/releases/download"
export COMPOSE_URI="$COMPOSE_URI/$COMPOSE_VERSION"
export COMPOSE_URI="$COMPOSE_URI/docker-compose-$OS-$ARCH"
export BIN_DIR="$HOME/bin"

echo
echo 'Ensuring $HOME is set: '"$HOME"
if [ -z "$HOME" ]; then
  echo '$HOME not set, exiting unsuccessfully'
  exit 1
fi

# create the home bin dir if necessary
echo
echo "Creating bin dir: $BIN_DIR"
mkdir -p "$BIN_DIR"

# get the the docker compose binary
echo
echo "Downloading docker-compose version: $COMPOSE_VERSION"
curl -L $COMPOSE_URI -o $BIN_DIR/docker-compose

echo
echo "Setting $BIN_DIR/docker-compose Permissions to 0700"
chmod 0700 $BIN_DIR/docker-compose

echo
echo "Validating path"
which docker-compose
