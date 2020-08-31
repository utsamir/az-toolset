#
# Created: 2020-08
# Author: Samir Djerbi 
# Description:
# Docker image suitable for DevOps-work. Includes the following tools:
#
#    * kubectl
#    * az-cli
#    * sudo
# 
# This Dockerfile takes two build arguments:
#    - user: Username the container session should be envoked as (default: admin)
#    - pw: Password hash to insert in /etc/shadow for above user
#
###############################################################################

FROM alpine:3.12.0
MAINTAINER samir.djerbi@uptimesystems.se

ARG user
ARG pw

RUN apk update 
RUN apk add --no-cache tzdata bash bash-completion curl python3 python3-dev gcc make musl-dev libffi-dev openssl-dev procps sudo

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
RUN echo "export PS1='\e[36m[\e[1;96m\$(kubectl config current-context)\e[0;36m/\e[1;32m\u\e[90m@\e[1;32m\h\e[0;36m]:\e[94m\w\e[0m$  '" >> /home/${user}/.bashrc

#
# Install and set up kubectl
# 
RUN curl --no-progress-meter -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/bin/kubectl
RUN echo 'source <(kubectl completion bash)' >> /home/${user}/.bashrc

#
# Install and set up az-cli
#
USER ${user}
RUN curl --no-progress-meter -L https://azurecliprod.blob.core.windows.net/install.py > /tmp/install.py
RUN printf "\n\n\n\n" | python3 /tmp/install.py

#
# Start bash shell as configured user
#
CMD bash 
