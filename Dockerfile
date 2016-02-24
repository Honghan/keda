# start from a base ubuntu image
FROM ubuntu
MAINTAINER Honghan Wu <honghan.wu@gmail.com>

########
# Pre-reqs
########
RUN apt-get update \ 
&& apt-get -y install software-properties-common \
&& add-apt-repository ppa:openjdk-r/ppa

RUN apt-get update \
	&& apt-get install -y \
	ant \
	curl \
	openjdk-8-jdk \
	subversion \
	unzip \
	vim


ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64/

#install maven ant tasks library
RUN cd /usr/share/ant/lib \
	&& curl http://www.mirrorservice.org/sites/ftp.apache.org/maven/ant-tasks/2.1.3/binaries/maven-ant-tasks-2.1.3.jar > maven-ant-tasks-2.1.3.jar

#######
# KGEDA
#######

# Create a user and roup with a specified U/GID.
# You should also create this group on the host and add any users who will be using this container.
RUN groupadd -g67890 kgeda
RUN useradd -u67890 -g kgeda -ms /bin/bash kgeda

# Create a mountpoint for the host volume
RUN mkdir /kgdata
RUN chown kgeda:kgeda /kgdata
VOLUME /kgdata
RUN chmod g+ws /kgdata
RUN setfacl -Rdm g:kgeda:rwx /kgdata


# Install GCP&GATE to /opt/kgeda
RUN mkdir /opt/kgeda
WORKDIR '/opt/kgeda'

ENV JAVA_TOOL_OPTIONS '-Dfile.encoding=UTF8'

RUN cd /opt/kgeda
ENV KGEDA_HOME '/opt/kgeda'
RUN svn co http://honghan.info/svn/research/programes/EDPStore --username UID --password PWD
RUN cd /opt/kgeda/EDPStore && ant

RUN cd /opt/kgeda
RUN svn co http://honghan.info/svn/research/programes/KDriveQG --username UID --password PWD
RUN cd /opt/kgeda/KDriveQG && ant

# Set the user so we don't run as root
USER kgeda
ENV HOME /home/kgeda
WORKDIR /home/kgeda

ENTRYPOINT pwd
