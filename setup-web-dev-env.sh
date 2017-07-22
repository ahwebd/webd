#!/bin/bash -ex

# Get full path of script directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

bash $script_dir/pull-docker-images.sh
bash $script_dir/1-docker-init/setup.sh
bash $script_dir/2-dbserver/2-setup.sh
bash $script_dir/3-webserver/2-setup.sh
bash $script_dir/4-python/1-wsgiserver/1-setup.sh

#bash $script_dir/stools/2-setup.sh
bash $script_dir/stoolsdev/2-setup.sh

bash $script_dir/selenium/2-setup.sh
