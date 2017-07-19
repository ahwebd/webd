#!/bin/bash -ex

# Get full path of script directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get variables
source $script_dir/../../../common-variables
source $script_dir/../../../3-wsgiserver/1-variables
source $script_dir/../1-variables

# settings.py
echo "DEBUG = False" | tee -a $apps_dir/$web_env/$project/$project/settings.py

# restart wsgiserver
docker stop $(docker ps -f name=^/wsgiserver. -q)

# @todo
# https://docs.djangoproject.com/en/dev/howto/deployment/checklist/
