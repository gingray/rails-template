#!/bin/sh

rm -f /app/tmp/pids/server.pid

bundle exec rails db:create
bundle exec rails db:migrate

bundle exec puma -C config/puma.rb -b tcp://0.0.0.0:3000