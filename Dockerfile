# This is a comment
FROM ubuntu:14.04

MAINTAINER Peter Andersen <peter@sproutup.co>

ENV ACTIVATOR_VERSION 1.3.2
ENV DEBIAN_FRONTEND noninteractive
ENV AWS_ACCESS_KEY_ID AKIAJM5X5NV444LJEUSA
ENV AWS_SECRET_KEY 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
ENV AWS_SECRET_ACCESS_KEY UHpVP/axa3eOmfCOcSQFGXwK4fzYMzHV8aYkh38X
ENV JENKINS_HOME /opt/jenkins
ENV ACTIVATOR_HOME /opt/activator

RUN apt-get update && apt-get install -y && rm -rf /var/lib/apt/lists/*

# Jenkins is ran with user `jenkins`, uid = 1000
# If you bind mount a volume from host/vloume from a data container, 
# ensure you use same uid
RUN useradd -d $JENKINS_HOME -u 1000 -m -s /bin/bash jenkins

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# ADD SSH KEY
ADD .ssh $JENKINS_HOME/.ssh

# INSTALL JAVA
ENV JAVA_VERSION 7u75
ENV JAVA_DEBIAN_VERSION 7u75-2.5.4-2
RUN apt-get update && apt-get install -y openjdk-7-jdk && rm -rf /var/lib/apt/lists/*

# INSTALL UTILS
RUN apt-get update && apt-get install -y wget git curl unzip && rm -rf /var/lib/apt/lists/*

# INSTALL TYPESAFE ACTIVATOR
RUN mkdir $ACTIVATOR_HOME
RUN cd $ACTIVATOR_HOME
RUN wget -nv http://downloads.typesafe.com/typesafe-activator/$ACTIVATOR_VERSION/typesafe-activator-$ACTIVATOR_VERSION.zip
RUN unzip typesafe-activator-$ACTIVATOR_VERSION.zip -d .
#RUN mv $HOME_ACTIVATOR/activator-$ACTIVATOR_VERSION $ACTIVATOR_HOME/activator
RUN rm typesafe-activator-$ACTIVATOR_VERSION.zip
RUN chmod a+x $HOME_ACTIVATOR/activator-$ACTIVATOR_VERSION/activator
RUN ln $HOME_ACTIVATOR/activator-$ACTIVATOR_VERSION/activator /usr/local/bin/activator
RUN ln $HOME_ACTIVATOR/activator-$ACTIVATOR_VERSION/activator-launch-$ACTIVATOR_VERSION.jar /usr/local/bin/activator-launch-$ACTIVATOR_VERSION.jar

# INSTALL EB CLI
RUN apt-get update && apt-get install -y python-pip && rm -rf /var/lib/apt/lists/*
RUN pip install awsebcli
RUN eb --version

# INSTALL JENKINS
RUN wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
RUN sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y jenkins

EXPOSE 8080

RUN chown -R jenkins:jenkins $JENKINS_HOME
RUN chown -R jenkins:jenkins $ACTIVATOR_HOME
#RUN chown -R jenkins /usr/local/activator/activator-launch-$ACTIVATOR_VERSION.jar

# will be used by attached slave agents:
#EXPOSE 50000

USER jenkins

# GET JENKINS CONFIG FROM GITHUB
RUN cd $JENKINS_HOME
RUN git clone git@github.com:sproutup/jenkins.git

CMD ["/usr/bin/java", "-jar", "/usr/share/jenkins/jenkins.war"]

#RUN etc/init.d/jenkins start
