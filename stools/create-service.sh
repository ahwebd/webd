#!/bin/bash -ex

# Get full path of script directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get variables
source $script_dir/../common-variables
source $script_dir/1-variables

# Start stools service
docker service create \
  --name stools \
  --hostname $server_hostname-stools \
  --network webd \
  --publish 8000:8000 \
  --mount src=stools_home,dst=/home \
  --mount type=bind,src=$apps_dir,dst=$apps_dir \
  --mount src=pgsockets,dst=/var/run/postgresql \
  --mount src=uwsgi_vassals,dst=/etc/uwsgi/vassals \
  --mount src=nginx_conf,dst=/etc/nginx/conf.d \
  $stools
