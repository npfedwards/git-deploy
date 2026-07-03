#!/bin/sh
# Reload PHP-FPM — adjust the service name for your server
if command -v systemctl >/dev/null 2>&1; then
  for service in php-fpm php8.3-fpm php8.2-fpm; do
    if sudo systemctl reload "$service" 2>/dev/null; then
      echo "reloaded $service"
      exit 0
    fi
  done
  echo "Error: could not reload PHP-FPM (tried php-fpm, php8.3-fpm, php8.2-fpm)" >&2
  exit 1
fi
echo "restarted PHP app"
