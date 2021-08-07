FROM jenkins/jenkins:lts

USER root
RUN chown 1000:1000 /var/jenkins_home/*

ARG HOST_GID=134
RUN apt-get update
RUN apt-get -y install apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common
RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"
RUN apt-get update
RUN apt-get -y install docker-ce
RUN apt-get install -y docker-compose
RUN apt remove golang-docker-credential-helpers -y

RUN groupmod -g $HOST_GID docker
RUN usermod -aG docker jenkins

RUN apt install python3-pip -y
RUN pip3 install awscli --upgrade 

USER jenkins