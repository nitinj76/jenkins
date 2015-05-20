# This is a comment
FROM ubuntu:14.04

MAINTAINER Peter Andersen <peter@sproutup.co>

ENV ACTIVATOR_VERSION 1.3.2
ENV DEBIAN_FRONTEND noninteractive
ENV AWS_ACCESS_KEY_ID=AKIAJM5X5NV444LJEUSA
ENV AWS_SECRET_KEY=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

RUN apt-get update && apt-get install -y && rm -rf /var/lib/apt/lists/*

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

ENV JAVA_VERSION 7u75
ENV JAVA_DEBIAN_VERSION 7u75-2.5.4-2

RUN apt-get update && apt-get install -y openjdk-7-jdk && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y wget git curl unzip && rm -rf /var/lib/apt/lists/*

ENV JENKINS_HOME /var/lib/jenkins

# INSTALL TYPESAFE ACTIVATOR
RUN cd /tmp
RUN wget http://downloads.typesafe.com/typesafe-activator/$ACTIVATOR_VERSION/typesafe-activator-$ACTIVATOR_VERSION.zip
RUN unzip typesafe-activator-$ACTIVATOR_VERSION.zip -d /usr/local
RUN mv /usr/local/activator-$ACTIVATOR_VERSION /usr/local/activator
RUN rm typesafe-activator-$ACTIVATOR_VERSION.zip
RUN ln /usr/local/activator/activator /usr/local/bin/activator
RUN ln /usr/local/activator/activator-launch-$ACTIVATOR_VERSION.jar /usr/local/bin/activator-launch-$ACTIVATOR_VERSION.jar

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

# will be used by attached slave agents:
#EXPOSE 50000

#USER jenkins

CMD ["/usr/bin/java", "-jar", "/usr/share/jenkins/jenkins.war"]

#RUN etc/init.d/jenkins start
