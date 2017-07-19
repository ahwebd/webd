#!/bin/bash -ex

# Get full path of script directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get variables
source $script_dir/../common-variables
source $script_dir/1-variables

# Start stoolsdev service
docker service create \
  --name stoolsdev \
  --hostname $server_hostname-stoolsdev \
  --network webd \
  --publish 8000:8000 \
  --mount src=stoolsdev_home,dst=/home \
  --mount type=bind,src=$apps_dir,dst=$apps_dir \
  --mount src=pgsockets,dst=/var/run/postgresql \
  --mount src=uwsgi_vassals,dst=/etc/uwsgi/vassals \
  --mount src=nginx_conf,dst=/etc/nginx/conf.d \
  $stoolsdev
