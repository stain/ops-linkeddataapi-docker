FROM ubuntu:14.04
MAINTAINER Stian Soiland-Reyes <soiland-reyes@cs.manchester.ac.uk>

# Install apache/PHP for REST API
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
	apache2 php5 memcached php5-memcached php5-memcache php5-curl \
        supervisor \
        unzip wget 
RUN a2enmod rewrite

RUN rm -rf /var/www/html
#Install Linked Data API
RUN wget https://github.com/openphacts/OPS_LinkedDataApi/archive/1.5.0.zip -O /tmp/api.zip && \
    cd /tmp && \
    unzip api.zip && \
    mv /tmp/OPS* /var/www/html

RUN sed -i '/<\/VirtualHost/ i\ <Directory /var/www/html/>\n  AllowOverride All\n </Directory>' /etc/apache2/sites-enabled/000-default.conf
#RUN cat /etc/apache2/apache2.conf | tr "\n" "|||" | \
#      sed 's,\(<Directory /var/www/html/>[^<]*\)AllowOverride None\([^<]*</Directory>\),\1AllowOverride All\2,' | \
#      sed 's/|||/n/g' >/tmp/apache2 && \
#    mv /tmp/apache2 /etc/apache2/apache2.conf
RUN mkdir /var/www/html/logs /var/www/html/cache && \
    chmod 777 /var/www/html/logs /var/www/html/cache && \
    chown -R www-data:www-data /var/www/html


EXPOSE 80 
CMD service memcached start && . /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND

