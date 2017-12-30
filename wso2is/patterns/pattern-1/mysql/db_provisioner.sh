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
DBPASSWD=wso2carbon

export DEBIAN_FRONTEND=noninteractive
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo debconf mysql-server/root_password password $DBPASSWD | \
  sudo debconf-set-selections
echo debconf mysql-server/root_password_again password $DBPASSWD | \
  sudo debconf-set-selections

apt-get update

# install mysql
apt-get -y install mysql-server

mysql -uroot -pwso2carbon -e "source /vagrant/mysql/scripts/mysql.sql"

mysql -uroot -pwso2carbon -e "create user 'root'@'192.168.100.3' identified by 'wso2carbon';"
mysql -uroot -pwso2carbon -e "grant all privileges on *.* to 'root'@'192.168.100.3' with grant option;"
mysql -uroot -pwso2carbon -e "create user 'root'@'192.168.100.4' identified by 'wso2carbon';"
mysql -uroot -pwso2carbon -e "grant all privileges on *.* to 'root'@'192.168.100.4' with grant option;"
mysql -uroot -pwso2carbon -e "flush privileges;"

sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

service mysql restart
