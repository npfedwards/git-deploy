#!/bin/sh
# Reload PHP-FPM — adjust the service name for your server
if command -v systemctl >/dev/null 2>&1; then
  sudo systemctl reload php-fpm 2>/dev/null \
    || sudo systemctl reload php8.3-fpm 2>/dev/null \
    || sudo systemctl reload php8.2-fpm 2>/dev/null \
    || true
fi
echo "restarted PHP app"
