# written by anli <anli@redhat.com>

FROM centos:centos7
MAINTAINER The CentOS Project <cloud-ops@centos.org>
RUN yum -y update; yum -y install epel-release; yum -y install hostname httpd php php-mysql php-gd pwgen supervisor bash-completion psmisc tar mariadb mariadb-server; yum clean all
EXPOSE 80 22

COPY ./wordplugins /wordplugins
COPY ./buildscripts/foreground.sh /etc/apache2/foreground.sh
COPY ./buildscripts/supervisord.conf /etc/supervisord.conf
COPY ./buildscripts/wordinstall.sh /tmp/wordinstall.sh
RUN /tmp/wordinstall.sh

COPY ./start.sh  /
CMD ["/start.sh"]
