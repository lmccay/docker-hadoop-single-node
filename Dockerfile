#
# Copyright (c) 2014 Sticksnleaves
#
# Apache Hadoop 2.3.0 single node install
#

FROM centos:6.4
MAINTAINER Larry McCay

# Prepare the operating system
# RUN apt-get update
# RUN apt-get upgrade -y

# Install Java dependencies
ENV JAVA_HOME /usr/lib/jvm/jdk
RUN yum install -y openjdk-7-jdk maven
RUN ln -s /usr/lib/jvm/java-7-openjdk-amd64 $JAVA_HOME

# Install dependencies
RUN yum install -y llvm-gcc build-essential make cmake automake autoconf libtool zlib1g-dev

# install Ambari repository
RUN rpm -Uvh http://s3.amazonaws.com/dev.hortonworks.com/AMBARI.baikal-1.x/repos/centos6/AMBARI.baikal-1.x-1.el6.noarch.rpm

# install Ambari server
RUN yum install ambari-server -y    #This should also pull in postgres packages as well.

# setup Ambari server
RUN ambari-server setup



# Prepare fuse for JDK install
# RUN yum install -y libfuse2
# RUN cd /tmp ; apt-get download fuse
# RUN cd /tmp ; dpkg-deb -x fuse_* .
# RUN cd /tmp ; dpkg-deb -e fuse_*
# RUN cd /tmp ; rm fuse_*.deb
# RUN cd /tmp ; echo -en '#!/bin/bash\nexit 0\n' > DEBIAN/postinst
# RUN cd /tmp ; dpkg-deb -b . /fuse.deb
# RUN cd /tmp ; dpkg -i /fuse.deb


# Add hadoop user
RUN addgroup hadoop
RUN useradd -d /home/hduser -m -s /bin/bash -G hadoop hduser

# Configure SSH
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN su hduser -c "ssh-keygen -t rsa -f ~/.ssh/id_rsa -P ''"
RUN su hduser -c "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys"
ADD config/ssh_config ./ssh_config
RUN mv ./ssh_config /home/hduser/.ssh/config

# Setup Hadoop
# ENV HADOOP_HOME /usr/local/hadoop
# ENV HADOOP_DATA /var/lib/hadoop
# ADD packages/hadoop-2.3.0.tar.gz ./hadoop-2.3.0.tar.gz
# RUN mv hadoop-2.3.0.tar.gz/hadoop-2.3.0 /usr/local/hadoop-2.3.0
# RUN ln -s /usr/local/hadoop-2.3.0 $HADOOP_HOME
# RUN rm -rf hadoop-2.3.0.tar.gz
# RUN mkdir $HADOOP_HOME/logs
# RUN mkdir -p $HADOOP_DATA/2.3.0/data
# RUN mkdir -p $HADOOP_DATA/current/data
# RUN ln -s $HADOOP_DATA/2.3.0/data $HADOOP_DATA/current/data

# Export Hadoop environment variables
ENV PATH $PATH:$HADOOP_HOME/bin
ENV PATH $PATH:$HADOOP_HOME/sbin
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV YARN_HOME $HADOOP_HOME

RUN echo "export JAVA_HOME=$JAVA_HOME" >> /home/hduser/.bashrc
RUN echo "export HADOOP_HOME=$HADOOP_HOME" >> /home/hduser/.bashrc
RUN echo "export PATH=$PATH" >> /home/hduser/.bashrc
RUN echo "export HADOOP_MAPRED_HOME=$HADOOP_MAPRED_HOME" >> /home/hduser/.bashrc
RUN echo "export HADOOP_COMMON_HOME=$HADOOP_COMMON_HOME" >> /home/hduser/.bashrc
RUN echo "export HADOOP_HDFS_HOME=$HADOOP_HDFS_HOME" >> /home/hduser/.bashrc
RUN echo "export YARN_HOME=$YARN_HOME" >> /home/hduser/.bashrc

# Build protobuf
# ADD packages/protobuf-2.5.0.tar.gz ./protobuf-2.5.0.tar.gz
# RUN cd protobuf-2.5.0.tar.gz/protobuf-2.5.0 ; \
#     ./configure --prefix=/usr/local ; \
#     make ; \
#     make install
# RUN rm -rf protobuf-2.5.0*
# ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib

# HDFS ports
EXPOSE 50070 50470 9000 50075 50475 50010 50020 50090

# YARN ports
EXPOSE 8088 8032 50060
