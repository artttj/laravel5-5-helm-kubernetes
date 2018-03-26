#!/usr/bin/env bash
#echo 'start of entrypoint'
cd /var/www/fleetcore;

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

# Run the CMD argument specified in the Dockerfile.

: >> /var/www/fleetcore/storage/logs/laravel.log && tail -f /var/www/fleetcore/storage/logs/laravel.log &
php-fpm
#exec "$@";