#!/bin/bash -ex

# Get full path of script directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get variables
source $script_dir/2-dbserver/1-variables
source $script_dir/3-webserver/1-variables
source $script_dir/4-python/1-variables
source $script_dir/stools/1-variables
source $script_dir/stoolsdev/1-variables
source $script_dir/selenium/1-variables

docker pull $postgres
docker pull $nginx
docker pull $python
#docker pull $stools
docker pull $stoolsdev
docker pull $hub
docker pull $chrome
docker pull $firefox
