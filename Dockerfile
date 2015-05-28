# This is a comment
FROM ubuntu:14.04

MAINTAINER Peter Andersen <peter@sproutup.co>

ENV ACTIVATOR_VERSION 1.3.2
ENV DEBIAN_FRONTEND noninteractive
ENV AWS_ACCESS_KEY_ID AKIAJM5X5NV444LJEUSA
ENV AWS_SECRET_KEY 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
ENV AWS_SECRET_ACCESS_KEY UHpVP/axa3eOmfCOcSQFGXwK4fzYMzHV8aYkh38X
ENV JENKINS_HOME /opt/jenkins
ENV JENKINS_BASE /home/jenkins
ENV ACTIVATOR_HOME /opt/activator

RUN apt-get update && apt-get install -y && rm -rf /var/lib/apt/lists/*

# Jenkins is ran with user `jenkins`, uid = 1000
# If you bind mount a volume from host/vloume from a data container, 
# ensure you use same uid
RUN useradd -u 1000 -m -s /bin/bash jenkins 
##&& \
##    mkdir $JENKINS_HOME && \
##    chown -R jenkins:jenkins $JENKINS_HOME

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# ADD SSH KEY
ADD .ssh $JENKINS_BASE/.ssh
RUN chown -R jenkins:jenkins $JENKINS_BASE && \
    chmod 600 $JENKINS_BASE/.ssh/id_rsa

# INSTALL JAVA
ENV JAVA_VERSION 7u75
ENV JAVA_DEBIAN_VERSION 7u75-2.5.4-2
RUN apt-get update && apt-get install -y openjdk-7-jdk && rm -rf /var/lib/apt/lists/*

# INSTALL UTILS
RUN apt-get update && apt-get install -y wget git curl unzip && rm -rf /var/lib/apt/lists/*

# INSTALL TYPESAFE ACTIVATOR
RUN mkdir $ACTIVATOR_HOME && \
    cd $ACTIVATOR_HOME && \
    wget -nv http://downloads.typesafe.com/typesafe-activator/$ACTIVATOR_VERSION/typesafe-activator-$ACTIVATOR_VERSION-minimal.zip && \
    unzip typesafe-activator-$ACTIVATOR_VERSION-minimal.zip -d . && \
    rm typesafe-activator-$ACTIVATOR_VERSION-minimal.zip && \
    mv activator-$ACTIVATOR_VERSION-minimal activator-$ACTIVATOR_VERSION && \
    chmod a+x activator-$ACTIVATOR_VERSION/activator && \
    ln activator-$ACTIVATOR_VERSION/activator /usr/local/bin/activator && \
    ln activator-$ACTIVATOR_VERSION/activator-launch-$ACTIVATOR_VERSION.jar /usr/local/bin/activator-launch-$ACTIVATOR_VERSION.jar

# INSTALL EB CLI
RUN apt-get update && apt-get install -y python-pip && rm -rf /var/lib/apt/lists/* && \
    pip install awsebcli && \
    eb --version

# GET JENKINS CONFIG FROM GITHUB
USER jenkins
RUN git clone git@github.com:sproutup/jenkins.git $JENKINS_BASE/jenkins
USER root
RUN ln -s $JENKINS_BASE/jenkins/opt/jenkins $JENKINS_HOME

# INSTALL JENKINS
RUN wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add - && \
    sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list' && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y jenkins

EXPOSE 8080

RUN chown -R jenkins:jenkins $JENKINS_HOME && \
    chown -R jenkins:jenkins $ACTIVATOR_HOME
#RUN chown -R jenkins /usr/local/activator/activator-launch-$ACTIVATOR_VERSION.jar

# will be used by attached slave agents:
#EXPOSE 50000

USER jenkins

CMD ["/usr/bin/java", "-jar", "/usr/share/jenkins/jenkins.war"]

#RUN etc/init.d/jenkins start
