FROM openjdk:11-jdk-stretch

RUN apt-get update && apt-get upgrade -y && apt-get install -y git curl && rm -rf /var/lib/apt/lists/*

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG agent_port=50000
ARG JENKINS_HOME=/var/jenkins_home

ENV JENKINS_HOME $JENKINS_HOME
ENV JENKINS_SLAVE_AGENT_PORT ${agent_port}

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN mkdir -p $JENKINS_HOME \
  && chown ${uid}:${gid} $JENKINS_HOME \
  && groupadd -g ${gid} ${group} \
  && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $JENKINS_HOME

# `/usr/share/jenkins/ref/` contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d

# Can be used to customize where jenkins.war get downloaded from
ARG JENKINS_URL=http://updates.jenkins-ci.org/latest/jenkins.war

# could use ADD but this one does not check Last-Modified header neither does it allow to control checksum
# see https://github.com/docker/docker/issues/8331
RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war 

ENV JENKINS_UC https://updates.jenkins.io
ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
ENV JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals
RUN chown -R ${user} "$JENKINS_HOME" /usr/share/jenkins/ref

# for main web interface:
EXPOSE ${http_port}

# will be used by attached slave agents:
EXPOSE ${agent_port}

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

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

USER ${user}
ENTRYPOINT ["java", "-jar", "/usr/share/jenkins/jenkins.war"]

