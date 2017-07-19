#!/bin/bash -ex

# Get full path of script directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get variables
source $script_dir/../common-variables

# Inititialize docker swarm with a network
docker swarm init \
  && docker network create --attachable --driver overlay webd

# Create a directory that will hold our web apps code
sudo mkdir -p $apps_dir && sudo chown $(id -u):$(id -u) $apps_dir
