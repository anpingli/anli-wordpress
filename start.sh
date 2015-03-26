#!/bin/bash

# Replace wordpress Environment in configure file using custom Env
for curEnv in `env`;
do
	curVar=${curEnv%%=*}
	curValue=${curEnv#*=}
	sed "/define('$curVar.*/ s/,.*/,'as$curValue');/" /var/www/html/wp-config.php
done

# copy the default database files to word directory 
if [ "${DB_HOST:-127.0.0.1}" =  "127.0.0.1" ] &&  [ ! -d /var/lib/mysql/${DB_NAME:-"wordpress"}  ] ; then
   cp -r /root/mysql/* /var/lib/mysql/
fi

__run_supervisor() {
supervisord -n
}
__run_supervisor
