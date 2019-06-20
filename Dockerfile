FROM jenkins/jenkins:jdk11

USER root
ARG pswd=1234
RUN mkdir -p /usr/local/bin \
    && chown jenkins /usr/local/bin \
    && apt-get update \
    && apt-get install sudo \
    && apt-get install zip \
    && echo "${pswd}\n${pswd}" | passwd \
    && echo "${pswd}\n${pswd}" | sudo passwd jenkins \
    && sudo adduser jenkins sudo

USER jenkins
WORKDIR /usr/local/bin
RUN cd ~ \
    && echo $(wget https://drive.google.com/uc?id=1Ej8VgsW5RgK66Btb9p74tSdHMH3p4UNb&export=download) \ 
    && mv uc?id=1Ej8VgsW5RgK66Btb9p74tSdHMH3p4UNb gdrive \
    && chmod +x gdrive \
    && install gdrive /usr/local/bin/gdrive
WORKDIR /var/jenkins_home
