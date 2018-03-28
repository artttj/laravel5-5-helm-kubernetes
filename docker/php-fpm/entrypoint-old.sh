#!/usr/bin/env bash

PROJECT=laravel5
cd /var/www/${PROJECT};

#cp /etc/volumes/fleetcore/.env .env

# Copy the oauth client secrets
#cp /etc/volumes/fleetcore/oauth-private.key ./storage/oauth-private.key
#cp /etc/volumes/fleetcore/oauth-public.key ./storage/oauth-public.key

# Ensure that the framework will return a 503 (Service Unavailable) for any HTTP requests.
# Allows other software to check if the application is ready.
php artisan down;

# Generate the application key.
php artisan key:generate --force;

php artisan migrate --force;

php artisan db:seed --force;

#php artisan auth:user-oauth-client;

# The framework is ready.
php artisan up;

# Modify the laravel.log to invoke Docker's Copy-on-write to bring the file up to current layer
: >> /var/www/${PROJECT}/storage/logs/laravel.log

# Tail the logs in the background
tail -f /var/www/${PROJECT}/storage/logs/laravel.log &

# Run the CMD argument specified in the Dockerfile. This ensures php-fpm runs as PID 1
exec "$@";


