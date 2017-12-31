#!/bin/sh

# ------------------------------------------------------------------------
# Copyright 2017 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License
# ------------------------------------------------------------------------

# variables
WSO2_SERVER=$1
WSO2_SERVER_VERSION=$2
WSO2_SERVER_PACK=${WSO2_SERVER}-${WSO2_SERVER_VERSION}.zip
JDK_ARCHIVE=jdk-8u*-linux-x64.tar.gz
WORKING_DIRECTORY=/home/ubuntu
JAVA_HOME=$WORKING_DIRECTORY/java/

export DEBIAN_FRONTEND=noninteractive

# run package updates
apt-get update
# install utility software
apt-get install unzip

# set up Java
if test ! -d $JAVA_HOME; then mkdir $JAVA_HOME; fi
if test -d $JAVA_HOME; then
  tar -xf /vagrant/files/$JDK_ARCHIVE -C $JAVA_HOME --strip-components=1
  export JAVA_HOME
fi

# copy the WSO2 product pack

# note: <product-pack>/bin folder is specifically checked here, since by the time this check is executed,
# the <product-pack> folder is created due to artifact syncing
if test ! -d ${WSO2_SERVER}-${WSO2_SERVER_VERSION}/bin; then
  cp /vagrant/files/$WSO2_SERVER_PACK $WORKING_DIRECTORY
  unzip -q -n /vagrant/files/$WSO2_SERVER_PACK -d $WORKING_DIRECTORY
  rm $WORKING_DIRECTORY/$WSO2_SERVER_PACK
fi

# set ownership of the working directory to the default 'ubuntu' user and group
chown -R ubuntu:ubuntu $WORKING_DIRECTORY

# copy changed configuration files
cp /vagrant/identity-server/common/repository/components/lib/mysql-connector-java-5.1.34-bin.jar $WORKING_DIRECTORY/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/components/lib/mysql-connector-java-5.1.34-bin.jar
cp /vagrant/identity-server/node-$3/repository/conf/axis2/axis2.xml $WORKING_DIRECTORY/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/conf/axis2/axis2.xml
cp /vagrant/identity-server/common/repository/conf/datasources/master-datasources.xml $WORKING_DIRECTORY/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/conf/datasources/master-datasources.xml
cp /vagrant/identity-server/common/repository/conf/carbon.xml $WORKING_DIRECTORY/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/conf/carbon.xml
cp /vagrant/identity-server/common/repository/conf/user-mgt.xml $WORKING_DIRECTORY/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/conf/user-mgt.xml
cp /vagrant/identity-server/common/repository/conf/identity/embedded-ldap.xml $WORKING_DIRECTORY/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/conf/identity/embedded-ldap.xml
cp /vagrant/identity-server/common/repository/conf/identity/identity.xml $WORKING_DIRECTORY/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/conf/identity/identity.xml
cp /vagrant/identity-server/common/repository/deployment/server/eventpublishers/IsAnalytics-Publisher-wso2event-AuthenticationData.xml $WORKING_DIRECTORY/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/deployment/server/eventpublishers/IsAnalytics-Publisher-wso2event-AuthenticationData.xml
cp /vagrant/identity-server/common/repository/deployment/server/eventpublishers/IsAnalytics-Publisher-wso2event-SessionData.xml $WORKING_DIRECTORY/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/deployment/server/eventpublishers/IsAnalytics-Publisher-wso2event-SessionData.xml

# start the WSO2 product pack as a background service
echo "Starting ${WSO2_SERVER}-${WSO2_SERVER_VERSION}..."
sh $WORKING_DIRECTORY/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/bin/wso2server.sh start
