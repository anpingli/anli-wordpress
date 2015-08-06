# CentOS7 + Wordpress + mysql + china  adapt
This repository is a subfolder yanked out of
https://github.com/CentOS/CentOS-Dockerfiles

You can run this image like below

1) docker run image 

2) docker run image -p 80:80

3) docker run image -p 80:80  --volumes-from /var/lib/mysql:/var/lib/mysql
