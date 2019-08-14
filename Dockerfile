# Ubuntu 16.04 based, runs as rundeck user
# https://hub.docker.com/r/rundeck/rundeck/tags
FROM rundeck/rundeck:3.1.0

MAINTAINER Massimo Loporchio <loporchio.massimo@cssnet.it>


USER root
RUN echo "deb http://archive.ubuntu.com/ubuntu xenial-updates main restricted universe multiverse /" | sudo tee -a /etc/apt/sources.list

RUN echo "deb https://dl.bintray.com/rundeck/rundeck-deb /" | sudo tee -a /etc/apt/sources.list

RUN apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove && \
    apt-get -y update

# intallazione requisiti ubuntu 
RUN apt-get -y install \
    apt-utils \
    software-properties-common  \
    apt-transport-https \
    iputils-ping \
    openssh-server \
    netcat-traditional \
    apt-transport-https \
    unzip \
    zip

# Installa il CLI di Rundeck per i backup
RUN curl "https://bintray.com/user/downloadSubjectPublicKey?username=bintray" > /tmp/bintray.gpg.key
RUN apt-key add - < /tmp/bintray.gpg.key
RUN apt-get -y install apt-transport-https
RUN apt-get -y install rundeck-cli

# installa requisiti per la build delle librerie winrm
RUN apt-get -y install \
    build-essential \
    libssl-dev \ 
    libffi-dev \
    python-dev \
    make \
    ruby \
    ruby-dev   

  
RUN apt-get -y --no-install-recommends install ca-certificates sshpass
RUN apt-get -y --no-install-recommends install python3-pip python3-dev python-pip  

# intalla pip
RUN  sudo -H pip3 --no-cache-dir install --upgrade pip setuptools

# installa ansible 
RUN sudo -H pip3 --no-cache-dir install ansible 
# installa supporto python ad winrm
RUN pip3 --no-cache-dir install "pywinrm>=0.3.0"[credssp]
RUN pip3 --no-cache-dir install requests-credssp --user

# installa le librerie winrm
RUN gem install rake
RUN gem install ffi
RUN gem install json --platform=ruby
RUN gem install winrm -v 2.3.2
RUN gem install winrm-fs -v 1.3.2
RUN gem install rubyntlm -v 0.6.2    
RUN gem update --system

USER rundeck

ENV RDECK_BASE=/home/rundeck \
    ANSIBLE_CONFIG=/home/rundeck/ansible/ansible.cfg \
    ANSIBLE_HOST_KEY_CHECKING=False
ENV MANPATH=${MANPATH}:${RDECK_BASE}/docs/man
ENV PATH=${PATH}:${RDECK_BASE}/tools/bin

RUN mkdir ${RDECK_BASE}/ansible 

# installa il plug-in per rundeck che consente l'invio di comandi a winrm
RUN curl -L https://github.com/rundeck-plugins/py-winrm-plugin/releases/download/2.0.3/py-winrm-plugin-2.0.3.zip -o ${RDECK_BASE}/libext/py-winrm-plugin-2.0.3.zip

# add default project
ENV PROJECT_BASE=${RDECK_BASE}/projects/Test-Project

RUN sudo rm -rf /var/lib/apt/lists/* \
  && mkdir -p ${PROJECT_BASE}/etc/ \
  && sudo mkdir /etc/ansible

#COPY --chown=rundeck:rundeck   docker/project.properties ${PROJECT_BASE}/etc/
#COPY docker/project.properties ${PROJECT_BASE}/etc/
#RUN  sudo chown -R rundeck:rundeck ${PROJECT_BASE}/etc/

# add locally built ansible plugin
#COPY --chown=rundeck:rundeck   build/libs/ansible-plugin-*.jar ${RDECK_BASE}/libext/
#COPY build/libs/ansible-plugin-*.jar ${RDECK_BASE}/libext/
#RUN  sudo chown -R rundeck:rundeck ${RDECK_BASE}/libext/

VOLUME ["/home/rundeck/server/data"]

EXPOSE 4440
ENTRYPOINT [ "docker-lib/entry.sh" ]
