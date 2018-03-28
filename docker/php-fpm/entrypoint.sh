#!/usr/bin/env bash

echo $@
# Set the name of the home directory
PROJECT=laravel5

# checking for equivalence of "php /var/www/laravel5/artisan serve &" because when passing this through as an argument, the '&' for background mode isn't interpreted correctly
if [ "$1" = "php /var/www/${PROJECT}/artisan serve &" ];
then
    echo "starting artisan server and doing fresh seed"
    php /var/www/${PROJECT}/artisan serve &
    # Run the second command, by default it is "php /var/www/laravel5/artisan migrate:fresh --force --seed" it initially dump and seed the database
    $2
elif [ "$1" = "php artisan migrate --force" ]
then
    echo "running migrations"
    # Run the migrations, by default "php artisan migrate --force"
    $1;
else
    cd /var/www/${PROJECT};

    # Modify the laravel.log to invoke Docker's Copy-on-write to bring the file up to current layer
    : >> /var/www/${PROJECT}/storage/logs/laravel.log

    # Tail the logs in the background
    tail -f /var/www/${PROJECT}/storage/logs/laravel.log &

    # Run the CMD argument (php-fpm by default) specified in the Dockerfile. This ensures php-fpm runs as PID 1
    exec "$@";
fi