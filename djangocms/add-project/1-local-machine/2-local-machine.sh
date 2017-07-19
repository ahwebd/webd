#!/bin/bash -ex

# Get full path of script directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get variables
source $script_dir/1-variables

# Add site entry to /etc/hosts file
echo -e "
# $web_env.$project
$server_ip $web_env.$project" | sudo tee -a /etc/hosts;
