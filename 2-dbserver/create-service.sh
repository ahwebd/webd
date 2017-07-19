#!/bin/bash -ex

# Get full path of script directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get variables
source $script_dir/../common-variables
source $script_dir/1-variables

# Start database service
docker service create \
  --name dbserver \
  --hostname $server_hostname-dbserver \
  --network webd \
  --mount src=pgdata,dst=/var/lib/postgresql/data \
  --mount src=pgsockets,dst=/var/run/postgresql \
  $postgres
