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
ENV RD_WINRM='2.0.1'
RUN curl -L https://s3.us-west-2.amazonaws.com/spark-repo-prod.rundeck.com/oss/signed/binary/59ed572534b2/2.0.1?AWSAccessKeyId=ASIA25B6VOWTLAKHFQWR&Expires=1565603213&Signature=wAdMqCcP0V83Nn2WCJihQh3H1to%3D&response-content-disposition=attachment%3B%20filename%3D%22py-winrm-plugin-2.0.1.zip%22&response-content-type=application%2Fzip&x-amz-security-token=AgoJb3JpZ2luX2VjEEkaCXVzLXdlc3QtMiJHMEUCIQCUxCsArtg8FY71JRFbLjCZx0j7kjbQ5auaJXByRKxDrgIgScoa4O0PdPz6Kqa7HkSFUFbIABdxCDaKK2jpjQ5GcvQqmQII0v%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARAAGgw3NDk2MDMyMjI5NTAiDCI5a4UPJo4IND53eyrtAWkruTmuQI1F7LEsdtR7sJSXjIQpPRDo7bJ7%2F2ke3AK2nlPQeoGzR%2FaSwu%2Fki6tjtTxrn9nDY4aoRN0f84COlnJ5R0%2BgyyF1hhsEs5r6WVZOW%2BbRGTQhRnmtvOhRwI0E3Zqx89IoDbfPUOP5aLr7hXFY69XuyOvHmgA7wuv3pd%2FjlRZ%2BYYzm6CmrKyTWgyIYS2E9rMu3MD7xdut0kHBbx%2Ba7mHiBWUj9gwpslaZL%2F1EcCnAKKqQLnHzzbwnPhcWHVn4VIyU0S24JH3PMilJBC6HNgoHYf3g%2BsovkOvh2azFtbJVWIvHlg1b9J0S%2FIzD5xcTqBTq0ASmxXqtHZCEoI7bBgW2yli%2F9%2F79nZt8CsV316ffi1UMLqV8Ptmg%2B5yBHrNvt5u10%2BMN%2Bh2f7MIXPrR%2ByTucoNjH5XVUerDkXKa7bYPBHW8B5aZOgB6kh%2Fo2x2LP9m%2BHDkNwwJq6XOBdpktYke3Hg7%2FJU9PYOJaNBPuD6lNFLAKnRPXJJEK3wfnwK7bkkQH%2B6VOd181QuXYAYuFLtZlhkUwj2%2FgB%2FitKQNaWz1pVlLgqMVVQfpw%3D%3D -o /home/rundeck/libext/py-winrm-plugin-$RD_WINRM.zip
#RUN curl -L https://github.com/NetDocuments/rd-winrm-plugin/archive/$RD_WINRM.zip -o /home/rundeck/libext/py-winrm-plugin-$RD_WINRM.zip


# installa pip
# installa supporto python ad winrm
# installa ansible 
    
RUN apt-get -y --no-install-recommends install ca-certificates python3-pip python-pip sshpass python-pip \
 && pip3 install --user --upgrade setuptools pip \
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
