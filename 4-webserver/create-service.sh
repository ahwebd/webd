#!/bin/bash -ex

# Get full path of script directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get variables
source $script_dir/../common-variables
source $script_dir/1-variables

# webserver service
docker service create \
  --name webserver \
  --hostname $server_hostname-webserver \
  --network webd \
  --publish 80:80 \
  --mount type=bind,src=$apps_dir,dst=$apps_dir \
  --mount src=nginx_conf,dst=/etc/nginx/conf.d \
  $nginx
