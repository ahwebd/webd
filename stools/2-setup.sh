#!/bin/bash -ex

# Get full path of script directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get variables
source $script_dir/../common-variables
source $script_dir/1-variables

# Create a docker volume that will hold users home directories,
# this way changes to user config/data will be kept after containers recreation
docker volume create stools_home \
  && docker run --rm -u root -v stools_home:/stools_home $stools \
    bash -c 'cp -rp /home/* /stools_home'

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

# To access containers easily, add bash aliases and functions:
echo '
# Access stools container
function st { docker exec -it $(docker ps -f name=^/stools. -q | sed -n 1p) bash; }

# Scale stools up or down
alias st-up="docker service scale stools=1"
alias st-down="docker service scale stools=0"
' | tee -a ~/.bash_aliases
