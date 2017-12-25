#!/bin/sh

WSO2_SERVER=wso2is-analytics
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
  export JAVA_HOME
fi

# copy product pack
if test ! -d ${WSO2_SERVER}-${WSO2_SERVER_VERSION}; then
  cp /vagrant/files/$WSO2_SERVER_PACK $WORKING_DIRECTORY
  unzip -q /vagrant/files/$WSO2_SERVER_PACK -d $WORKING_DIRECTORY
  rm $WORKING_DIRECTORY/$WSO2_SERVER_PACK
fi

cp /vagrant/identity-server-analytics/common/repository/components/lib/mysql-connector-java-5.1.34-bin.jar $WORKING_DIRECTORY/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/components/lib/mysql-connector-java-5.1.34-bin.jar
#cp /vagrant/identity-server-analytics/common/repository/conf/analytics/spark/spark-defaults.conf $WORKING_DIRECTORY/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/conf/analytics/spark/spark-defaults.conf
#cp /vagrant/identity-server-analytics/node-$1/repository/conf/axis2/axis2.xml $WORKING_DIRECTORY/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/conf/axis2/axis2.xml
cp /vagrant/identity-server-analytics/common/repository/conf/datasources/analytics-datasources.xml $WORKING_DIRECTORY/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/conf/datasources/analytics-datasources.xml
cp /vagrant/identity-server-analytics/common/repository/conf/datasources/master-datasources.xml $WORKING_DIRECTORY/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/conf/datasources/master-datasources.xml
#cp /vagrant/identity-server-analytics/common/repository/conf/carbon.xml $WORKING_DIRECTORY/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/conf/carbon.xml
#cp /vagrant/identity-server-analytics/node-$1/repository/conf/event-processor.xml $WORKING_DIRECTORY/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/conf/event-processor.xml
cp /vagrant/identity-server-analytics/common/repository/conf/registry.xml $WORKING_DIRECTORY/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/conf/registry.xml
cp /vagrant/identity-server-analytics/common/repository/conf/user-mgt.xml $WORKING_DIRECTORY/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/conf/user-mgt.xml

chown -R ubuntu:ubuntu $WORKING_DIRECTORY

sh $WORKING_DIRECTORY/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/bin/wso2server.sh start
