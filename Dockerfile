FROM debian:jessie

RUN apt-get update && \
    apt-get install -y software-properties-common \
                       curl \
                       wget \
                       git \
                       libgd3 \
                       apache2 \
                       php5 \
                       unzip \
                    --no-install-recommends && rm -r /var/lib/apt/lists/*

RUN mkdir -p /var/lock/apache2 \
             /var/run/apache2 \
             /var/log/apache2 && \
    chown -R www-data:www-data /var/lock/apache2 \
             /var/run/apache2 \
             /var/log/apache2 \
             /var/www/html                       

#Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin creates=/usr/local/bin/composer && \
    mv /usr/local/bin/composer.phar /usr/local/bin/composer && \
    chmod a+x /usr/local/bin/composer && \
    composer --version

COPY ./apache2-foreground /usr/local/bin

EXPOSE 80

RUN chmod +x /usr/local/bin/apache2-foreground

ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_DIR /var/run/apache2
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2/apache2.pid


CMD ["apache2-foreground"]
