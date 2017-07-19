#!/bin/bash -ex

# Get full path of script directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get variables
source $script_dir/../common-variables
source $script_dir/1-variables

# Create a docker volume that will hold users home directories,
# this way changes to user config/data will be kept after containers recreation
docker volume create stoolsdev_home \
  && docker run --rm -u root -v stoolsdev_home:/stoolsdev_home $stoolsdev \
    bash -c 'cp -rp /home/* /stoolsdev_home'

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

# To access containers easily, add bash aliases and functions:
echo '
# Access stoolsdev container
function std { docker exec -it $(docker ps -f name=^/stoolsdev. -q | sed -n 1p) bash; }

# Scale stoolsdev up or down
alias std-up="docker service scale stoolsdev=1"
alias std-down="docker service scale stoolsdev=0"
' | tee -a ~/.bash_aliases
