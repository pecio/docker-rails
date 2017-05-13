#!/bin/sh -l
case "$1" in
  '')
    # Normal run
    exec /usr/bin/local/bundle exec unicorn -p 3000 -c config/unicorn.rb
    ;;
  rails|rake|irb)
    exec /usr/local/bin/bundle exec "$@"
    ;;
  *)
    exec "$@"
    ;;
esac
