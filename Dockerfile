# install meme distro
FROM	debian:buster

# setup srcs
COPY srcs srcs

# install everything
RUN		apt-get update
RUN		apt-get -y install mariadb-server
RUN		apt-get -y install nginx 
RUN		apt-get -y install php7.3-fpm php-common php-mysql php-mbstring

# download things not in pacman
RUN		apt-get -y install wget
## get phpmyadmin
RUN		wget https://files.phpmyadmin.net/phpMyAdmin/4.9.2/phpMyAdmin-4.9.2-english.tar.gz
RUN		tar -xzvf phpMyAdmin-4.9.2-english.tar.gz
## get wordpress
RUN		tar -xzvf srcs/latest.tar.gz -C /

# setup mysql basics
RUN		service mysql start; \
		mysql -uroot mysql; \
		mysqladmin password "guest"; \
		echo "DELETE FROM mysql.user WHERE User='';" | mysql --user=root;\
		echo "CREATE DATABASE wordpress;" | mysql --user=root;\
		echo "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');" | mysql --user=root; \
		echo "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';" | mysql --user=root; \
		echo "FLUSH PRIVILEGES;" | mysql --user=root

EXPOSE 80
EXPOSE 443

# load configs
RUN		rm /etc/nginx/sites-enabled/default
RUN		cp srcs/nginx_config /etc/nginx/conf.d/default.conf
RUN		mkdir /wordpress/phpmyadmin && mv -v phpMyAdmin-4.9.2-english/* /wordpress/phpmyadmin
RUN		cp -f srcs/config.inc.php /wordpress/phpmyadmin
RUN		cp -f srcs/wp-config.php /wordpress/

# run programs
CMD		sh srcs/start.sh