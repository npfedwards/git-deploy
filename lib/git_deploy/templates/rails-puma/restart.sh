#!/bin/sh
mkdir -p tmp/pids
if [ -f tmp/pids/puma.pid ]; then
  bundle exec pumactl -P tmp/pids/puma.pid restart
else
  mkdir -p tmp
  touch tmp/restart.txt
  echo "restarting Puma app (tmp/restart.txt fallback — configure puma.pid for pumactl restart)"
fi
