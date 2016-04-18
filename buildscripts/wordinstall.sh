#!/bin/bash
set -x

__new_passwords() {
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

__new_wordpress() {
curl -k -o wordpress.tar.gz https://wordpress.org/latest.tar.gz 
tar xvzf wordpress.tar.gz wordpress
cp -r wordpress/* /var/www/html/.
rm -rf wordpress.tar.gz wordpress
cp -r wordplugins/* /var/www/html/wp-content/plugins

sed -i 's/fonts.googleapis.com/font.useso.com/' /var/www/html/wp-includes/script-loader.php
sed -i 's/fonts.googleapis.com/font.useso.com/' /var/www/html/wp-content/themes/*/functions.php
sed -i 's/fonts.googleapis.com/font.useso.com/' /var/www/html/wp-includes/js/tinymce/plugins/compat3x/css/dialog.css

sed -e "s/database_name_here/$WORDPRESS_DB/
s/username_here/$WORDPRESS_DB/
s/localhost/127.0.0.1/
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

__new_mysql() {

killall mysqld
rm -rf /var/lib/mysql/ /etc/my.cnf
mysql_install_db
chown -R mysql:mysql /var/lib/mysql
/usr/bin/mysqld_safe &
sleep 10

mysqladmin -u root password $MYSQL_PASSWORD 
mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE wordpress; GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' IDENTIFIED BY '$WORDPRESS_PASSWORD'; FLUSH PRIVILEGES;"
sleep 10
killall mysqld_safe
cp -r /var/lib/mysql /root/

}


# Call all functions
__new_passwords
__new_wordpress
__new_mysql
