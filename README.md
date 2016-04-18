# CentOS7 + Wordpress + mysql + china  adapt

You can run this image like below

1) docker run wordpresscn

2) docker run wordpresscn -p 80:80

3) docker run -p 8080:80  -v /var/lib/wordpress:/var/lib/mysql:z wordpresscn
