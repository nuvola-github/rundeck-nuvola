FROM rundeck/rundeck:3.1.0

USER root
RUN echo "deb http://archive.ubuntu.com/ubuntu xenial-updates main restricted universe multiverse /" | sudo tee -a /etc/apt/sources.list

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
    unzip \
    zip

# installa requisiti per la build delle librerie winrm
RUN apt-get -y install \
    build-essential \
    libssl-dev \ 
    libffi-dev \
    python-dev \
    make \
    ruby \
    ruby-dev   
    
RUN apt-get -y --no-install-recommends install sshpass ca-certificates
RUN apt-get -y --no-install-recommends install python3-pip python3-dev python-pip  

# installa le librerie winrm
RUN gem install rake
RUN gem install ffi
RUN gem install json --platform=ruby
RUN gem install winrm -v 2.3.2
RUN gem install winrm-fs -v 1.3.2
RUN gem install rubyntlm -v 0.6.2    
RUN gem update --system

# installa il plug-in per rundeck che consente l'invio di comandi a winrm
RUN curl -L https://github.com/rundeck-plugins/py-winrm-plugin/releases/download/2.0.3/py-winrm-plugin-2.0.3.zip -o /home/rundeck/libext/py-winrm-plugin-2.0.3.zip

# installa pip
RUN pip3 --no-cache-dir install setuptools 
RUN pip3 --no-cache-dir --user install --upgrade pip 
# installa ansible 
RUN pip3 --no-cache-dir install ansible 
# installa supporto python ad winrm
RUN pip3 --no-cache-dir install "pywinrm>=0.3.0"
 
RUN rm -rf /var/lib/apt/lists/* 
RUN mkdir /etc/ansible

USER rundeck

ENV RDECK_BASE=/home/rundeck \
    ANSIBLE_CONFIG=/home/rundeck/ansible/ansible.cfg \
    ANSIBLE_HOST_KEY_CHECKING=False

ENV PATH=${PATH}:${RDECK_BASE}/tools/bin
ENV MANPATH=${MANPATH}:${RDECK_BASE}/docs/man

# add locally built ansible plugin
COPY --chown=rundeck:rundeck build/libs/ansible-plugin-*.jar ${RDECK_BASE}/libext/

RUN mkdir /home/rundeck/ansible 
## eliminato perchè dava errore : && chown rundeck:rundeck /home/rundeck/ansible

# add default project
ENV PROJECT_BASE=${RDECK_BASE}/projects/Test-Project
RUN mkdir -p ${PROJECT_BASE}/etc/
COPY --chown=rundeck:rundeck docker/project.properties ${PROJECT_BASE}/etc/

VOLUME ["/home/rundeck/server/data"]

EXPOSE 4440
ENTRYPOINT [ "docker-lib/entry.sh" ]
