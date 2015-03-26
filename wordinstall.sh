#!/bin/bash
set -x

__handle_passwords() {
# Here we generate random passwords (thank you pwgen!). The first two are for mysql users, the last batch for random keys in wp-config.php
WORDPRESS_DB="wordpress"
MYSQL_PASSWORD=`pwgen -c -n -1 12`
WORDPRESS_PASSWORD=`pwgen -c -n -1 12`
# This is so the passwords show up in logs. 
echo mysql root password: $MYSQL_PASSWORD
echo wordpress password: $WORDPRESS_PASSWORD
echo $MYSQL_PASSWORD > /mysql-root-pw.txt
echo $WORDPRESS_PASSWORD > /wordpress-db-pw.txt
}

__renew_wordpress() {
rm -rf wordpress.tar.gz
rm -rf wordpress
rm -rf /var/www/html/*
curl -k -o wordpress.tar.gz https://wordpress.org/latest.tar.gz 
tar xvzf wordpress.tar.gz wordpress
cp -r wordpress/* /var/www/html/.
cp -r wordplugins/* /var/www/html/wp-content/plugins

sed -e "s/database_name_here/$WORDPRESS_DB/
s/username_here/$WORDPRESS_DB/
s/password_here/$WORDPRESS_PASSWORD/
/'AUTH_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
/'SECURE_AUTH_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
/'LOGGED_IN_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
/'NONCE_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
/'AUTH_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
/'SECURE_AUTH_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
/'LOGGED_IN_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
/'NONCE_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/" /var/www/html/wp-config-sample.php > /var/www/html/wp-config.php

chown -R apache:apache /var/www/html
}

__renew_mysql() {

supervisorctl stop mysqld
killall mysqld
# Hack to get MySQL up and running... I need to look into it more.
#yum -y erase mariadb mariadb-server
rm -rf /var/lib/mysql/ /etc/my.cnf
#yum -y install mariadb mariadb-server
mysql_install_db
chown -R mysql:mysql /var/lib/mysql

supervisorctl start mysqld 
sleep 10

mysqladmin -u root password $MYSQL_PASSWORD 
mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE wordpress; GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' IDENTIFIED BY '$WORDPRESS_PASSWORD'; FLUSH PRIVILEGES;"
sleep 10
killall mysqld

cp -r /var/lib/mysql /root/
}


# Call all functions
__handle_passwords
supervisorctl stop httpd
__renew_wordpress
__renew_mysql
