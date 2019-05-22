FROM jenkins/jenkins:lts

USER root
ARG pswd=1234
RUN mkdir -p /usr/local/bin \
    && chown jenkins /usr/local/bin \
    && apt-get update \
    && apt-get install sudo \
    && echo "${pswd}\n${pswd}" | passwd \
    && echo "${pswd}\n${pswd}" | sudo passwd jenkins \
    && sudo adduser jenkins sudo

USER jenkins
WORKDIR /usr/local/bin
RUN cd ~ \
    && echo $(wget https://docs.google.com/uc?id=0B3X9GlR6EmbnWksyTEtCM0VfaFE&export=download) \ 
    && mv uc?id=0B3X9GlR6EmbnWksyTEtCM0VfaFE gdrive \
    && chmod +x gdrive \
    && install gdrive /usr/local/bin/gdrive
WORKDIR /var/jenkins_home
