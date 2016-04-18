#!/bin/bash

# Replace wordpress Environment in configure file using custom Env
for curEnv in `env`;
do
	curVar=${curEnv%%=*}
	curValue=${curEnv#*=}
        # echo the match values and replace them
	sed -n "#define('$curVar.*# s#,.*#,'$curValue');#p" /var/www/html/wp-config.php
	sed -i "#define('$curVar.*# s#,.*#,'$curValue');#" /var/www/html/wp-config.php
done

# copy the default database files to word directory if the there is mysql database
if [ "${DB_HOST:-127.0.0.1}" = "127.0.0.1" ] && [ ! -d /var/lib/mysql/${DB_NAME:-"wordpress"}  ] ; then
   cp -r /root/mysql/* /var/lib/mysql/
   chcon -R system_u:object_r:mysqld_db_t:s0 mysql
fi

__run_supervisor() {
exec supervisord -n
}
__run_supervisor
