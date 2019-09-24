From jenkins/jenkins:lts
USER root
RUN echo
RUN apt-get update
RUN apt-get install -y \
    lynx \
    build-essential \
    file \
    cpio \
    diffstat \
    gawk \
    koji-client \
    python-krbv \
    sudo \
    apt-transport-https \
    ca-certificates \    
    curl \
    software-properties-common \
    locales
# Make sure docker works in container
RUN apt install -y apt-transport-https ca-certificates curl software-properties-common
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
RUN apt update
RUN apt -y install docker-ce
# Fix locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
# Add script for configuring koji certificates
COPY add-koji-cert.sh /usr/bin/
RUN chmod 755 /usr/bin/add-koji-cert.sh
USER jenkins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
USER root
RUN git clone https://github.com/jpuhlman/mvgit.git 
RUN cd mvgit; make prefix=/usr
RUN cd mvgit; make prefix=/usr install
RUN rm -rf mvgit
COPY init.sh /
RUN chmod 755 /init.sh
ENV INSTALL_PLUGINS 1
# Intentionally not switch to root so init can do some setup magic.
ENTRYPOINT ["/init.sh"]

