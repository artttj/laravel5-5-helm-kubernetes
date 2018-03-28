#!/bin/bash

# cd into our Laravel app directory.
PROJECT=laravel5
cd /var/www/${PROJECT};
ls -ltrah

# Ensure Laravel is in Maintenance Mode
php artisan down;

# Generate the application key.
php artisan key:generate --force;

php artisan migrate;

php artisan up;

# Modify the laravel.log to invoke Docker's Copy-on-write to bring the file up to current layer
: >> /var/www/${PROJECT}/storage/logs/laravel.log

# Tail the logs in the background
tail -f /var/www/${PROJECT}/storage/logs/laravel.log &

# Run the CMD argument specified in the Dockerfile. This ensures php-fpm runs as PID 1
exec "$@";
