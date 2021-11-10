#!/bin/bash

eval $(printenv | sed -n "s/^\([^=]\+\)=\(.*\)$/export \1=\2/p" | sed 's/"/\\\"/g' | sed '/=/s//="/' | sed 's/$/"/' >> /etc/profile)

echo $APP_DIR
echo $ROOT_URL
echo $MONGO_URL

echo 'Starting app...'

cd $APP_DIR

exec "$@"