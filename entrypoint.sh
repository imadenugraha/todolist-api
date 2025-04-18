#!/bin/sh

set -xe

echo "📦 Running migration"
cd /var/www && \
    php artisan config:cache && \
    php artisan view:cache && \
    php artisan migrate --force

echo "🚀 Running Server"
cd /var/www && exec php artisan octane:frankenphp --workers=4 --host=0.0.0.0 --port=9804
