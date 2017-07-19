#!/bin/bash -ex

# Get full path of script directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get variables
source $script_dir/../common-variables
source $script_dir/1-variables

# Pull docker image
docker pull $postgres

# Create postgres superuser password and store it as a docker secret
openssl rand -base64 12 | docker secret create postgres_pass_v1 -

# Start database service
docker service create \
  --name dbserver \
  --hostname $server_hostname-dbserver \
  --network webd \
  --mount src=pgdata,dst=/var/lib/postgresql/data \
  --mount src=pgsockets,dst=/var/run/postgresql \
  --secret source=postgres_pass_v1,target=postgres_pass \
  -e POSTGRES_PASSWORD_FILE="/run/secrets/postgres_pass" \
  $postgres
