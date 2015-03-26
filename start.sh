#!/bin/bash

WORDPRESS_DB="wordpress"
MYSQL_PASSWORD=`cat mysql-root-pw.txt`
WORDPRESS_PASSWORD=`cat /mysql-root-pw.txt`

__run_supervisor() {
supervisord -n
}

if [ ! -d /var/lib/mysql/wordpress ] ; then
   cp -r /root/mysql/* /var/lib/mysql/
fi

__run_supervisor
