#!/bin/bash

echo "Running migration"
php artisan migrate --force

echo "Running Server"
exec php artisan octane:frankenphp --workers=16 --host=0.0.0.0 --port=9804 --watch
