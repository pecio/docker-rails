#!/bin/sh -l
if [ -x "/usr/local/bundle/bin/$1" ]
then
  exec /usr/local/bin/bundle exec "$@"
else
  exec "$@"
fi
