FROM python:3.5.3
ARG DEBIAN_FRONTEND="noninteractive"

RUN set -ex \
    && apt-get update && apt-get install -y \
      apt-utils \
    && rm -rf /var/lib/apt/lists/*

RUN set -ex \
    && apt-get update && apt-get install -y \
# misc tools
      bash-completion \
      less \
      man-db \
      nano \
      patch \
# needed packages and dependencies
      apt-transport-https \
      ca-certificates \
      curl \
      git \
      software-properties-common \
      sudo \
      unzip \
    && rm -rf /var/lib/apt/lists/*

# Create a user with sudo privileges
RUN set -ex \
    && adduser --disabled-password --gecos "" dkr \
    && echo "dkr ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers.d/50-users-config

USER dkr
WORKDIR /home/dkr
ENV TERM="xterm-256color"

# Enable command history search by typing first characters then up/down keys
RUN sed -i '/force_color_prompt/s/^#//g' ~/.bashrc \
    && { \
          echo '# Command history search'; \
      		echo '"\e[A": history-search-backward'; \
      		echo '"\e[B": history-search-forward'; \
        } >> ~/.inputrc

CMD ["sleep","infinity"]
