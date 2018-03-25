FROM php:7.2-fpm

#--------------------------------------------------------------------------
# Software Installation
#--------------------------------------------------------------------------
# Installing tools and PHP extentions using "apt", "docker-php", "pecl",
#

# Install "curl", "libmemcached-dev", "libpq-dev", "libjpeg-dev",
#         "libpng-dev", "libfreetype6-dev", "libssl-dev", "libmcrypt-dev",
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    cron \
    procps \
    grep \
    vim \
    supervisor \
    curl \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
    wget \
  && rm -rf /var/lib/apt/lists/*

## Composer Install
RUN EXPECTED_COMPOSER_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig) && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '${EXPECTED_COMPOSER_SIGNATURE}') { echo 'Composer.phar Installer verified'; } else { echo 'Composer.phar Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"

RUN docker-php-ext-install pdo_pgsql pdo_mysql bcmath opcache \
&& docker-php-ext-configure gd \
  --enable-gd-native-ttf \
  --with-jpeg-dir=/usr/lib \
  --with-freetype-dir=/usr/include/freetype2 && \
  docker-php-ext-install gd bcmath opcache zip

#
#--------------------------------------------------------------------------
# Add Configuration Files
#--------------------------------------------------------------------------
#

#ARG LOCAL_SETTINGS_PATH=docker/docker-files/php
#
#ADD ${LOCAL_SETTINGS_PATH}/laravel.ini /usr/local/etc/php/conf.d
#ADD ${LOCAL_SETTINGS_PATH}/xlaravel.pool.conf /usr/local/etc/php-fpm.d/
#ADD ${LOCAL_SETTINGS_PATH}/supervisor.conf /etc/supervisord.conf
#ADD ${LOCAL_SETTINGS_PATH}/crontab /var/spool/cron/crontabs/root
#ADD ${LOCAL_SETTINGS_PATH}/entrypoint.sh /entrypoint.sh
#RUN chmod +x /entrypoint.sh

#
#--------------------------------------------------------------------------
# Add the Laravel Project
#--------------------------------------------------------------------------
#
# Composer must be ran on the host.
#

USER root

RUN rm -rf /var/www/* && mkdir -p /var/www/fleetcore

COPY composer.json /var/www/fleetcore

RUN chown -R www-data:www-data /var/www && usermod -u 1000 www-data

WORKDIR /var/www/fleetcore

RUN composer install --no-scripts --no-autoloader

COPY . /var/www/fleetcore

# Create the Laravel Log file and assign it to www-data:
RUN mkdir -p /var/www/fleetcore/storage/logs
RUN touch /var/www/fleetcore/storage/logs/laravel.log
RUN chown www-data:www-data /var/www/fleetcore/storage/logs/laravel.log

#Make storage folder and give access to www-data
RUN mkdir -p /var/www/fleetcore/storage
RUN chown -R www-data:www-data /var/www/fleetcore/storage

RUN composer dump-autoload --optimize;

EXPOSE 9000

#ENTRYPOINT ["php-fpm"]
ENTRYPOINT ["./entrypoint.sh"]
#CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]