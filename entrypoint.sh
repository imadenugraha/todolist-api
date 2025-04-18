#!/bin/sh

echo "📦 Running migration"
cd /var/www && php artisan migrate --force

echo "🚀 Running Server"
exec cd /var/www && php artisan octane:frankenphp --workers=16 --host=0.0.0.0 --port=9804 --watch
