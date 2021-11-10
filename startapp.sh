#!/bin/bash

echo "Running startapp script..."

echo -e "${ROOT_URL}"

cd $APP_DIR
echo -e "===> root_url: ${ROOT_URL}:${PORT}/"
echo -e "===> port ${PORT}"
echo -e "===> mail_url: ${MAIL_URL}"
echo -e "===> Database: ${MONGO_URL}"
echo -e "===> Database OP LOG: ${MONGO_OPLOG_URL}"

ROOT_URL=${ROOT_URL}:${PORT} METEOR_SETTINGS=$(cat programs/server/settings/settings.json) node main.js