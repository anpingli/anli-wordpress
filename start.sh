#!/bin/bash

WORDPRESS_DB="wordpress"
MYSQL_PASSWORD=`cat mysql-root-pw.txt`
WORDPRESS_PASSWORD=`cat /mysql-root-pw.txt`

__run_supervisor() {
supervisord -n
}

# Call all functions
#__check
__run_supervisor
