#!/bin/bash

cd $APP_DIR

echo "===> root_url: ${ROOT_URL}:${PORT}/"
echo "===> port ${PORT}"
echo "===> mail_url: ${MAIL_URL}"
echo "===> Database: ${MONGO_URL}"
echo "===> Database OP LOG: ${MONGO_OPLOG_URL}"

ROOT_URL=${ROOT_URL}:${PORT} METEOR_SETTINGS=$(cat programs/server/settings/settings.json) node main.js