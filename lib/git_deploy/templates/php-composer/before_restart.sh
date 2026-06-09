#!/usr/bin/env bash
set -e
oldrev=$1
newrev=$2

if [ -f composer.json ]; then
  composer install --no-dev --optimize-autoloader --no-interaction
fi

if [ -f artisan ]; then
  php artisan migrate --force
fi
