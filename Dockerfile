FROM debian:jessie

RUN apt-get update && \
    apt-get install -y openssh-client \
                       mysql-client \
                       software-properties-common \
                       curl \
                       wget \
                       git \
                       libgd3 \
                       apache2 \
                       php5 \
                       unzip \
                    --no-install-recommends && rm -r /var/lib/apt/lists/*

RUN a2enmod rewrite \
            remoteip \
            headers \
            expires \
            deflate \
            proxy \
            proxy_fcgi

COPY ./php.ini /usr/local/etc/php/

RUN apt-get update && \
    apt-get install -y php5-mysql \
                       php5-curl \
                       php5-cli \
                       php5-gd \
                       imagemagick \
                       php5-memcache \
                       php5-dev \
                       php5-imagick \
                       php-pear \
                    --no-install-recommends && rm -r /var/lib/apt/lists/*

RUN mkdir -p /var/lock/apache2 \
             /var/run/apache2 \
             /var/log/apache2 && \
    chown -R www-data:www-data /var/lock/apache2 \
             /var/run/apache2 \
             /var/log/apache2 \
             /var/www/html                       

#Install nodejs
RUN wget https://nodejs.org/dist/v4.4.3/node-v4.4.3-linux-x64.tar.xz && \
    tar xf node-v4.4.3-linux-x64.tar.xz && \
    mv node-v4.4.3-linux-x64 /var/lib/nodejs && \
    ln -s /var/lib/nodejs/bin/node /usr/local/bin/node && \
    ln -s /var/lib/nodejs/bin/npm /usr/local/bin/npm && \
    node --version && \
    npm version

#Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin creates=/usr/local/bin/composer && \
    mv /usr/local/bin/composer.phar /usr/local/bin/composer && \
    chmod a+x /usr/local/bin/composer && \
    composer --version

#Install phing and drush
RUN composer require phing/phing:2.* && \
    composer require drush/drush:8.1 && \
    cd vendor/drush/drush && composer install
RUN mv vendor /var/lib/composer-modules && \
    ln -s /var/lib/composer-modules/bin/drush /usr/local/bin/drush && \
    ln -s /var/lib/composer-modules/bin/phing /usr/local/bin/phing && \
    phing -v && drush --version

#Install grunt cli
RUN npm install -g grunt-cli && \
    ln -s /var/lib/nodejs/lib/node_modules/grunt-cli/bin/grunt /usr/local/bin/grunt && \
    grunt --version
    

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
    \curl -L https://get.rvm.io | bash -s stable && \
    /bin/bash -l -c "rvm requirements" && \
    /bin/bash -l -c "rvm install 2.1.5" && \
    /bin/bash -l -c "rvm install 2.3.0" && \
    /bin/bash -l -c "rvm use 2.1.5 && gem install bundler --no-ri --no-rdoc" && \
    /bin/bash -l -c "rvm use 2.3.0 && gem install bundler --no-ri --no-rdoc"    

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
