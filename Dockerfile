FROM rundeck/rundeck:3.1.0

USER root

RUN echo "deb http://archive.ubuntu.com/ubuntu xenial-updates main restricted universe multiverse /" | sudo tee -a /etc/apt/sources.list

RUN apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove && \
    apt-get -y update && \
    apt-get -y install \
    software-properties-common  \
    apt-transport-https \
    iputils-ping \
    openssh-server \
    netcat-traditional \
    unzip \
    zip

RUN apt-get -y install \
    apt-utils

RUN apt-get -y install build-essential \
    make \
    ruby \
    ruby-dev    

RUN gem update --system
RUN gem install ffi
RUN gem install json --platform=ruby
RUN gem install winrm -v 2.3.2
RUN gem install winrm-fs -v 1.3.2
RUN gem install rubyntlm -v 0.6.2    

ENV RD_WINRM='1.7.0'
RUN curl -L https://github.com/NetDocuments/rd-winrm-plugin/archive/$RD_WINRM.zip -o /home/rundeck/libext/rd-winrm-plugin-$RD_WINRM.zip

# install ansible
RUN apt-get -y install sshpass && \
    apt-get -y install python3-pip && \
    apt-get -y install python-pip && \
    pip3 install --upgrade pip

RUN pip3 install ansible && \
    pip3 install "pywinrm>=0.3.0"

USER rundeck
ENV RDECK_BASE=/home/rundeck \
    ANSIBLE_CONFIG=/home/rundeck/ansible/ansible.cfg \
    ANSIBLE_HOST_KEY_CHECKING=False

RUN mkdir /home/rundeck/ansible 
## && chown rundeck:rundeck /home/rundeck/ansible

VOLUME ["/home/rundeck/server/data"]

EXPOSE 4440
ENTRYPOINT [ "docker-lib/entry.sh" ]
