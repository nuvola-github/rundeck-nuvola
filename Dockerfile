FROM rundeck/rundeck:3.1.0

USER root
RUN echo "deb http://archive.ubuntu.com/ubuntu xenial-updates main restricted universe multiverse /" | sudo tee -a /etc/apt/sources.list

RUN apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove && \
    apt-get -y update && \
    apt-get -y install \
    apt-utils \
    software-properties-common  \
    apt-transport-https \
    iputils-ping \
    openssh-server \
    netcat-traditional \
    unzip \
    zip

# installa requisiti per la build delle librerie winrm
RUN apt-get -y install build-essential \
    make \
    ruby \
    ruby-dev    

# installa le librerie winrm
RUN gem update --system
RUN gem install rake
RUN gem install ffi
RUN gem install json --platform=ruby
RUN gem install winrm -v 2.3.2
RUN gem install winrm-fs -v 1.3.2
RUN gem install rubyntlm -v 0.6.2    

# installa il plug-in per rundeck che consente l'invio di comandi a winrm
ENV RD_WINRM='1.7.0'
RUN curl -L https://github.com/NetDocuments/rd-winrm-plugin/archive/$RD_WINRM.zip -o /home/rundeck/libext/rd-winrm-plugin-$RD_WINRM.zip

# installa pip
# installa supporto python ad winrm
# installa ansible 
RUN apt-get -y --no-install-recommends install ca-certificates python3-pip sshpass python-pip \
 && pip3 --no-cache-dir install --upgrade pip setuptools \
 && pip3 --no-cache-dir install ansible \
 && pip3 --no-cache-dir install "pywinrm>=0.3.0" \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir /etc/ansible

USER rundeck

ENV RDECK_BASE=/home/rundeck \
    ANSIBLE_CONFIG=/home/rundeck/ansible/ansible.cfg \
    ANSIBLE_HOST_KEY_CHECKING=False

ENV MANPATH=${MANPATH}:${RDECK_BASE}/docs/man
ENV PATH=${PATH}:${RDECK_BASE}/tools/bin

# add default project
ENV PROJECT_BASE=${RDECK_BASE}/projects/Test-Project
RUN mkdir -p ${PROJECT_BASE}/etc/
COPY --chown=rundeck:rundeck docker/project.properties ${PROJECT_BASE}/etc/

# add locally built ansible plugin
COPY --chown=rundeck:rundeck build/libs/ansible-plugin-*.jar ${RDECK_BASE}/libext/

RUN mkdir /home/rundeck/ansible 
## eliminato perchè dava errore : && chown rundeck:rundeck /home/rundeck/ansible

VOLUME ["/home/rundeck/server/data"]

EXPOSE 4440
ENTRYPOINT [ "docker-lib/entry.sh" ]
