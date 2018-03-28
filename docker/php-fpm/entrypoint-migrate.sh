#!/bin/bash

# cd into our Laravel app directory.
PROJECT=laravel5
cd /var/www/${PROJECT};
ls -ltrah

# Ensure Laravel is in Maintenance Mode
php artisan down;

# Generate the application key.
php artisan key:generate --force;


#
# The `php artisan deploy:check` command has 120 seconds to complete.
#
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##

timeout 120s php artisan deploy:check;

#Capture the exit code in the rc variable
rc=$?;

#
# An exit code of 0 means we can start out
# application (migrations, seeds, etc).
#
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##


if [[ $rc == 0 ]]; then
   echo "************************************************\n";
   echo "*              DEPLOY CHECK PASSED!            *\n";
   echo "************************************************\n";


    if [ $1 = 'migrate' ]; then
       php artisan deploy:up --migrate;

       migrationOutcome=$?

       if [ $? -eq 0 ]; then

          echo "The deploy:up --migrate command finished with exit code ${migrationOutcome}"
          exit 0;
       else
        echo "The deploy:up --migrate command finished with an error code! ${migrationOutcome}"
        exit 1
       fi
    else
       echo "Running deploy:up without the migration command"
       php artisan deploy:up;
    fi
fi

if [[ $rc != 0 ]]; then

   if [[ $rc == 124 ]]; then
        echo "************************************************\n";
        echo "*                     ALERT                    *\n";
        echo "************************************************\n";
        echo "\n";
        echo "* Deploy Check has Timed Out!";
        echo "\n";
        echo "************************************************\n";

   else
        echo "************************************************\n";
        echo "*                     ALERT                    *\n";
        echo "************************************************\n";
        echo "\n";
        echo "* Deploy Check did not finish with a status code 0!";
        echo "\n";
        echo "************************************************\n";
   fi
fi

#
# Run the CMD argument specified in the Dockerfile.
# If our deployment was started correctly, the laravel framework would NOT be maintenance mode. If the
# deployment failed or timed out, the CMD will still start the supervisor which will start
# the laravel queue workers, but the workers themselves will not execute any jobs
# if the framework is in maintenance mode. HTTP requests will return 503 HTTP status codes if the
# framework is in maintenance mode which means that if this image is deployed
# as a POD in a Kubernetes cluster, the 503 can be used for the readiness probe.
#
###~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~##
# Modify the laravel.log to invoke Docker's Copy-on-write to bring the file up to current layer
: >> /var/www/${PROJECT}/storage/logs/laravel.log

# Tail the logs in the background
tail -f /var/www/${PROJECT}/storage/logs/laravel.log &

# Run the CMD argument specified in the Dockerfile. This ensures php-fpm runs as PID 1
exec "$@";
