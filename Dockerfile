#
# Created: 2020-08
# Author: Samir Djerbi 
# Description:
# Docker image suitable for DevOps-work. Includes the following tools:
#
#    * kubectl
#    * helm
#    * az-cli
#    * sudo
#    * git
#    * openssl
# 
# This Dockerfile takes two build arguments:
#    - user: A user the container session will run as. The user is created without a password.
#    - pw: If you want to use `sudo` you need to pass this argument with a pre-generated hash that will be inserted into /etc/shadow.
#
###############################################################################

FROM alpine:3.12.0
MAINTAINER samir.djerbi@uptimesystems.se

ARG user
ARG pw

RUN apk update 
RUN apk add --no-cache tzdata bash bash-completion curl python3 python3-dev gcc make musl-dev libffi-dev openssl-dev procps sudo openssl vim bind-tools git

# 
# Timezone is set to UTC+2 inside image
#
RUN cp /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
RUN echo "Europe/Stockholm" > /etc/timezone
RUN apk del tzdata

#
# Set up user
#
RUN adduser -D -s /bin/bash -g "Mr Admin" ${user}
RUN addgroup ${user} wheel
RUN sed -i "s,${user}:!,${user}:${pw},g" /etc/shadow
RUN sed -i "s,# %wheel ALL=(ALL) ALL,%wheel ALL=(ALL) ALL,g" /etc/sudoers
RUN touch /home/${user}/.bashrc
RUN chown ${user}:${user} /home/${user}/.bashrc
RUN echo 'source  /usr/share/bash-completion/bash_completion' >> /home/${user}/.bashrc
RUN echo "export PS1='\e[36m[\e[1;93m\$(kubectl config current-context)\e[0;36m][\e[1;32m\u\e[90m@\e[1;32m\h\e[0;36m]:\e[94m\w\e[0m$ '" >> /home/${user}/.bashrc

#
# Install and set up kubectl and Helm
# 
RUN curl -sLO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/bin/kubectl
RUN echo 'source <(kubectl completion bash)' >> /home/${user}/.bashrc
RUN curl -s https://get.helm.sh/helm-canary-linux-amd64.tar.gz -o - | tar zxv -C /tmp/
RUN mv /tmp/linux-amd64/helm /usr/bin
RUN echo 'source <(helm completion bash)' >> /home/${user}/.bashrc

#
# Install and set up az-cli
#
USER ${user}
RUN curl -sL https://azurecliprod.blob.core.windows.net/install.py > /tmp/install.py
RUN printf "\n\n\n\n" | python3 /tmp/install.py
RUN rm /tmp/install.py

#
# Start bash shell as configured user
#
CMD bash 
