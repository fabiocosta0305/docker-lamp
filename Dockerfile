FROM ubuntu:17.04
MAINTAINER Fer Uria <fauria@gmail.com>
LABEL Description="Cutting-edge LAMP stack, based on Ubuntu 16.04 LTS. Includes .htaccess support and popular PHP7 features, including composer and mail() function." \
	License="Apache License 2.0" \
	Usage="docker run -d -p [HOST WWW PORT NUMBER]:80 -p [HOST DB PORT NUMBER]:3306 -v [HOST WWW DOCUMENT ROOT]:/var/www/html -v [HOST DB DOCUMENT ROOT]:/var/lib/mysql fauria/lamp" \
	Version="1.0"

RUN apt-get update
RUN apt-get upgrade -y

COPY debconf.selections /tmp/
RUN debconf-set-selections /tmp/debconf.selections

RUN apt-get install -y \
	php7.0 \
	php7.0-bz2 \
	php7.0-cgi \
	php7.0-cli \
	php7.0-common \
	php7.0-curl \
	php7.0-dev \
	php7.0-enchant \
	php7.0-fpm \
	php7.0-gd \
	php7.0-gmp \
	php7.0-imap \
	php7.0-interbase \
	php7.0-intl \
	php7.0-json \
	php7.0-ldap \
	php7.0-mcrypt \
	php7.0-mysql \
	php7.0-odbc \
	php7.0-opcache \
	php7.0-pgsql \
	php7.0-phpdbg \
	php7.0-pspell \
	php7.0-readline \
	php7.0-recode \
	php7.0-snmp \
	php7.0-sqlite3 \
	php7.0-sybase \
	php7.0-tidy \
	php7.0-xmlrpc \
	php7.0-xsl
# RUN apt-get install apache2 libapache2-mod-php7.0 -y
RUN apt-get install postgresql postgresql-contrib phppgadmin php-pgsql -y
# RUN apt-get install mariadb-common mariadb-server mariadb-client -y
RUN apt-get install postfix -y
RUN apt-get install git nodejs npm composer nano tree vim curl ftp -y
RUN apt-get install nginx -y
RUN npm install -g bower grunt-cli gulp
RUN apt-get install sudo -y
RUN apt-get install openssh-server -y

ENV LOG_STDOUT **Boolean**
ENV LOG_STDERR **Boolean**
ENV LOG_LEVEL warn
ENV ALLOW_OVERRIDE All
ENV DATE_TIMEZONE UTC
ENV TERM dumb

#COPY default /etc/nginx/sites-avaliable/

RUN a2enmod rewrite
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN chown -R www-data:www-data /var/www/html
RUN mkdir -p /var/run/postgresql/9.6-main.pg_stat_tmp/
RUN chown -R postgres:postgres /var/run/postgresql/
RUN mkdir -p /var/run/sshd/


# Creating an user for some needed access

RUN useradd -ms /bin/bash user
RUN echo 'user:password' | chpasswd
RUN usermod -aG sudo user

#COPY first-psql-user.sh /usr/sbin/
#RUN chmod +x /usr/sbin/first-psql-user.sh
#RUN /usr/sbin/first-psql-user.sh

#RUN su postgres -c '/usr/lib/postgresql/9.6/bin/pg_ctl start' &
#RUN find /usr -iname '*postgres*'
RUN sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/9.6/main/postgresql.conf
RUN echo 'host all all 0.0.0.0/0 md5' >> /etc/postgresql/9.6/main/pg_hba.conf

# RUN su postgres -c '/usr/lib/postgresql/9.6/bin/postgres --single  --config-file=/etc/postgresql/9.6/main/postgresql.conf' &
# RUN sleep 10
# RUN sudo -u postgres psql -p 5432 -c "ALTER user postgres WITH ENCRYPTED PASSWORD 'postgres'"

RUN echo "ALTER user postgres WITH PASSWORD 'postgres'" | su postgres -c '/usr/lib/postgresql/9.6/bin/postgres --single  --config-file=/etc/postgresql/9.6/main/postgresql.conf' 

# VOLUME /var/lib/mysql
# VOLUME /var/log/mysql

EXPOSE 80
EXPOSE 22
#EXPOSE 3306
EXPOSE 5432


VOLUME /var/www/html
VOLUME /var/log/httpd
VOLUME /var/lib/postgresql/
VOLUME /var/log/postgresql/
VOLUME /var/run/postgresql/
VOLUME /etc/postgresql/
VOLUME /run/postgresql/

COPY index.php /var/www/html/
COPY run-lamp.sh /usr/sbin/
COPY sshd_config /etc/ssh/
RUN chmod +x /usr/sbin/run-lamp.sh


# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf 

#CMD ["/usr/sbin/run-lamp.sh"]
CMD ["/usr/lib/postgresql/9.6/bin/postgres", "-D", "/var/lib/postgresql/9.6/main", "-c",  "--config_file=/etc/postgresql/9.6/main/postgresql.conf"]
CMD ["/usr/sbin/sshd", "-D"]
CMD ["/usr/sbin/nginx"]

    
