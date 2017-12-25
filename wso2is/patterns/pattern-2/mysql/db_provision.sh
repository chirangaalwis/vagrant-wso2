#!/bin/sh

# variables
DBPASSWD=wso2carbon

# for mysql 5.5 installed in ubuntu/trusty64
# export DEBIAN_FRONTEND=noninteractive
# apt-get update
# apt-get install -y mysql-server
# sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mysql/my.cnf
# restart mysql
# cd /vagrant/mysql/scripts
# mysqladmin -u root password wso2carbon
# mysql -uroot -pwso2carbon -e "source mysql.sql"

export DEBIAN_FRONTEND=noninteractive

echo debconf mysql-server/root_password password $DBPASSWD | \
  sudo debconf-set-selections
echo debconf mysql-server/root_password_again password $DBPASSWD | \
  sudo debconf-set-selections

apt-get update

# install mysql
apt-get -y install mysql-server
# install Expect
apt-get -y install expect

# build Expect script
tee ~/secure_mysql.sh > /dev/null << EOF
spawn $(which mysql_secure_installation)

expect "Enter password for user root:"
send "$DBPASSWD\r"

expect "Press y|Y for Yes, any other key for No:"
send "y\r"

expect "Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG:"
send "2\r"

expect "Change the password for root ? ((Press y|Y for Yes, any other key for No) :"
send "n\r"

expect "Remove anonymous users? (Press y|Y for Yes, any other key for No) :"
send "y\r"

expect "Disallow root login remotely? (Press y|Y for Yes, any other key for No) :"
send "y\r"

expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :"
send "y\r"

expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No) :"
send "y\r"

EOF

# run Expect script, which runs the "mysql_secure_installation" script which removes insecure defaults.
expect ~/secure_mysql.sh

# cleanup
rm -v ~/secure_mysql.sh

mysql -uroot -pwso2carbon -e "source /vagrant/mysql/scripts/mysql.sql"

mysql -uroot -pwso2carbon -e "create user 'root'@'192.168.100.3' identified by 'Carbon@wso2';"
mysql -uroot -pwso2carbon -e "grant all privileges on *.* to 'root'@'192.168.100.3' with grant option;"
mysql -uroot -pwso2carbon -e "create user 'root'@'192.168.100.4' identified by 'Carbon@wso2';"
mysql -uroot -pwso2carbon -e "grant all privileges on *.* to 'root'@'192.168.100.4' with grant option;"
mysql -uroot -pwso2carbon -e "create user 'root'@'192.168.100.5' identified by 'Carbon@wso2';"
mysql -uroot -pwso2carbon -e "grant all privileges on *.* to 'root'@'192.168.100.5' with grant option;"
#mysql -uroot -pwso2carbon -e "create user 'root'@'192.168.100.6' identified by 'Carbon@wso2';"
#mysql -uroot -pwso2carbon -e "grant all privileges on *.* to 'root'@'192.168.100.6' with grant option;"
mysql -uroot -pwso2carbon -e "flush privileges;"

sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

service mysql restart

# TODO: suppress warnings: https://stackoverflow.com/questions/20751352/suppress-warning-messages-using-mysql-from-within-terminal-but-password-written

# https://serverfault.com/questions/486710/access-to-mysql-server-via-virtualbox/486716#486716
