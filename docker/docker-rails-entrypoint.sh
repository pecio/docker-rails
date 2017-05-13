#!/bin/sh -l
case "$1" in
  '')
    # Normal run
    exec /usr/bin/bundle exec unicorn -p 3000 -c config/unicorn.rb
    ;;
  rake|irb)
    exec /usr/bin/bundle exec "$@"
    ;;
  *)
    exec "$@"
    ;;
esac
