#!/bin/bash -ex

# Get full path of script directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get variables
source $script_dir/../../common-variables
source $script_dir/../1-variables

# wsgiserver service
docker service create \
  --name wsgiserver \
  --hostname $server_hostname-wsgiserver \
  --network webd \
  --mount type=bind,src=$apps_dir,dst=$apps_dir \
  --mount src=pgsockets,dst=/var/run/postgresql \
  --mount src=uwsgi_vassals,dst=/etc/uwsgi/vassals \
  --user $(id -u):101 \
  $python bash -c \
    "source $apps_dir/venvs/uwsgi/bin/activate &&
    uwsgi --emperor /etc/uwsgi/vassals"
# 101 is the group id of nginx, this way nginx will have necessary permissions
# on the socket created by wsgiserver
