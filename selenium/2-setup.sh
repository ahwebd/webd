#!/bin/bash -ex

# Get full path of script directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get variables
source $script_dir/../common-variables
source $script_dir/1-variables

# See: https://github.com/SeleniumHQ/docker-selenium

# Pull docker images
docker pull $hub && docker pull $chrome && docker pull $firefox

# Hub service
docker service create \
  --name hub-se \
  --hostname $server_hostname-se-hub \
  --network webd \
  --publish 4444:4444 \
  $hub

# Chrome
docker service create \
  --name chrome-se \
  --hostname $server_hostname-se-chrome \
  --network webd \
  --publish 5555:5555 \
  --publish 5900:5900 \
  --mount type=tmpfs,tmpfs-size=2g,dst=/dev/shm \
  -e HUB_PORT_4444_TCP_ADDR=hub-se \
  -e HUB_PORT_4444_TCP_PORT=4444 \
  -e SCREEN_WIDTH=$screen_width \
  -e SCREEN_HEIGHT=$screen_height \
  $chrome

# Firefox
docker service create \
  --name firefox-se \
  --hostname $server_hostname-se-firefox \
  --network webd \
  --publish 5556:5555 \
  --publish 5901:5900 \
  --mount type=tmpfs,tmpfs-size=2g,dst=/dev/shm \
  -e HUB_PORT_4444_TCP_ADDR=hub-se \
  -e HUB_PORT_4444_TCP_PORT=4444 \
  -e SCREEN_WIDTH=$screen_width \
  -e SCREEN_HEIGHT=$screen_height \
  $firefox
