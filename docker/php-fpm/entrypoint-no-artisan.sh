#!/usr/bin/env bash

PROJECT=laravel5
cd /var/www/${PROJECT};

# Modify the laravel.log to invoke Docker's Copy-on-write to bring the file up to current layer
: >> /var/www/${PROJECT}/storage/logs/laravel.log

# Tail the logs in the background
tail -f /var/www/${PROJECT}/storage/logs/laravel.log &

# Run the CMD argument specified in the Dockerfile. This ensures php-fpm runs as PID 1
exec "$@";