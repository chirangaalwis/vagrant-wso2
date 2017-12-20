#!/bin/sh

WSO2_SERVER=wso2is
WSO2_SERVER_VERSION=5.4.0
WSO2_SERVER_PACK=${WSO2_SERVER}-${WSO2_SERVER_VERSION}.zip
JDK_ARCHIVE=jdk-8u*-linux-x64.tar.gz
WORKING_DIRECTORY=/home/ubuntu
JAVA_HOME=$WORKING_DIRECTORY/java/

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests \
curl \
iproute2 \
telnet \
unzip
rm -rf /var/lib/apt/lists/*

# set up Java
if test ! -d $JAVA_HOME; then mkdir $JAVA_HOME; fi
if test -d $JAVA_HOME; then
  tar -xf /vagrant/files/$JDK_ARCHIVE -C $JAVA_HOME --strip-components=1
  export JAVA_HOME=$JAVA_HOME
fi

# copy product pack
cp /vagrant/files/$WSO2_SERVER_PACK $WORKING_DIRECTORY
unzip -q /vagrant/files/$WSO2_SERVER_PACK -d $WORKING_DIRECTORY
rm $WORKING_DIRECTORY/$WSO2_SERVER_PACK

cp /vagrant/identity-server/repository/conf/axis2/axis2-2.xml /home/ubuntu/wso2is-5.4.0/repository/conf/axis2/axis2.xml
cp /vagrant/identity-server/repository/components/lib/mysql-connector-java-5.1.34-bin.jar /home/ubuntu/wso2is-5.4.0/repository/components/lib/mysql-connector-java-5.1.34-bin.jar
cp /vagrant/identity-server/repository/conf/datasources/master-datasources.xml /home/ubuntu/wso2is-5.4.0/repository/conf/datasources/master-datasources.xml
cp /vagrant/identity-server/repository/conf/carbon.xml /home/ubuntu/wso2is-5.4.0/repository/conf/carbon.xml
cp /vagrant/identity-server/repository/conf/user-mgt.xml /home/ubuntu/wso2is-5.4.0/repository/conf/user-mgt.xml

chown -R ubuntu:ubuntu $WORKING_DIRECTORY

sh $WORKING_DIRECTORY/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/bin/wso2server.sh start

# ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep '192.168.0*'
